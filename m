Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id EA50D6B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 08:09:23 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so1532487eek.18
        for <linux-mm@kvack.org>; Wed, 21 May 2014 05:09:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b49si8329035eef.116.2014.05.21.05.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 05:09:22 -0700 (PDT)
Date: Wed, 21 May 2014 13:09:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: non-atomically mark page accessed during page cache
 allocation where possible -fix
Message-ID: <20140521120916.GS23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-19-git-send-email-mgorman@suse.de>
 <20140520154900.GO23991@suse.de>
 <20140520123453.09a76dd0c8fad40082a16289@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140520123453.09a76dd0c8fad40082a16289@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Prabhakar Lad <prabhakar.csengg@gmail.com>

On Tue, May 20, 2014 at 12:34:53PM -0700, Andrew Morton wrote:
> On Tue, 20 May 2014 16:49:00 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Prabhakar Lad reported the following problem
> > 
> >   I see following issue on DA850 evm,
> >   git bisect points me to
> >   commit id: 975c3a671f11279441006a29a19f55ccc15fb320
> >   ( mm: non-atomically mark page accessed during page cache allocation
> >   where possible)
> > 
> >   Unable to handle kernel paging request at virtual address 30e03501
> >   pgd = c68cc000
> >   [30e03501] *pgd=00000000
> >   Internal error: Oops: 1 [#1] PREEMPT ARM
> >   Modules linked in:
> >   CPU: 0 PID: 1015 Comm: network.sh Not tainted 3.15.0-rc5-00323-g975c3a6 #9
> >   task: c70c4e00 ti: c73d0000 task.ti: c73d0000
> >   PC is at init_page_accessed+0xc/0x24
> >   LR is at shmem_write_begin+0x54/0x60
> >   pc : [<c0088aa0>]    lr : [<c00923e8>]    psr: 20000013
> >   sp : c73d1d90  ip : c73d1da0  fp : c73d1d9c
> >   r10: c73d1dec  r9 : 00000000  r8 : 00000000
> >   r7 : c73d1e6c  r6 : c694d7bc  r5 : ffffffe4  r4 : c73d1dec
> >   r3 : c73d0000  r2 : 00000001  r1 : 00000000  r0 : 30e03501
> >   Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> >   Control: 0005317f  Table: c68cc000  DAC: 00000015
> >   Process network.sh (pid: 1015, stack limit = 0xc73d01c0)
> > 
> > pagep is set but not pointing to anywhere valid as it's an uninitialised
> > stack variable. This patch is a fix to
> > mm-non-atomically-mark-page-accessed-during-page-cache-allocation-where-possible.patch
> > 
> > ...
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2459,7 +2459,7 @@ ssize_t generic_perform_write(struct file *file,
> >  		flags |= AOP_FLAG_UNINTERRUPTIBLE;
> >  
> >  	do {
> > -		struct page *page;
> > +		struct page *page = NULL;
> >  		unsigned long offset;	/* Offset into pagecache page */
> >  		unsigned long bytes;	/* Bytes to write to page */
> >  		size_t copied;		/* Bytes copied from user */
> 
> Well not really.  generic_perform_write() only touches *page if
> ->write_begin() returned "success", which is reasonable behavior.
> 
> I'd say you mucked up shmem_write_begin() - it runs
> init_page_accessed() even if shmem_getpage() returned an error.  It
> shouldn't be doing that.
> 
> This?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/shmem.c: don't run init_page_accessed() against an uninitialised pointer
> 
> If shmem_getpage() returned an error then it didn't necessarily initialise
> *pagep.  So shmem_write_begin() shouldn't be playing with *pagep in this
> situation.
> 
> Fixes an oops when "mm: non-atomically mark page accessed during page
> cache allocation where possible" (quite reasonably) left *pagep
> uninitialized.
> 
> Reported-by: Prabhakar Lad <prabhakar.csengg@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
