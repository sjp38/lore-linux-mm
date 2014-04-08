Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5BB6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 14:16:10 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id mz13so985527bkb.31
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 11:16:09 -0700 (PDT)
Received: from mail-bk0-x22c.google.com (mail-bk0-x22c.google.com [2a00:1450:4008:c01::22c])
        by mx.google.com with ESMTPS id dz3si1486351bkc.156.2014.04.08.11.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 11:16:08 -0700 (PDT)
Received: by mail-bk0-f44.google.com with SMTP id mz13so992859bkb.3
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 11:16:08 -0700 (PDT)
Date: Tue, 8 Apr 2014 22:16:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
Message-ID: <20140408181606.GL23983@moon>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
 <53440A5D.6050301@zytor.com>
 <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
 <20140408164652.GL7292@suse.de>
 <20140408173031.GS10526@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408173031.GS10526@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Apr 08, 2014 at 07:30:31PM +0200, Peter Zijlstra wrote:
> On Tue, Apr 08, 2014 at 05:46:52PM +0100, Mel Gorman wrote:
> > Someone will ask why automatic NUMA balancing hints do not use "real"
> > PROT_NONE but as it would need VMA information to do that on all
> > architectures it would mean that VMA-fixups would be required when marking
> > PTEs for NUMA hinting faults so would be expensive.
> 
> Like this:
> 
>   https://lkml.org/lkml/2012/11/13/431
> 
> That used the generic PROT_NONE infrastructure and compared, on fault,
> the page protection bits against the vma->vm_page_prot bits?
> 
> So the objection to that approach was the vma-> dereference in
> pte_numa() ?

Peter, I somehow missing, with this patch would it be possible to
get rid of ugly macros in 2 level pages like we have now? (I've
dropped off softdirty support for non x86-64 now [patches are
flying around]) but still there are a few remains which make
Linus unhappy.

static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
{
	return (pgoff_t)
		(pte_bitop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		    +
		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT3,           -1UL,  PTE_FILE_LSHIFT3));
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
