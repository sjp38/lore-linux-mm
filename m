Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BADAD6B0497
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 21:09:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so9477619pgr.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 18:09:30 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id g11si3389449plm.262.2017.08.29.18.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 18:09:29 -0700 (PDT)
Date: Tue, 29 Aug 2017 18:09:28 -0700 (PDT)
Message-Id: <20170829.180928.896986367806428362.davem@davemloft.net>
Subject: Re: [PATCH v7 02/11] sparc64/mm: setting fields in deferred pages
From: David Miller <davem@davemloft.net>
In-Reply-To: <1503972142-289376-3-git-send-email-pasha.tatashin@oracle.com>
References: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
	<1503972142-289376-3-git-send-email-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 28 Aug 2017 22:02:13 -0400

> Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
> flags and other fields in "struct page"es are never changed prior to first
> initializing struct pages by going through __init_single_page().
> 
> With deferred struct page feature enabled there is a case where we set some
> fields prior to initializing:
> 
> mem_init() {
>      register_page_bootmem_info();
>      free_all_bootmem();
>      ...
> }
> 
> When register_page_bootmem_info() is called only non-deferred struct pages
> are initialized. But, this function goes through some reserved pages which
> might be part of the deferred, and thus are not yet initialized.
> 
> mem_init
> register_page_bootmem_info
> register_page_bootmem_info_node
>  get_page_bootmem
>   .. setting fields here ..
>   such as: page->freelist = (void *)type;
> 
> free_all_bootmem()
> free_low_memory_core_early()
>  for_each_reserved_mem_region()
>   reserve_bootmem_region()
>    init_reserved_page() <- Only if this is deferred reserved page
>     __init_single_pfn()
>      __init_single_page()
>       memset(0) <-- Loose the set fields here
> 
> We end-up with similar issue as in the previous patch, where currently we
> do not observe problem as memory is zeroed. But, if flag asserts are
> changed we can start hitting issues.
> 
> Also, because in this patch series we will stop zeroing struct page memory
> during allocation, we must make sure that struct pages are properly
> initialized prior to using them.
> 
> The deferred-reserved pages are initialized in free_all_bootmem().
> Therefore, the fix is to switch the above calls.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
