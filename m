Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A42E96B026B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:10:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f9-v6so14764209pfn.22
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 02:10:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d7-v6si17859732pgc.445.2018.07.11.02.10.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 02:10:27 -0700 (PDT)
Date: Wed, 11 Jul 2018 11:10:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 14/27] mm: Handle THP/HugeTLB shadow stack page
 fault
Message-ID: <20180711091022.GT2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-15-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710222639.8241-15-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 03:26:26PM -0700, Yu-cheng Yu wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index a2695dbc0418..f7c46d61eaea 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4108,7 +4108,13 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
>  				return do_huge_pmd_numa_page(&vmf, orig_pmd);
>  
> -			if (dirty && !pmd_write(orig_pmd)) {
> +			/*
> +			 * Shadow stack trans huge PMDs are copy-on-access,
> +			 * so wp_huge_pmd() on them no mater if we have a
> +			 * write fault or not.
> +			 */
> +			if (is_shstk_mapping(vma->vm_flags) ||
> +			    (dirty && !pmd_write(orig_pmd))) {
>  				ret = wp_huge_pmd(&vmf, orig_pmd);
>  				if (!(ret & VM_FAULT_FALLBACK))
>  					return ret;

Can't we do this (and the do_wp_page thing) by setting FAULT_FLAG_WRITE
in the arch fault handler on shadow stack faults?
