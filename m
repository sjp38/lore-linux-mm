Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3E806B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:58:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t80so51327251pgb.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:58:37 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id p62si6462315pfk.529.2017.08.15.21.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 21:58:37 -0700 (PDT)
Date: Tue, 15 Aug 2017 21:58:34 -0700 (PDT)
Message-Id: <20170815.215834.141971110430980112.davem@davemloft.net>
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
	<cover.1502219353.git.khalid.aziz@oracle.com>
	<3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Wed,  9 Aug 2017 15:26:02 -0600

> +void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct *vma,
> +		      unsigned long addr, pte_t pte)
> +{
 ...
> +	tag = tag_start(addr, tag_desc);
> +	paddr = pte_val(pte) & _PAGE_PADDR_4V;
> +	for (tmp = paddr; tmp < (paddr+PAGE_SIZE); tmp += adi_blksize()) {
> +		version1 = (*tag) >> 4;
> +		version2 = (*tag) & 0x0f;
> +		*tag++ = 0;
> +		asm volatile("stxa %0, [%1] %2\n\t"
> +			:
> +			: "r" (version1), "r" (tmp),
> +			  "i" (ASI_MCD_REAL));
> +		tmp += adi_blksize();
> +		asm volatile("stxa %0, [%1] %2\n\t"
> +			:
> +			: "r" (version2), "r" (tmp),
> +			  "i" (ASI_MCD_REAL));
> +	}
> +	asm volatile("membar #Sync\n\t");

You do a membar here.

> +		for (i = pfrom; i < (pfrom + PAGE_SIZE); i += adi_blksize()) {
> +			asm volatile("ldxa [%1] %2, %0\n\t"
> +					: "=r" (adi_tag)
> +					:  "r" (i), "i" (ASI_MCD_REAL));
> +			asm volatile("stxa %0, [%1] %2\n\t"
> +					:
> +					: "r" (adi_tag), "r" (pto),
> +					  "i" (ASI_MCD_REAL));

But not here.

Is this OK?  I suspect you need to add a membar this this second piece
of MCD tag storing code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
