Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id k07CPag7051492
	for <linux-mm@kvack.org>; Sat, 7 Jan 2006 12:25:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k07CPZCO232014
	for <linux-mm@kvack.org>; Sat, 7 Jan 2006 13:25:35 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k07CPZeL005602
	for <linux-mm@kvack.org>; Sat, 7 Jan 2006 13:25:35 +0100
Date: Sat, 7 Jan 2006 13:25:34 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <20060107122534.GA20442@osiris.boeblingen.de.ibm.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Here's a new version of my shared page tables patch.
> 
> The primary purpose of sharing page tables is improved performance for
> large applications that share big memory areas between multiple processes.
> It eliminates the redundant page tables and significantly reduces the
> number of minor page faults.  Tests show significant performance
> improvement for large database applications, including those using large
> pages.  There is no measurable performance degradation for small processes.

Tried to get this running with CONFIG_PTSHARE and CONFIG_PTSHARE_PTE on
s390x. Unfortunately it crashed on boot, because pt_share_pte
returned a broken pte pointer:

> +pte_t *pt_share_pte(struct vm_area_struct *vma, unsigned long address, pmd_t *pmd,
> + ...
> +	pmd_val(spmde) = 0;
> + ...
> +		if (pmd_present(spmde)) {

This is wrong. A pmd_val of 0 will make pmd_present return true on s390x
which is not what you want.
Should be pmd_clear(&spmde).

> +pmd_t *pt_share_pmd(struct vm_area_struct *vma, unsigned long address, pud_t *pud,
> + ...
> +	pud_val(spude) = 0;

Should be pud_clear, I guess :)

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
