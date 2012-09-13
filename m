Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 56AB06B010F
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 20:03:14 -0400 (EDT)
Date: Thu, 13 Sep 2012 09:05:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] memory-hotplug: don't replace lowmem pages with
 highmem
Message-ID: <20120913000519.GC2766@bbox>
References: <1347414231-31451-1-git-send-email-minchan@kernel.org>
 <1347414231-31451-2-git-send-email-minchan@kernel.org>
 <20120912143239.65fa8b58.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912143239.65fa8b58.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>

On Wed, Sep 12, 2012 at 02:32:39PM -0700, Andrew Morton wrote:
> On Wed, 12 Sep 2012 10:43:51 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > [1] reporeted that lowmem pages could be replaced by
> > highmem pages during migration of CMA and fixed.
> > 
> > Quote from [1]'s description
> > "
> >     The filesystem layer expects pages in the block device's mapping to not
> >     be in highmem (the mapping's gfp mask is set in bdget()), but CMA can
> >     currently replace lowmem pages with highmem pages, leading to crashes in
> >     filesystem code such as the one below:
> > 
> >       Unable to handle kernel NULL pointer dereference at virtual address 00000400
> >       pgd = c0c98000
> >       [00000400] *pgd=00c91831, *pte=00000000, *ppte=00000000
> >       Internal error: Oops: 817 [#1] PREEMPT SMP ARM
> >       CPU: 0    Not tainted  (3.5.0-rc5+ #80)
> >       PC is at __memzero+0x24/0x80
> >       ...
> >       Process fsstress (pid: 323, stack limit = 0xc0cbc2f0)
> >       Backtrace:
> >       [<c010e3f0>] (ext4_getblk+0x0/0x180) from [<c010e58c>] (ext4_bread+0x1c/0x98)
> >       [<c010e570>] (ext4_bread+0x0/0x98) from [<c0117944>] (ext4_mkdir+0x160/0x3bc)
> >        r4:c15337f0
> >       [<c01177e4>] (ext4_mkdir+0x0/0x3bc) from [<c00c29e0>] (vfs_mkdir+0x8c/0x98)
> >       [<c00c2954>] (vfs_mkdir+0x0/0x98) from [<c00c2a60>] (sys_mkdirat+0x74/0xac)
> >        r6:00000000 r5:c152eb40 r4:000001ff r3:c14b43f0
> >       [<c00c29ec>] (sys_mkdirat+0x0/0xac) from [<c00c2ab8>] (sys_mkdir+0x20/0x24)
> >        r6:beccdcf0 r5:00074000 r4:beccdbbc
> >       [<c00c2a98>] (sys_mkdir+0x0/0x24) from [<c000e3c0>] (ret_fast_syscall+0x0/0x30)
> > "
> > 
> > Memory-hotplug has same problem with CMA so [1]'s fix could be applied
> > with memory-hotplug, too.
> > 
> > Fix it by reusing.
> 
> Do we think this issue should be fixed in 3.6?  Earlier?

I really wanted to Cced stable but didn't due to a below

 - It must fix a real bug that bothers people (not a, "This could be a
   problem..." type thing).

We haven't ever seen at the report of memory-hotplug although it pops up in CMA.
But I doubt fujitsu guys already saw it.


> 
> > @@ -809,8 +802,12 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  			putback_lru_pages(&source);
> >  			goto out;
> >  		}
> > -		/* this function returns # of failed pages */
> > -		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
> > +
> > +		/*
> > +		 * alloc_migrate_target should be improooooved!!
> 
> Not a helpful comment!  If you've identified some improvement then
> please do provide all the details.

I have an idea to improve it and hoping send patch soonish.
I will handle it in my patch.

Thanks Andrew.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
