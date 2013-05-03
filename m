Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id CD8376B02D3
	for <linux-mm@kvack.org>; Fri,  3 May 2013 07:36:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 3 May 2013 17:01:14 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 35E86E0053
	for <linux-mm@kvack.org>; Fri,  3 May 2013 17:08:42 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43BaNXr9109970
	for <linux-mm@kvack.org>; Fri, 3 May 2013 17:06:23 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43BaQaX001433
	for <linux-mm@kvack.org>; Fri, 3 May 2013 21:36:27 +1000
Message-ID: <5183A137.4060808@linux.vnet.ibm.com>
Date: Fri, 03 May 2013 19:36:23 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: soft-dirty bits for user memory changes tracking
References: <517FED13.8090806@parallels.com> <517FED64.4020400@parallels.com>
In-Reply-To: <517FED64.4020400@parallels.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 05/01/2013 12:12 AM, Pavel Emelyanov wrote:

> +static inline void clear_soft_dirty(struct vm_area_struct *vma,
> +		unsigned long addr, pte_t *pte)
> +{
> +#ifdef CONFIG_MEM_SOFT_DIRTY
> +	/*
> +	 * The soft-dirty tracker uses #PF-s to catch writes
> +	 * to pages, so write-protect the pte as well. See the
> +	 * Documentation/vm/soft-dirty.txt for full description
> +	 * of how soft-dirty works.
> +	 */
> +	pte_t ptent = *pte;
> +	ptent = pte_wrprotect(ptent);
> +	ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
> +	set_pte_at(vma->vm_mm, addr, pte, ptent);
> +#endif

It seems that TLBs are not flushed and mmu-notification is not called?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
