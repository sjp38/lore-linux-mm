Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D93D26B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:50:15 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so20751993wmp.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 02:50:15 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 5si29639042wmq.67.2016.02.10.02.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 02:50:14 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id g62so20992851wme.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 02:50:14 -0800 (PST)
Date: Wed, 10 Feb 2016 12:50:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm,thp: khugepaged: call pte flush at the time of
 collapse
Message-ID: <20160210105012.GA23604@node.shutemov.name>
References: <1455080175-10987-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455080175-10987-1-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 10, 2016 at 10:26:15AM +0530, Vineet Gupta wrote:
> This showed up on ARC when running LMBench bw_mem tests as
> Overlapping TLB Machine Check Exception triggered due to STLB entry
> (2M pages) overlapping some NTLB entry (regular 8K page).
> 
> bw_mem 2m touches a large chunk of vaddr creating NTLB entries.
> In the interim khugepaged kicks in, collapsing the contiguous ptes into
> a single pmd. pmdp_collapse_flush()->flush_pmd_tlb_range() is called to
> flush out NTLB entries for the ptes. This for ARC (by design) can only
> shootdown STLB entries (for pmd). The stray NTLB entries cause the overlap
> with the subsequent STLB entry for collapsed page.
> So make pmdp_collapse_flush() call pte flush interface not pmd flush.
> 
> Note that originally all thp flush call sites in generic code called
> flush_tlb_range() leaving it to architecture to implement the flush for
> pte and/or pmd. Commit 12ebc1581ad11454 changed this by calling a new
> opt-in API flush_pmd_tlb_range() which made the semantics more explicit
> but failed to distinguish the pte vs pmd flush in generic code, which is
> what this patch fixes.
> 
> Note that ARC can fixed w/o touching the generic pmdp_collapse_flush()
> by defining a ARC version, but that defeats the purpose of generic
> version, plus sementically this is the right thing to do.
> 
> Fixes STAR 9000961194: LMBench on AXS103 triggering duplicate TLB
> exceptions with super pages
> 
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org> #4.4
> Cc: <linux-snps-arc@lists.infradead.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Fixes: 12ebc1581ad11454 ("mm,thp: introduce flush_pmd_tlb_range")
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
