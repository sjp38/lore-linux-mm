Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 776AD6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:21:33 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id 19so1085320ykq.25
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:21:32 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id c8si3298241yha.147.2014.04.08.10.21.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 10:21:31 -0700 (PDT)
Message-ID: <53443018.2090408@citrix.com>
Date: Tue, 8 Apr 2014 18:21:28 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: use paravirt friendly ops for NUMA hinting ptes
References: <1396962570-18762-1-git-send-email-mgorman@suse.de> <1396962570-18762-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-X86 <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/04/14 14:09, Mel Gorman wrote:
> David Vrabel identified a regression when using automatic NUMA balancing
> under Xen whereby page table entries were getting corrupted due to the
> use of native PTE operations. Quoting him
> 
> 	Xen PV guest page tables require that their entries use machine
> 	addresses if the preset bit (_PAGE_PRESENT) is set, and (for
> 	successful migration) non-present PTEs must use pseudo-physical
> 	addresses.  This is because on migration MFNs in present PTEs are
> 	translated to PFNs (canonicalised) so they may be translated back
> 	to the new MFN in the destination domain (uncanonicalised).
> 
> 	pte_mknonnuma(), pmd_mknonnuma(), pte_mknuma() and pmd_mknuma()
> 	set and clear the _PAGE_PRESENT bit using pte_set_flags(),
> 	pte_clear_flags(), etc.
> 
> 	In a Xen PV guest, these functions must translate MFNs to PFNs
> 	when clearing _PAGE_PRESENT and translate PFNs to MFNs when setting
> 	_PAGE_PRESENT.
> 
> His suggested fix converted p[te|md]_[set|clear]_flags to using
> paravirt-friendly ops but this is overkill. He suggested an alternative of
> using p[te|md]_modify in the NUMA page table operations but this is does
> more work than necessary and would require looking up a VMA for protections.
> 
> This patch modifies the NUMA page table operations to use paravirt friendly
> operations to set/clear the flags of interest. Unfortunately this will take
> a performance hit when updating the PTEs on CONFIG_PARAVIRT but I do not
> see a way around it that does not break Xen.

Acked-by: David Vrabel <david.vrabel@citrix.com>

It passed my mprotect() PROT_NONE -> PROT_READ test case so

Tested-by: David Vrabel <david.vrabel@citrix.com>

I'll leave it up to the x86 maintainers to decide which fix to take.
This one or the more generic "x86: use pv-ops in
{pte,pmd}_{set,clear}_flags()"

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
