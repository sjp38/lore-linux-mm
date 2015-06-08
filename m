Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id D01AD6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 13:45:57 -0400 (EDT)
Received: by labko7 with SMTP id ko7so102599384lab.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:45:57 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id ck8si2687061wib.55.2015.06.08.10.45.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 10:45:56 -0700 (PDT)
Received: by wigg3 with SMTP id g3so60443489wig.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:45:55 -0700 (PDT)
Date: Mon, 8 Jun 2015 19:45:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150608174551.GA27558@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433767854-24408-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> Changelog since V4
> o Rebase to 4.1-rc6
> 
> Changelog since V3
> o Drop batching of TLB flush from migration
> o Redo how larger batching is managed
> o Batch TLB flushes when writable entries exist
> 
> When unmapping pages it is necessary to flush the TLB. If that page was
> accessed by another CPU then an IPI is used to flush the remote CPU. That
> is a lot of IPIs if kswapd is scanning and unmapping >100K pages per second.
> 
> There already is a window between when a page is unmapped and when it is
> TLB flushed. This series simply increases the window so multiple pages
> can be flushed using a single IPI. This *should* be safe or the kernel is
> hosed already but I've cc'd the x86 maintainers and some of the Intel folk
> for comment.
> 
> Patch 1 simply made the rest of the series easier to write as ftrace
> 	could identify all the senders of TLB flush IPIS.
> 
> Patch 2 collects a list of PFNs and sends one IPI to flush them all
> 
> Patch 3 tracks when there potentially are writable TLB entries that
> 	need to be batched differently
> 
> The performance impact is documented in the changelogs but in the optimistic
> case on a 4-socket machine the full series reduces interrupts from 900K
> interrupts/second to 60K interrupts/second.

Yeah, so I think batching writable flushes is useful I think, but I disagree with 
one aspect of it: with the need to gather _pfns_ and batch them over to the remote 
CPU.

As per my measurements the __flush_tlb_single() primitive (which you use in patch
#2) is very expensive on most Intel and AMD CPUs. It barely makes sense for a 2
pages and gets exponentially worse. It's probably done in microcode and its 
performance is horrible.

So have you explored the possibility to significantly simplify your patch-set by 
only deferring the flushing, and doing a simple TLB flush on the remote CPU? As 
per your measurements there must be tons and tons of flushes of lots of pages, the 
pfn tracking simply does not make sense.

That way there's no memory overhead and no complex tracking of pfns - we'd 
basically track a simple deferred-flush bit instead. We'd still have the benefits 
of batching the IPIs, which is the main win.

I strongly suspect that your numbers will become even better with such a variant.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
