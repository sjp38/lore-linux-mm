Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 252F66B0047
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 21:28:37 -0500 (EST)
Date: Sun, 21 Feb 2010 10:28:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Message-ID: <20100221022831.GB6448@localhost>
References: <4B6B7FBF.9090005@bx.jp.nec.com> <20100205072858.GC9320@elte.hu> <20100208155450.GA17055@localhost> <20100209162101.GA12840@localhost> <20100213132952.GG11364@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100213132952.GG11364@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Chris Frost <frost@cs.ucla.edu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

> > tracing: pagecache object collections
> >
> > This dumps
> > - all cached files of a mounted fs  (the inode-cache)
> > - all cached pages of a cached file (the page-cache)
> >
> > Usage and Sample output:
> >
> > # echo /dev > /debug/tracing/objects/mm/pages/walk-fs
> > # tail /debug/tracing/trace
> >              zsh-2528  [000] 10429.172470: dump_inode: ino=889 size=0 cached=0 age=442 dirty=0 dev=0:18 file=/dev/console
> >              zsh-2528  [000] 10429.172472: dump_inode: ino=888 size=0 cached=0 age=442 dirty=7 dev=0:18 file=/dev/null
> >              zsh-2528  [000] 10429.172474: dump_inode: ino=887 size=40 cached=0 age=442 dirty=0 dev=0:18 file=/dev/shm
> >              zsh-2528  [000] 10429.172477: dump_inode: ino=886 size=40 cached=0 age=442 dirty=0 dev=0:18 file=/dev/pts
> >              zsh-2528  [000] 10429.172479: dump_inode: ino=885 size=11 cached=0 age=442 dirty=0 dev=0:18 file=/dev/core
> >              zsh-2528  [000] 10429.172481: dump_inode: ino=884 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stderr
> >              zsh-2528  [000] 10429.172483: dump_inode: ino=883 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stdout
> >              zsh-2528  [000] 10429.172486: dump_inode: ino=882 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stdin
> >              zsh-2528  [000] 10429.172488: dump_inode: ino=881 size=13 cached=0 age=442 dirty=0 dev=0:18 file=/dev/fd
> >              zsh-2528  [000] 10429.172491: dump_inode: ino=872 size=13360 cached=0 age=442 dirty=0 dev=0:18 file=/dev
> >
> > Here "age" is either age from inode create time, or from last dirty time.
> >
> 
> It would be nice to see mapped/unmapped information as well.

As you noticed, we have mapcount for individual pages :)

> > +static int pages_similiar(struct page* page0, struct page* page)
> > +{
> > +     if (page_count(page0) != page_count(page))
> > +             return 0;
> > +
> > +     if (page_mapcount(page0) != page_mapcount(page))
> > +             return 0;
> > +
> > +     if (page_flags(page0) != page_flags(page))
> > +             return 0;
> > +
> > +     return 1;
> > +}
> > +
> 
> OK, so pages_similar() is used to identify a range of pages in the
> cache?

Right. Many files are accessed sequentially or clustered, so
pages_similar() can save lots of output lines :)

> > +#define BATCH_LINES  100
> > +static void dump_pagecache(struct address_space *mapping)
> > +{
> > +     int i;
> > +     int lines = 0;
> > +     pgoff_t len = 0;
> > +     struct pagevec pvec;
> > +     struct page *page;
> > +     struct page *page0 = NULL;
> > +     unsigned long start = 0;
> > +
> > +     for (;;) {
> > +             pagevec_init(&pvec, 0);
> > +             pvec.nr = radix_tree_gang_lookup(&mapping->page_tree,
> > +                             (void **)pvec.pages, start + len, PAGEVEC_SIZE);
> 
> Is radix_tree_gang_lookup synchronized somewhere? Don't we need to
> call it under RCU or a lock (mapping) ?

No. This function is inherently non-atomic, and it seems that most in-kernel
users do not bother to take rcu_read_lock(). So lets leave it as is?

> > +static ssize_t
> > +trace_pagecache_write(struct file *filp, const char __user *ubuf, size_t count,
> > +                   loff_t *ppos)
> > +{
> > +     struct file *file = NULL;
> > +     char *name;
> > +     int err = 0;
> > +
> 
> Can't we use the trace_parser here?

Seems not necessary? It's merely one file name, which could contain spaces.

> > +     if (count <= 1)
> > +             return -EINVAL;
> > +     if (count > PATH_MAX + 1)
> > +             return -ENAMETOOLONG;
> > +
> > +     name = kmalloc(count+1, GFP_KERNEL);
> > +     if (!name)
> > +             return -ENOMEM;
> > +
> > +     if (copy_from_user(name, ubuf, count)) {
> > +             err = -EFAULT;
> > +             goto out;
> > +     }
> > +
> > +     /* strip the newline added by `echo` */
> > +     if (name[count-1] != '\n')
> > +             return -EINVAL;
> 
> Doesn't sound correct, what happens if we use echo -n?

It's a bit sad. If we accept both "echo" and "echo -n" with some
smart logic to test for trailing '\n', then it will go wrong for a
'\n'-terminated file name.

Or shall we support only "echo -n"?  I can do with either one.

> > --- linux-mm.orig/fs/inode.c  2010-02-08 23:19:12.000000000 +0800
> > +++ linux-mm/fs/inode.c       2010-02-08 23:19:22.000000000 +0800
> > @@ -149,7 +149,7 @@ struct inode *inode_init_always(struct s
> >       inode->i_bdev = NULL;
> >       inode->i_cdev = NULL;
> >       inode->i_rdev = 0;
> > -     inode->dirtied_when = 0;
> > +     inode->dirtied_when = jiffies;
> >
> 
> Hmmm... Is the inode really dirtied when initialized? I know the
> change is for tracing, but the code when read is confusing.

Huh. Not really dirtied (for that you need to check I_DIRTY), but
dirtied_when is only used in writeback code when I_DIRTY is set.

So I overload dirtied_when in the clean case to indicate the inode
load time. This is a useful trick for fastboot to collect cache
footprint shortly after boot, when most inodes are clean.

It does ask for a comment:

        /*
         * This records inode load time. It will be invalidated once inode is
         * dirtied, or jiffies wraps around. Despite the pitfalls it still
         * provides useful information for some use cases like fastboot.
         */
        inode->dirtied_when = jiffies;


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
