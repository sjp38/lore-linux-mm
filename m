Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4A506B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:53:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so50388853pgb.14
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:53:29 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id r63si6404465pfg.653.2017.08.15.21.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 21:53:28 -0700 (PDT)
Date: Tue, 15 Aug 2017 21:53:26 -0700 (PDT)
Message-Id: <20170815.215326.1833101229202321710.davem@davemloft.net>
Subject: Re: [PATCH v7 2/9] mm, swap: Add infrastructure for saving page
 metadata on swap
From: David Miller <davem@davemloft.net>
In-Reply-To: <87ff7a44c45bd6a146102c6e6033ee7810d9ebb5.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
	<cover.1502219353.git.khalid.aziz@oracle.com>
	<87ff7a44c45bd6a146102c6e6033ee7810d9ebb5.1502219353.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, kirill.shutemov@linux.intel.com, mhocko@suse.com, jack@suse.cz, ross.zwisler@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, dave.jiang@intel.com, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, shli@fb.com, mingo@kernel.org, jmarchan@redhat.com, lstoakes@gmail.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Wed,  9 Aug 2017 15:25:55 -0600

> @@ -1399,6 +1399,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				(flags & TTU_MIGRATION)) {
>  			swp_entry_t entry;
>  			pte_t swp_pte;
> +
> +			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
> +				set_pte_at(mm, address, pvmw.pte, pteval);
> +				ret = false;
> +				page_vma_mapped_walk_done(&pvmw);
> +				break;
>  			/*
>  			 * Store the pfn of the page in a special migration
>  			 * pte. do_swap_page() will wait until the migration
> @@ -1410,6 +1416,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> +			}

This basic block doesn't look right.  I think the new closing brace is
intended to be right after the new break; statement.  If not at the
very least the indentation of the existing code in there needs to be
adjusted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
