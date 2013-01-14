Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 6255E6B0078
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 13:43:11 -0500 (EST)
Date: Mon, 14 Jan 2013 19:43:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memory-hotplug: revert register_page_bootmem_info_node()
 to empty when platform related code is not implemented
Message-ID: <20130114184308.GD5126@dhcp22.suse.cz>
References: <1358160835-30617-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358160835-30617-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, wency@cn.fujitsu.com, jiang.liu@huawei.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

On Mon 14-01-13 18:53:55, Lin Feng wrote:
> Memory-hotplug codes for x86_64 have been implemented by patchset:
> https://lkml.org/lkml/2013/1/9/124
> While other platforms haven't been completely implemented yet.
> 
> If we enable both CONFIG_MEMORY_HOTPLUG_SPARSE and CONFIG_SPARSEMEM_VMEMMAP,
> register_page_bootmem_info_node() may be buggy, which is a hotplug generic
> function but falling back to call platform related function
> register_page_bootmem_memmap().
> 
> Other platforms such as powerpc it's not implemented, so on such platforms,
> revert them as empty as they were before.
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  mm/memory_hotplug.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8aa2b56..bd93c2e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -189,6 +189,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
>  }
>  #endif
>  
> +#ifdef CONFIG_X86_64
>  void register_page_bootmem_info_node(struct pglist_data *pgdat)
>  {
>  	unsigned long i, pfn, end_pfn, nr_pages;
> @@ -230,6 +231,14 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
>  			register_page_bootmem_info_section(pfn);
>  	}
>  }
> +#else
> +static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
> +{
> +	/*
> +	 * Todo: platforms other than X86_64 haven't been implemented yet.
> +	 */
> +}
> +#endif

This is just ugly. Could you please add something like HAVE_BOOTMEM_INFO_NODE
or something with a bettern name and let CONFIG_MEMORY_HOTPLUG select it
for supported architectures and configurations (e.g.
CONFIG_SPARSEMEM_VMEMMAP doesn't need a special arch support, right?).
These Todo things are just too messy.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
