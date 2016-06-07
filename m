Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 453E46B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 04:43:48 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so4566465pac.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 01:43:48 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id fe10si32034399pab.47.2016.06.07.01.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 01:36:29 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id fg1so13708885pad.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 01:36:23 -0700 (PDT)
Subject: Re: [PATCH 2/2] powerpc/mm: check for irq disabled() only if DEBUG_VM
 is enabled.
References: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1464692688-6612-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <3eb96c44-98fa-cc51-276c-727d0241c849@gmail.com>
Date: Tue, 7 Jun 2016 18:36:17 +1000
MIME-Version: 1.0
In-Reply-To: <1464692688-6612-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 31/05/16 21:04, Aneesh Kumar K.V wrote:
> We don't need to check this always. The idea here is to capture the
> wrong usage of find_linux_pte_or_hugepte and we can do that by
> occasionally running with DEBUG_VM enabled.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable.h | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
> index ee09e99097f0..9bd87f269d6d 100644
> --- a/arch/powerpc/include/asm/pgtable.h
> +++ b/arch/powerpc/include/asm/pgtable.h
> @@ -71,10 +71,8 @@ pte_t *__find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
>  static inline pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
>  					       bool *is_thp, unsigned *shift)
>  {
> -	if (!arch_irqs_disabled()) {
> -		pr_info("%s called with irq enabled\n", __func__);
> -		dump_stack();
> -	}
> +	VM_WARN(!arch_irqs_disabled(),
> +		"%s called with irq enabled\n", __func__);
>  	return __find_linux_pte_or_hugepte(pgdir, ea, is_thp, shift);
>  }

Agreed! Honestly, I think it should be a VM_BUG_ON() since we have a large reliance
on this elsewhere in the code.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
