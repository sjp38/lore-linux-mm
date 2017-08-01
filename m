Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 746126B0573
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 15:33:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so12204759qki.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 12:33:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r64si28489426qkr.100.2017.08.01.12.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 12:33:44 -0700 (PDT)
Date: Tue, 1 Aug 2017 21:33:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 4/4] mm: fix KSM data corruption
Message-ID: <20170801193341.GA24406@redhat.com>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-5-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501566977-20293-5-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>

Hello,

On Tue, Aug 01, 2017 at 02:56:17PM +0900, Minchan Kim wrote:
> CPU0		CPU1		CPU2		CPU3
> ----		----		----		----
> Write the same
> value on page
> 
> [cache PTE as
>  dirty in TLB]
> 
> 		MADV_FREE
> 		pte_mkclean()
> 
> 				4 > clear_refs
> 				pte_wrprotect()
> 
> 						write_protect_page()
> 						[ success, no flush ]
> 
> 						pages_indentical()
> 						[ ok ]
> 
> Write to page
> different value
> 
> [Ok, using stale
>  PTE]
> 
> 						replace_page()
> 
> Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. CPU0
> already wrote on the page, but KSM ignored this write, and it got lost.
> "
> 
> In above scenario, MADV_FREE is fixed by changing TLB batching API
> including [set|clear]_tlb_flush_pending. Remained thing is soft-dirty part.
> 
> This patch changes soft-dirty uses TLB batching API instead of flush_tlb_mm
> and KSM checks pending TLB flush by using mm_tlb_flush_pending so that
> it will flush TLB to avoid data lost if there are other parallel threads
> pending TLB flush.
> 
> [1] http://lkml.kernel.org/r/BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com
> 
> Note:
> I failed to reproduce this problem through Nadav's test program which
> need to tune timing in my system speed so didn't confirm it work.
> Nadav, Could you test this patch on your test machine?

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
