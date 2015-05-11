Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 418626B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 03:46:50 -0400 (EDT)
Received: by wiun10 with SMTP id n10so85960973wiu.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 00:46:49 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id bz5si10836224wib.38.2015.05.11.00.46.48
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 00:46:48 -0700 (PDT)
Date: Mon, 11 May 2015 10:46:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V3] powerpc/thp: Serialize pmd clear against a linux page
 table walk.
Message-ID: <20150511074631.GA10974@node.dhcp.inet.fi>
References: <1431325561-21396-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431325561-21396-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 11:56:01AM +0530, Aneesh Kumar K.V wrote:
> Serialize against find_linux_pte_or_hugepte which does lock-less
> lookup in page tables with local interrupts disabled. For huge pages
> it casts pmd_t to pte_t. Since format of pte_t is different from
> pmd_t we want to prevent transit from pmd pointing to page table
> to pmd pointing to huge page (and back) while interrupts are disabled.
> We clear pmd to possibly replace it with page table pointer in
> different code paths. So make sure we wait for the parallel
> find_linux_pte_or_hugepage to finish.
> 
> Without this patch, a find_linux_pte_or_hugepte running in parallel to
> __split_huge_zero_page_pmd or do_huge_pmd_wp_page_fallback or zap_huge_pmd
> can run into the above issue. With __split_huge_zero_page_pmd and
> do_huge_pmd_wp_page_fallback we clear the hugepage pte before inserting
> the pmd entry with a regular pgtable address. Such a clear need to
> wait for the parallel find_linux_pte_or_hugepte to finish.
> 
> With zap_huge_pmd, we can run into issues, with a hugepage pte
> getting zapped due to a MADV_DONTNEED while other cpu fault it
> in as small pages.
> 
> Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

CC: stable@ ?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
