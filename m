Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 885E36B0313
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:40:45 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 20so35638110qtq.2
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:40:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g68si1058969qkd.163.2017.06.16.06.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 06:40:44 -0700 (PDT)
Date: Fri, 16 Jun 2017 15:40:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv2 2/3] mm: Do not loose dirty and access bits in
 pmdp_invalidate()
Message-ID: <20170616134041.GF11676@redhat.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145224.66200-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 15, 2017 at 05:52:23PM +0300, Kirill A. Shutemov wrote:
> -void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  		     pmd_t *pmdp)
>  {
> -	pmd_t entry = *pmdp;
> -	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
> -	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	pmd_t old = pmdp_establish(pmdp, pmd_mknotpresent(*pmdp));
> +	if (pmd_present(old))
> +		flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	return old;
>  }
>  #endif

The pmd_present() check added above is superflous because there's no
point to call pmdp_invalidate if the pmd is not present (present as in
pmd_present) already. pmd_present returns true if _PAGE_PSE is set
and it was always set before calling pmdp_invalidate.

It looks like we could skip the flush if _PAGE_PRESENT is not set
(i.e. for example if the pmd is PROTNONE) but that's not what the above
pmd_present will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
