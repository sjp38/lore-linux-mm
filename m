Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9CE16B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 08:42:47 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x77so4591192wmd.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 05:42:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k97si11729896wrc.14.2018.02.19.05.42.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 05:42:46 -0800 (PST)
Date: Mon, 19 Feb 2018 14:42:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 6/6] mm/memory_hotplug: optimize memory hotplug
Message-ID: <20180219134244.GM21134@dhcp22.suse.cz>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-7-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-7-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Thu 15-02-18 11:59:20, Pavel Tatashin wrote:
[...]
> @@ -260,21 +260,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  		return ret;
>  
>  	/*
> -	 * Make all the pages reserved so that nobody will stumble over half
> -	 * initialized state.
> -	 * FIXME: We also have to associate it with a node because page_to_nid
> -	 * relies on having page with the proper node.
> +	 * The first page in every section holds node id, this is because we
> +	 * will need it in online_pages().
>  	 */
> -	for (i = 0; i < PAGES_PER_SECTION; i++) {
> -		unsigned long pfn = phys_start_pfn + i;
> -		struct page *page;
> -		if (!pfn_valid(pfn))
> -			continue;
> -
> -		page = pfn_to_page(pfn);
> -		set_page_node(page, nid);
> -		SetPageReserved(page);
> -	}
> +	page = pfn_to_page(phys_start_pfn);
> +	mm_zero_struct_page(page);
> +	set_page_node(page, nid);

I really dislike this part. It is just too subtle assumption. We can
safely store the node id into memory_block and push it down the way to
online. Or am I missing something?

Btw. the rest of the series seem good as is so I would go with it and
keep this last patch aparat and make sure to do it properly rather than
add more hacks.
  
>  	if (!want_memblock)
>  		return 0;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
