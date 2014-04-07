Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 112C16B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:58:41 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so7256917pbb.29
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:58:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ic8si8856327pad.259.2014.04.07.12.58.38
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 12:58:39 -0700 (PDT)
Message-ID: <5342E273.4070308@intel.com>
Date: Mon, 07 Apr 2014 10:37:55 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <1396883443-11696-1-git-send-email-mgorman@suse.de> <1396883443-11696-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1396883443-11696-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 04/07/2014 08:10 AM, Mel Gorman wrote:
> +/*
> + * Software bits ignored by the page table walker
> + * At the time of writing, different levels have bits that are ignored. Due
> + * to physical address limitations, bits 52:62 should be ignored for the PMD
> + * and PTE levels and are available for use by software. Be aware that this
> + * may change if the physical address space expands.
> + */
> +#define _PAGE_BIT_NUMA		62

Doesn't moving it up to the high bits break pte_modify()'s assumptions?
 I was thinking of this nugget from change_pte_range():

	ptent = ptep_modify_prot_start(mm, addr, pte);
        if (pte_numa(ptent))
        	ptent = pte_mknonnuma(ptent);
	ptent = pte_modify(ptent, newprot);

pte_modify() pulls off all the high bits out of 'ptent' and only adds
them back if they're in newprot (which as far as I can tell comes from
the VMA).  So I _think_ it'll axe the _PAGE_NUMA out of 'ptent'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
