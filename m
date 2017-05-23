Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50D5C6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 09:20:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r203so29851780wmb.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:20:18 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 45si16936539wrz.309.2017.05.23.06.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 06:20:16 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id b84so23520547wmh.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:20:16 -0700 (PDT)
Date: Tue, 23 May 2017 16:13:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 2/6] mm, gup: Ensure real head page is ref-counted
 when using hugepages
Message-ID: <20170523131312.aim6obne2t5sxtdr@node.shutemov.name>
References: <20170522133604.11392-1-punit.agrawal@arm.com>
 <20170522133604.11392-3-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522133604.11392-3-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, hillf.zj@alibaba-inc.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Michal Hocko <mhocko@suse.com>

On Mon, May 22, 2017 at 02:36:00PM +0100, Punit Agrawal wrote:
> When speculatively taking references to a hugepage using
> page_cache_add_speculative() in gup_huge_pmd(), it is assumed that the
> page returned by pmd_page() is the head page. Although normally true,
> this assumption doesn't hold when the hugepage comprises of successive
> page table entries such as when using contiguous bit on arm64 at PTE or
> PMD levels.
> 
> This can be addressed by ensuring that the page passed to
> page_cache_add_speculative() is the real head or by de-referencing the
> head page within the function.
> 
> We take the first approach to keep the usage pattern aligned with
> page_cache_get_speculative() where users already pass the appropriate
> page, i.e., the de-referenced head.
> 
> Apply the same logic to fix gup_huge_[pud|pgd]() as well.

Hm. Okay. But I'm kinda surprise that this is the only place that need to
be adjusted.

Have you validated all other pmd_page() use-cases?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
