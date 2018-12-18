Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7948E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:21:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h11so15764665pfj.13
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 09:21:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o3si13531811pll.201.2018.12.18.09.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 09:21:21 -0800 (PST)
Date: Tue, 18 Dec 2018 09:21:00 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V3 3/5] arch/powerpc/mm: Nest MMU workaround for mprotect
 RW upgrade.
Message-ID: <20181218172100.GB22729@infradead.org>
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
 <20181205030931.12037-4-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205030931.12037-4-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, Dec 05, 2018 at 08:39:29AM +0530, Aneesh Kumar K.V wrote:
> +pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
> +			     pte_t *ptep)
> +{
> +	unsigned long pte_val;
> +
> +	/*
> +	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
> +	 * possible. Also keep the pte_present true so that we don't take
> +	 * wrong fault.
> +	 */
> +	pte_val = pte_update(vma->vm_mm, addr, ptep, _PAGE_PRESENT, _PAGE_INVALID, 0);
> +
> +	return __pte(pte_val);
> +
> +}
> +EXPORT_SYMBOL(ptep_modify_prot_start);

As far as I can tell this is only called from mm/memory.c, mm/mprotect.c
and fs/proc/task_mmu.c, so there should be no need to export the
function.
