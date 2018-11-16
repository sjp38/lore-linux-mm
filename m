Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0E36B0961
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:56:01 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id g204-v6so13240135oia.21
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:56:01 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 9si15221622oti.99.2018.11.16.03.56.00
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 03:56:00 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 1/5] mm: print more information about mapping in
 __dump_page
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-2-mhocko@kernel.org>
Message-ID: <36711b50-6f5d-deaa-ec6f-c6a6d66cd94b@arm.com>
Date: Fri, 16 Nov 2018 17:25:56 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/16/2018 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __dump_page prints the mapping pointer but that is quite unhelpful
> for many reports because the pointer itself only helps to distinguish
> anon/ksm mappings from other ones (because of lowest bits
> set). Sometimes it would be much more helpful to know what kind of
> mapping that is actually and if we know this is a file mapping then also
> try to resolve the dentry name.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/debug.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index cdacba12e09a..a33177bfc856 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -44,6 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
>  
>  void __dump_page(struct page *page, const char *reason)
>  {
> +	struct address_space *mapping = page_mapping(page);
>  	bool page_poisoned = PagePoisoned(page);
>  	int mapcount;
>  
> @@ -70,6 +71,18 @@ void __dump_page(struct page *page, const char *reason)
>  	if (PageCompound(page))
>  		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
>  	pr_cont("\n");
> +	if (PageAnon(page))
> +		pr_emerg("anon ");
> +	else if (PageKsm(page))
> +		pr_emerg("ksm ");
> +	else if (mapping) {
> +		pr_emerg("%ps ", mapping->a_ops);
> +		if (mapping->host->i_dentry.first) {
> +			struct dentry *dentry;
> +			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
> +			pr_emerg("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
> +		}
> +	}
>  	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
>  
>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
> 

Differentiating between anon, ksm mapping and going till dentry information
for file mappings is surely an improvement. 

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
