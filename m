Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9CC96B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:59:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m75so1149086wmb.12
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:59:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si662830wmd.176.2017.07.19.15.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 15:59:52 -0700 (PDT)
Date: Wed, 19 Jul 2017 23:59:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170719225950.wfpfzpc6llwlyxdo@suse.de>
References: <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 19, 2017 at 03:19:00PM -0700, Nadav Amit wrote:
> >> Yes, of course, since KSM does not batch TLB flushes. I regarded the other
> >> direction - first try_to_unmap() removes the PTE (but still does not flush),
> >> unlocks the page, and then KSM acquires the page lock and calls
> >> write_protect_page(). It finds out the PTE is not present and does not flush
> >> the TLB.
> > 
> > When KSM acquires the page lock, it then acquires the PTL where the
> > cleared PTE is observed directly and skipped.
> 
> I don???t see why. Let???s try again - CPU0 reclaims while CPU1 deduplicates:
> 
> CPU0				CPU1
> ----				----
> shrink_page_list()
> 
> => try_to_unmap()
> ==> try_to_unmap_one()
> [ unmaps from some page-tables ]
> 
> [ try_to_unmap returns false;
>   page not reclaimed ]
> 
> => keep_locked: unlock_page()
> 
> [ TLB flush deferred ]
> 				try_to_merge_one_page()
> 				=> trylock_page()
> 				=> write_protect_page()
> 				==> acquire ptl
> 				  [ PTE non-present ???> no PTE change
> 				    and no flush ]
> 				==> release ptl
> 				==> replace_page()
> 
> 
> At this point, while replace_page() is running, CPU0 may still not have
> flushed the TLBs. Another CPU (CPU2) may hold a stale PTE, which is not
> write-protected. It can therefore write to that page while replace_page() is
> running, resulting in memory corruption.
> 
> No?
> 

KSM is not my strong point so it's reaching the point where others more
familiar with that code need to be involved.

If try_to_unmap returns false on CPU0 then at least one unmap attempt
failed and the page is not reclaimed. For those that were unmapped, they
will get flushed in the near future. When KSM operates on CPU1, it'll skip
the unmapped pages under the PTL so stale TLB entries are not relevant as
the mapped entries are still pointing to a valid page and ksm misses a merge
opportunity. If it write protects a page, ksm unconditionally flushes the PTE
on clearing the PTE so again, there is no stale entry anywhere. For CPU2,
it'll either reference a PTE that was unmapped in which case it'll fault
once CPU0 flushes the TLB and until then it's safe to read and write as
long as the TLB is flushed before the page is freed or IO is initiated which
reclaim already handles. If CPU2 references a page that was still mapped
then it'll be fine until KSM unmaps and flushes the page before going
further so any reference after KSM starts the critical operation will
trap a fault.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
