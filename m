Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9126B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:49:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l3so27692434wrc.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:49:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b37si14879818wrb.338.2017.07.25.02.49.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 02:49:17 -0700 (PDT)
Date: Tue, 25 Jul 2017 10:49:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
Message-ID: <20170725094915.uldl43aazfbvdl7f@suse.de>
References: <20170717180246.62277-1-namit@vmware.com>
 <20170724165449.1a51b34d22ee4a9b54ce2652@linux-foundation.org>
 <1A44338A-C667-4D63-A93F-EBBF6C9226D2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1A44338A-C667-4D63-A93F-EBBF6C9226D2@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

On Mon, Jul 24, 2017 at 05:27:47PM -0700, Nadav Amit wrote:
> > Do we still need the barrier()s or is it OK to let the atomic op do
> > that for us (with a suitable code comment).
> 
> I will submit v2. However, I really don???t understand the comment on
> mm_tlb_flush_pending():
> 
> /*              
>  * Memory barriers to keep this state in sync are graciously provided by
>  * the page table locks, outside of which no page table modifications happen.
>  * The barriers below prevent the compiler from re-ordering the instructions
>  * around the memory barriers that are already present in the code.
>  */
> 
> But IIUC migrate_misplaced_transhuge_page() does not call
> mm_tlb_flush_pending() while the ptl is taken.
> 
> Mel, can I bother you again? Should I move the flush in
> migrate_misplaced_transhuge_page() till after the ptl is taken?
> 

The flush, if it's necessary, needs to happen before the copy. However,
in this particular context it shouldn't matter.  In this specific context,
we must be dealing with a NUMA hinting fault which means the original PTE
is PROT_NONE, flushed and no writes are possible.  If a protection update
happens during the copy in migrate_misplaced_transhuge_page then it'll
be detected in migrate_misplaced_transhuge_page by the pmd_same check and
the page copy was a waste of time but otherwise harmless.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
