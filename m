Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 138A86B02B4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:11:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g14so176701822pgu.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:11:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w22si8376026plk.820.2017.07.25.02.11.16
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 02:11:17 -0700 (PDT)
Date: Tue, 25 Jul 2017 18:11:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170725091115.GA22920@bbox>
References: <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725085132.iysanhtqkgopegob@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 25, 2017 at 09:51:32AM +0100, Mel Gorman wrote:
> On Tue, Jul 25, 2017 at 04:37:48PM +0900, Minchan Kim wrote:
> > > Ok, as you say you have reproduced this with corruption, I would suggest
> > > one path for dealing with it although you'll need to pass it by the
> > > original authors.
> > > 
> > > When unmapping ranges, there is a check for dirty PTEs in
> > > zap_pte_range() that forces a flush for dirty PTEs which aims to avoid
> > > writable stale PTEs from CPU0 in a scenario like you laid out above.
> > > 
> > > madvise_free misses a similar class of check so I'm adding Minchan Kim
> > > to the cc as the original author of much of that code. Minchan Kim will
> > > need to confirm but it appears that two modifications would be required.
> > > The first should pass in the mmu_gather structure to
> > > madvise_free_pte_range (at minimum) and force flush the TLB under the
> > > PTL if a dirty PTE is encountered. The second is that it should consider
> > 
> > OTL: I couldn't read this lengthy discussion so I miss miss something.
> > 
> > About MADV_FREE, I do not understand why it should flush TLB in MADV_FREE
> > context. MADV_FREE's semantic allows "write(ie, dirty)" so if other thread
> > in parallel which has stale pte does "store" to make the pte dirty,
> > it's okay since try_to_unmap_one in shrink_page_list catches the dirty.
> > 
> 
> In try_to_unmap_one it's fine. It's not necessarily fine in KSM. Given
> that the key is that data corruption is avoided, you could argue with a
> comment that madv_free doesn't necesssarily have to flush it as long as
> KSM does even if it's clean due to batching.

Yes, I think it should be done in side where have a concern.
Maybe, mm_struct can carry a flag which indicates someone is
doing the TLB bacthing and then KSM side can flush it by the flag.
It would reduce unncessary flushing.

> 
> > In above example, I think KSM should flush the TLB, not MADV_FREE and
> > soft dirty page hander.
> > 
> 
> That would also be acceptable.
> 
> > > flushing the full affected range as madvise_free holds mmap_sem for
> > > read-only to avoid problems with two parallel madv_free operations. The
> > > second is optional because there are other ways it could also be handled
> > > that may have lower overhead.
> > 
> > Ditto. I cannot understand. Why does two parallel MADV_FREE have a problem?
> > 
> 
> Like madvise(), madv_free can potentially return with a stale PTE visible
> to the caller that observed a pte_none at the time of madv_free and uses
> a stale PTE that potentially allows a lost write. It's debatable whether

That is the part I cannot understand.
How does it lost "the write"? MADV_FREE doesn't discard the memory so
finally, the write should be done sometime.
Could you tell me more?

Thanks.

> this matters considering that madv_free to a region means that parallel
> writers can lose their update anyway. It's less of a concern than the
> KSM angle outlined in Nadav's example which he was able to artifically
> reproduce by slowing operations to increase the race window.
> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
