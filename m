Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 828556B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 03:43:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so3591794wrb.13
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 00:43:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 52si1702326wrx.410.2017.07.20.00.43.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 00:43:44 -0700 (PDT)
Date: Thu, 20 Jul 2017 08:43:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170720074342.otez35bme5gytnxl@suse.de>
References: <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 19, 2017 at 04:39:07PM -0700, Nadav Amit wrote:
> > If try_to_unmap returns false on CPU0 then at least one unmap attempt
> > failed and the page is not reclaimed.
> 
> Actually, try_to_unmap() may even return true, and the page would still not
> be reclaimed - for example if page_has_private() and freeing the buffers
> fails. In this case, the page would be unlocked as well.
> 

I'm not seeing the relevance from the perspective of a stale TLB being
used to corrupt memory or access the wrong data.

> > For those that were unmapped, they
> > will get flushed in the near future. When KSM operates on CPU1, it'll skip
> > the unmapped pages under the PTL so stale TLB entries are not relevant as
> > the mapped entries are still pointing to a valid page and ksm misses a merge
> > opportunity.
> 
> This is the case I regarded, but I do not understand your point. The whole
> problem is that CPU1 would skip the unmapped pages under the PTL. As it
> skips them it does not flush them from the TLB. And as a result,
> replace_page() may happen before the TLB is flushed by CPU0.
> 

At the time of the unlock_page on the reclaim side, any unmapping that
will happen before the flush has taken place. If KSM starts between the
unlock_page and the tlb flush then it'll skip any of the PTEs that were
previously unmapped with stale entries so there is no relevant stale TLB
entry to work with.

> > If it write protects a page, ksm unconditionally flushes the PTE
> > on clearing the PTE so again, there is no stale entry anywhere. For CPU2,
> > it'll either reference a PTE that was unmapped in which case it'll fault
> > once CPU0 flushes the TLB and until then it's safe to read and write as
> > long as the TLB is flushed before the page is freed or IO is initiated which
> > reclaim already handles.
> 
> In my scenario the page is not freed and there is no I/O in the reclaim
> path. The TLB flush of CPU0 in my scenario is just deferred while the
> page-table lock is not held. As I mentioned before, this time-period can be
> potentially very long in a virtual machine. CPU2 referenced a PTE that
> was unmapped by CPU0 (reclaim path) but not CPU1 (ksm path).
> 
> ksm, IIUC, would not expect modifications of the page during replace_page.

Indeed not but it'll either find not PTE in which case it won't allow a
stale PTE entry to exist and even when it finds a PTE, it flushes the
TLB unconditionally to avoid any writes taking place. It holds the page
lock while setting up the sharing so no parallel fault can reinsert the
page and no parallel writes can take place that would result in false
sharing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
