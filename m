Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 214606B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 11:59:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a22-v6so5920907eds.13
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 08:59:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22-v6si3440207edr.193.2018.07.02.08.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 08:59:00 -0700 (PDT)
Date: Mon, 2 Jul 2018 17:58:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: teach dump_page() to correctly output poisoned
 struct pages
Message-ID: <20180702155858.GE19043@dhcp22.suse.cz>
References: <20180702152745.27596-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702152745.27596-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, gregkh@linuxfoundation.org

On Mon 02-07-18 11:27:45, Pavel Tatashin wrote:
> If struct page is poisoned, and uninitialized access is detected via
> PF_POISONED_CHECK(page) dump_page() is called to output the page. But,
> the dump_page() itself accesses struct page to determine how to print
> it, and therefore gets into a recursive loop.
> 
> For example:
> dump_page()
>  __dump_page()
>   PageSlab(page)
>    PF_POISONED_CHECK(page)
>     VM_BUG_ON_PGFLAGS(PagePoisoned(page), page)
>      dump_page() recursion loop.

This deserves a big fat comment in __dump_page. Basically no Page$FOO
can be used on an HWPoison page.
 
> Fixes: f165b378bbdf ("mm: uninitialized struct page poisoning sanity checking")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/debug.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 56e2d9125ea5..469b526e6abc 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -43,12 +43,20 @@ const struct trace_print_flags vmaflag_names[] = {
>  
>  void __dump_page(struct page *page, const char *reason)
>  {
> +	bool page_poisoned = PagePoisoned(page);
> +	int mapcount;
> +
> +	if (page_poisoned) {
> +		pr_emerg("page:%px is uninitialized and poisoned", page);
> +		goto hex_only;
> +	}
> +
>  	/*
>  	 * Avoid VM_BUG_ON() in page_mapcount().
>  	 * page->_mapcount space in struct page is used by sl[aou]b pages to
>  	 * encode own info.
>  	 */
> -	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
> +	mapcount = PageSlab(page) ? 0 : page_mapcount(page);
>  
>  	pr_emerg("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
>  		  page, page_ref_count(page), mapcount,
> @@ -60,6 +68,7 @@ void __dump_page(struct page *page, const char *reason)
>  
>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>  
> +hex_only:
>  	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE, 32,
>  			sizeof(unsigned long), page,
>  			sizeof(struct page), false);
> @@ -68,7 +77,7 @@ void __dump_page(struct page *page, const char *reason)
>  		pr_alert("page dumped because: %s\n", reason);
>  
>  #ifdef CONFIG_MEMCG
> -	if (page->mem_cgroup)
> +	if (!page_poisoned && page->mem_cgroup)
>  		pr_alert("page->mem_cgroup:%px\n", page->mem_cgroup);
>  #endif
>  }
> -- 
> 2.18.0
> 

-- 
Michal Hocko
SUSE Labs
