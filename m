Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEC06B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:30:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so158038744pgs.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:30:04 -0700 (PDT)
Received: from mail-pg0-f49.google.com (mail-pg0-f49.google.com. [74.125.83.49])
        by mx.google.com with ESMTPS id f1si4603967pge.536.2017.08.14.15.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 15:30:02 -0700 (PDT)
Received: by mail-pg0-f49.google.com with SMTP id y129so55704301pgy.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:30:02 -0700 (PDT)
Subject: Re: [PATCH v5 02/10] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-3-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <910adbb5-c5d7-3091-1c92-996f73dd6221@redhat.com>
Date: Mon, 14 Aug 2017 15:30:00 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-3-tycho@docker.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> +/* Update a single kernel page table entry */
> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> +{
> +	unsigned int level;
> +	pgprot_t msk_clr;
> +	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
> +
> +	BUG_ON(!pte);
> +
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
> +		break;
> +	case PG_LEVEL_2M:
> +		/* We need to check if it's a 2M page or 1GB page before retrieve
> +		 * pgprot info, as each one will be extracted from a different
> +		 * page table levels */
> +		msk_clr = pmd_pgprot(*(pmd_t*)pte);
> +	case PG_LEVEL_1G: {
> +		struct cpa_data cpa;
> +		int do_split;
> +
> +		msk_clr = pud_pgprot(*(pud_t*)pte);
> +
> +		memset(&cpa, 0, sizeof(cpa));
> +		cpa.vaddr = kaddr;
> +		cpa.pages = &page;
> +		cpa.mask_set = prot;
> +		cpa.mask_clr = msk_clr;
> +		cpa.numpages = 1;
> +		cpa.flags = 0;
> +		cpa.curpage = 0;
> +		cpa.force_split = 0;
> +
> +
> +		do_split = try_preserve_large_page(pte, (unsigned long)kaddr, &cpa);
> +		if (do_split) {
> +			spin_lock(&cpa_lock);
> +			BUG_ON(split_large_page(&cpa, pte, (unsigned long)kaddr));
> +			spin_unlock(&cpa_lock);
> +		}

This doesn't work in atomic contexts:

[   28.263571] BUG: sleeping function called from invalid context at 
mm/page_alloc.c:4048
[   28.263575] in_atomic(): 1, irqs_disabled(): 1, pid: 2433, name: 
gnome-terminal
[   28.263576] INFO: lockdep is turned off.
[   28.263578] irq event stamp: 0
[   28.263580] hardirqs last  enabled at (0): [<          (null)>] 
     (null)
[   28.263584] hardirqs last disabled at (0): [<ffffffff840af28a>] 
copy_process.part.25+0x62a/0x1e90
[   28.263587] softirqs last  enabled at (0): [<ffffffff840af28a>] 
copy_process.part.25+0x62a/0x1e90
[   28.263588] softirqs last disabled at (0): [<          (null)>] 
     (null)
[   28.263591] CPU: 0 PID: 2433 Comm: gnome-terminal Tainted: G        W 
       4.13.0-rc5-xpfo+ #86
[   28.263592] Hardware name: LENOVO 20BTS1N700/20BTS1N700, BIOS 
N14ET28W (1.06 ) 03/12/2015
[   28.263593] Call Trace:
[   28.263598]  dump_stack+0x8e/0xd6
[   28.263601]  ___might_sleep+0x164/0x250
[   28.263604]  __might_sleep+0x4a/0x80
[   28.263607]  __alloc_pages_nodemask+0x2b3/0x3e0
[   28.263611]  alloc_pages_current+0x6a/0xe0
[   28.263614]  split_large_page+0x4e/0x360
[   28.263618]  set_kpte+0x12c/0x150
[   28.263623]  xpfo_kunmap+0x7e/0xa0
[   28.263627]  wp_page_copy+0x16e/0x800
[   28.263631]  do_wp_page+0x9a/0x580
[   28.263633]  __handle_mm_fault+0xb1c/0x1130
[   28.263638]  handle_mm_fault+0x178/0x350
[   28.263641]  __do_page_fault+0x26e/0x510
[   28.263644]  do_page_fault+0x30/0x80
[   28.263647]  page_fault+0x28/0x30


split_large_page calls alloc_page with GFP_KERNEL. switching to
use GFP_ATOMIC in this path works locally for me.

Thanks,
Laura

> +
> +		break;
> +	}
> +	case PG_LEVEL_512G:
> +		/* fallthrough, splitting infrastructure doesn't
> +		 * support 512G pages. */
> +	default:
> +		BUG();
> +	}
> +
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
