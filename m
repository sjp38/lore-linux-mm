Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB6E86B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 06:10:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so27774719wrb.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 03:10:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si3606461wrv.93.2017.07.25.03.10.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 03:10:13 -0700 (PDT)
Date: Tue, 25 Jul 2017 11:10:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170725100722.2dxnmgypmwnrfawp@suse.de>
References: <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170725091115.GA22920@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 25, 2017 at 06:11:15PM +0900, Minchan Kim wrote:
> On Tue, Jul 25, 2017 at 09:51:32AM +0100, Mel Gorman wrote:
> > On Tue, Jul 25, 2017 at 04:37:48PM +0900, Minchan Kim wrote:
> > > > Ok, as you say you have reproduced this with corruption, I would suggest
> > > > one path for dealing with it although you'll need to pass it by the
> > > > original authors.
> > > > 
> > > > When unmapping ranges, there is a check for dirty PTEs in
> > > > zap_pte_range() that forces a flush for dirty PTEs which aims to avoid
> > > > writable stale PTEs from CPU0 in a scenario like you laid out above.
> > > > 
> > > > madvise_free misses a similar class of check so I'm adding Minchan Kim
> > > > to the cc as the original author of much of that code. Minchan Kim will
> > > > need to confirm but it appears that two modifications would be required.
> > > > The first should pass in the mmu_gather structure to
> > > > madvise_free_pte_range (at minimum) and force flush the TLB under the
> > > > PTL if a dirty PTE is encountered. The second is that it should consider
> > > 
> > > OTL: I couldn't read this lengthy discussion so I miss miss something.
> > > 
> > > About MADV_FREE, I do not understand why it should flush TLB in MADV_FREE
> > > context. MADV_FREE's semantic allows "write(ie, dirty)" so if other thread
> > > in parallel which has stale pte does "store" to make the pte dirty,
> > > it's okay since try_to_unmap_one in shrink_page_list catches the dirty.
> > > 
> > 
> > In try_to_unmap_one it's fine. It's not necessarily fine in KSM. Given
> > that the key is that data corruption is avoided, you could argue with a
> > comment that madv_free doesn't necesssarily have to flush it as long as
> > KSM does even if it's clean due to batching.
> 
> Yes, I think it should be done in side where have a concern.
> Maybe, mm_struct can carry a flag which indicates someone is
> doing the TLB bacthing and then KSM side can flush it by the flag.
> It would reduce unncessary flushing.
> 

If you're confident that it's only necessary on the KSM side to avoid the
problem then I'm ok with that. Update KSM in that case with a comment
explaining the madv_free race and why the flush is unconditionally
necessary. madv_free only came up because it was a critical part of having
KSM miss a TLB flush.

> > Like madvise(), madv_free can potentially return with a stale PTE visible
> > to the caller that observed a pte_none at the time of madv_free and uses
> > a stale PTE that potentially allows a lost write. It's debatable whether
> 
> That is the part I cannot understand.
> How does it lost "the write"? MADV_FREE doesn't discard the memory so
> finally, the write should be done sometime.
> Could you tell me more?
> 

I'm relying on the fact you are the madv_free author to determine if
it's really necessary. The race in question is CPU 0 running madv_free
and updating some PTEs while CPU 1 is also running madv_free and looking
at the same PTEs. CPU 1 may have writable TLB entries for a page but fail
the pte_dirty check (because CPU 0 has updated it already) and potentially
fail to flush. Hence, when madv_free on CPU 1 returns, there are still
potentially writable TLB entries and the underlying PTE is still present
so that a subsequent write does not necessarily propagate the dirty bit
to the underlying PTE any more. Reclaim at some unknown time at the future
may then see that the PTE is still clean and discard the page even though
a write has happened in the meantime. I think this is possible but I could
have missed some protection in madv_free that prevents it happening.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
