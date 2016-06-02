Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB666B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 16:12:52 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id te7so15570306pab.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 13:12:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s20si562063paf.70.2016.06.02.13.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 13:12:51 -0700 (PDT)
Date: Thu, 2 Jun 2016 13:12:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] powerpc/mm/radix: Implement tlb mmu gather flush
 efficiently
Message-Id: <20160602131250.e4d43401e7eade277bc4476a@linux-foundation.org>
In-Reply-To: <1464860389-29019-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1464860389-29019-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu,  2 Jun 2016 15:09:49 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Now that we track page size in mmu_gather, we can use address based
> tlbie format when doing a tlb_flush(). We don't do this if we are
> invalidating the full address space.
> 
> ...
>
>  void radix__tlb_flush(struct mmu_gather *tlb)
>  {
> +	int psize = 0;
>  	struct mm_struct *mm = tlb->mm;
> -	radix__flush_tlb_mm(mm);
> +	int page_size = tlb->page_size;
> +
> +	psize = radix_get_mmu_psize(page_size);
> +	if (psize == -1)
> +		/* unknown page size */
> +		goto flush_mm;
> +
> +	if (!tlb->fullmm && !tlb->need_flush_all)
> +		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
> +	else
> +flush_mm:
> +		radix__flush_tlb_mm(mm);

That's kinda ugly.  What about

void radix__tlb_flush(struct mmu_gather *tlb)
{
	int psize = 0;
	struct mm_struct *mm = tlb->mm;
	int page_size = tlb->page_size;

	psize = radix_get_mmu_psize(page_size);

	if (psize != -1 && !tlb->fullmm && !tlb->need_flush_all)
		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
	else
		radix__flush_tlb_mm(mm);
}

?

We lost the comment, but that can be neatly addressed by documenting
radix_get_mmu_psize() (of course!).  Please send along a comment to do
this and I'll add it in.

--- a/arch/powerpc/mm/tlb-radix.c~powerpc-mm-radix-implement-tlb-mmu-gather-flush-efficiently-fix
+++ a/arch/powerpc/mm/tlb-radix.c
@@ -265,13 +265,9 @@ void radix__tlb_flush(struct mmu_gather
 	int page_size = tlb->page_size;
 
 	psize = radix_get_mmu_psize(page_size);
-	if (psize == -1)
-		/* unknown page size */
-		goto flush_mm;
 
-	if (!tlb->fullmm && !tlb->need_flush_all)
+	if (psize != -1 && !tlb->fullmm && !tlb->need_flush_all)
 		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
 	else
-flush_mm:
 		radix__flush_tlb_mm(mm);
 }
_

I'll await feedback from the other PPC developers before doing anything
further on this patchset.

hm, no ppc mailing lists were cc'ed.  Regrettable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
