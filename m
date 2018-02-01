Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB216B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 09:15:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o11so13572223pgp.14
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 06:15:48 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b187si3724427pfg.66.2018.02.01.06.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 06:15:47 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/sparsemem: Defer the ms->section_mem_map clearing
 a little later
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-2-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <87acc80a-8a9a-5037-8efc-9bb64ddaaffb@intel.com>
Date: Thu, 1 Feb 2018 06:15:45 -0800
MIME-Version: 1.0
In-Reply-To: <20180201071956.14365-2-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 01/31/2018 11:19 PM, Baoquan He wrote:
>  	for_each_present_section_nr(0, pnum) {
> +		struct mem_section *ms;
> +		ms = __nr_to_section(pnum);
>  		usemap = usemap_map[pnum];
> -		if (!usemap)
> +		if (!usemap) {
> +#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> +			ms->section_mem_map = 0;
> +#endif
>  			continue;
> +		}
>  
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
>  		map = map_map[pnum];
>  #else
>  		map = sparse_early_mem_map_alloc(pnum);
>  #endif
> -		if (!map)
> +		if (!map) {
> +#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> +			ms->section_mem_map = 0;
> +#endif
>  			continue;
> +		}

This is starting to look like code that only a mother could love.  Can
this be cleaned up a bit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
