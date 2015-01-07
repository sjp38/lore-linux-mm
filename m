Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E91906B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 21:03:56 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so1473612pdj.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 18:03:56 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bd4si176904pdb.204.2015.01.06.18.03.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 18:03:55 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so1563818pab.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 18:03:54 -0800 (PST)
Date: Tue, 6 Jan 2015 18:03:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC] mm:change meminfo cached calculation
In-Reply-To: <20150106172518.8f84bffdfa0d35336b233d07@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1501061747540.2041@eggly.anvils>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net> <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com> <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net> <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net> <20141208114601.GA28846@node.dhcp.inet.fi> <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net> <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103EDAF89E160@CNBJMBX05.corpusers.net> <20150106164340.55e83f742d6f57c19e6500ff@linux-foundation.org>
 <alpine.LSU.2.11.1501061654340.1497@eggly.anvils> <20150106172518.8f84bffdfa0d35336b233d07@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "minchan@kernel.org" <minchan@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "pintu.k@samsung.com" <pintu.k@samsung.com>

On Tue, 6 Jan 2015, Andrew Morton wrote:
> On Tue, 6 Jan 2015 17:04:33 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:
> > On Tue, 6 Jan 2015, Andrew Morton wrote:
> > > On Fri, 26 Dec 2014 19:56:49 +0800 "Wang, Yalin" <Yalin.Wang@sonymobile.com> wrote:
> > > 
> > > > This patch subtract sharedram from cached,
> > > > sharedram can only be swap into swap partitions,
> > > > they should be treated as swap pages, not as cached pages.
> > > > 
> > > > ...
> > > >
> > > > --- a/fs/proc/meminfo.c
> > > > +++ b/fs/proc/meminfo.c
> > > > @@ -45,7 +45,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
> > > >  	committed = percpu_counter_read_positive(&vm_committed_as);
> > > >  
> > > >  	cached = global_page_state(NR_FILE_PAGES) -
> > > > -			total_swapcache_pages() - i.bufferram;
> > > > +			total_swapcache_pages() - i.bufferram - i.sharedram;
> > > >  	if (cached < 0)
> > > >  		cached = 0;
> > > 
> > > Documentation/filesystems/proc.txt says
> > > 
> > > :      Cached: in-memory cache for files read from the disk (the
> > > :              pagecache).  Doesn't include SwapCached
> > > 
> > > So yes, I guess it should not include shmem.
> > > 
> > > And why not do this as well?
> > > 
> > > 
> > > --- a/Documentation/filesystems/proc.txt~mm-change-meminfo-cached-calculation-fix
> > > +++ a/Documentation/filesystems/proc.txt
> > > @@ -811,7 +811,7 @@ MemAvailable: An estimate of how much me
> > >       Buffers: Relatively temporary storage for raw disk blocks
> > >                shouldn't get tremendously large (20MB or so)
> > >        Cached: in-memory cache for files read from the disk (the
> > > -              pagecache).  Doesn't include SwapCached
> > > +              pagecache).  Doesn't include SwapCached or Shmem.
> > >    SwapCached: Memory that once was swapped out, is swapped back in but
> > >                still also is in the swapfile (if memory is needed it
> > >                doesn't need to be swapped out AGAIN because it is already
> > 
> > Whoa.  Changes of this kind would have made good sense about 14 years ago.
> > And there's plenty more which would benefit from having anon/shmem/file
> > properly distinguished.  But how can we make such a change now,
> > breaking everything that has made its own sense of these counts?
> 
> That's what I was wondering, but I was having some trouble picking a
> situation where it mattered much.

If it doesn't matter, then we don't need to change it.

> What's the problematic scenario
> here?  Userspace that is taking Cached, saying "that was silly" and
> subtracting Shmem from it by hand?

Someone a long time ago saw "that was silly", worked out it was because
of Shmem, adjusted their scripts or whatever accordingly, and has run
happily ever since.

> 
> I suppose that as nobody knows we should err on the side of caution and
> leave this alone.  But the situation is pretty sad - it would be nice
> to make the code agree with the documentation at least.

By all means fix the documentation.  And work on a /proc/meminfo.2015
which has sensibly differentiated counts (and probably omits that
wonderful Linux 2.2-compatible "Buffers").

But there's more to do than I can think of.  Cc'ing Jerome who has a
particular interest in this (no, I haven't forgotten his patches,
but nor have I had a moment to reconsider them).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
