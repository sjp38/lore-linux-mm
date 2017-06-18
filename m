Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4106C6B02F3
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 02:26:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a82so74964827pfc.8
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 23:26:54 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id g2si6373757pln.576.2017.06.17.23.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 23:26:53 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id e187so2927904pgc.3
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 23:26:52 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <35264bd304c93f6d3cfff2329e3e01b084598ea1.1497415951.git.luto@kernel.org>
Date: Sat, 17 Jun 2017 23:26:48 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <740B1D51-B801-48C9-A4C9-F31B34A09AEF@gmail.com>
References: <cover.1497415951.git.luto@kernel.org>
 <cover.1497415951.git.luto@kernel.org>
 <35264bd304c93f6d3cfff2329e3e01b084598ea1.1497415951.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


> On Jun 13, 2017, at 9:56 PM, Andy Lutomirski <luto@kernel.org> wrote:
> 
> PCID is a "process context ID" -- it's what other architectures call
> an address space ID.  Every non-global TLB entry is tagged with a
> PCID, only TLB entries that match the currently selected PCID are
> used, and we can switch PGDs without flushing the TLB.  x86's
> PCID is 12 bits.
> 
> This is an unorthodox approach to using PCID.  x86's PCID is far too
> short to uniquely identify a process, and we can't even really
> uniquely identify a running process because there are monster
> systems with over 4096 CPUs.  To make matters worse, past attempts
> to use all 12 PCID bits have resulted in slowdowns instead of
> speedups.
> 
> This patch uses PCID differently.  We use a PCID to identify a
> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
> binding at all; instead, we give it a fresh PCID each time it's
> loaded except in cases where we want to preserve the TLB, in which
> case we reuse a recent value.
> 
> In particular, we use PCIDs 1-3 for recently-used mms and we reserve
> PCID 0 for swapper_pg_dir and for PCID-unaware CR3 users (e.g. EFI).
> Nothing ever switches to PCID 0 without flushing PCID 0 non-global
> pages, so PCID 0 conflicts won't cause problems.

Is this commit message outdated? NR_DYNAMIC_ASIDS is set to 6.
More importantly, I do not see PCID 0 as reserved:

> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
> +			    u16 *new_asid, bool *need_flush)
> +{
> 

[snip]

> +	if (*new_asid >= NR_DYNAMIC_ASIDS) {
> +		*new_asid = 0;
> +		this_cpu_write(cpu_tlbstate.next_asid, 1);
> +	}
> +	*need_flush = true;
> +}


Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
