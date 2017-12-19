Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE7306B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:05:46 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id a3so2566317itg.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:05:46 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0102.hostedemail.com. [216.40.44.102])
        by mx.google.com with ESMTPS id f32si2951110ioi.249.2017.12.19.09.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 09:05:46 -0800 (PST)
Message-ID: <1513703142.1234.53.camel@perches.com>
Subject: Re: [PATCH 1/2] mm: Make follow_pte_pmd an inline
From: Joe Perches <joe@perches.com>
Date: Tue, 19 Dec 2017 09:05:42 -0800
In-Reply-To: <20171219165823.24243-1-willy@infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>

On Tue, 2017-12-19 at 08:58 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The one user of follow_pte_pmd (dax) emits a sparse warning because
> it doesn't know that follow_pte_pmd conditionally returns with the
> pte/pmd locked.  The required annotation is already there; it's just
> in the wrong file.
[]
> diff --git a/include/linux/mm.h b/include/linux/mm.h
[]
> @@ -1324,6 +1324,19 @@ int follow_phys(struct vm_area_struct *vma, unsigned long address,
>  int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
>  			void *buf, int len, int write);
>  
> +static inline int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
> +			     unsigned long *start, unsigned long *end,
> +			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
> +{
> +	int res;
> +
> +	/* (void) is needed to make gcc happy */
> +	(void) __cond_lock(*ptlp,
> +			   !(res = __follow_pte_pmd(mm, address, start, end,
> +						    ptepp, pmdpp, ptlp)));

This seems obscure and difficult to read.  Perhaps:

	res = __follow_pte_pmd(mm, address, start, end, ptepp, pmdpp, ptlp);
	(void)__cond_lock(*ptlp, !res);

> +	return res;
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
