Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85B7BC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32A3921473
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32A3921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9EBA6B0006; Tue,  9 Apr 2019 05:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F8D6B0007; Tue,  9 Apr 2019 05:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93BB86B0008; Tue,  9 Apr 2019 05:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4500B6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:18:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k8so8318134edl.22
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zGmozu/iHLKSKQMAOGoQl7kSZ4a7Tauvc2SfRHFS/tA=;
        b=ntLPXuwwbOsTibTPjpSDlQuhRJrhO/tEO3do9Wkh5ywyHzgd++Vs/RJLAJD7Boe3uL
         0T4VesUlZIDI4aEQAFHgYXSKMHF+Jpv7pu6nr4ecMzlmVm4GOiwAt8MTfxi762MBD9ST
         6LLa2Nf2EBuf5BJK44VlP1QG6IuhR3/vPlUgLlF5CYsK1x3Z/noNQDxMLXG53kNsEihb
         g3CWtmH40nN/cv0P/EPeG2vxTs+49eJfVVVPzNqNtqt8L7xEuiif3IbjuUmbc2atmXg5
         TJnriQgfTwIHSx5lyGGBbbTbynz4TDnIspgxRA47W0WelmDB7SQYJxVOWz2KmQMbHJ5Y
         V4jQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXFcOO3qmssZ9RpWD/zrlplQ9EUgeDDad8vMjbVmF5cEEj3XX/Z
	2qLc1jqlfPoobySBiBZr+UIqXtmpWS/xUtZKO1yWq9DRzvyOkJlOlzedXc0UTn13Fk4o/70sAlN
	ee1O1cOGJs2OkpIbwayOwUXU2tdfG+6US5r7FaMmo6oxONoXhAG+e3GiRx2DuWowU7w==
X-Received: by 2002:a50:d591:: with SMTP id v17mr22685198edi.180.1554801530782;
        Tue, 09 Apr 2019 02:18:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCz0lg4rQIx9lTNBfb7Hpetwn3S/hsDWL8ouIxRj7S5TsYKqDmkW8sJAttLF51nWiJZGAS
X-Received: by 2002:a50:d591:: with SMTP id v17mr22685140edi.180.1554801529748;
        Tue, 09 Apr 2019 02:18:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554801529; cv=none;
        d=google.com; s=arc-20160816;
        b=SMSDPQ290a6wx1w8BxBGFOal63xatl2/vkLcAXyb/tKtzIScMoRod9I6ypfmFh95dC
         NjT91vh2QHLXTnSDVVCBEKXplRzBAQDwVXoj2MNKreoCDU97T74qJh7plX7bSq7Ka3DN
         +m+wizP7Cs752Tir2UVkj9pXM1KxPGAv4dEEqCc8IcgU5JuUujaQ3BPFrKuEGPtTikEv
         pYa07S5Ine/5HitbCDdAxHdn+H6wb7TucyOyXNaWhTDOFDBG6xV0rtKsN+8eAYATzq6K
         GZ4gJJ+kpoKNn0IsqVo6KZiaeE/fSZg93nUjS4WJYR7dj8riFr2B2/7+NT9v8tTjpooD
         xNeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zGmozu/iHLKSKQMAOGoQl7kSZ4a7Tauvc2SfRHFS/tA=;
        b=xhkNz9J8bXeHbQ+cCitEut9OvJS0CvEC8JsDuCi5ymf9fblRBfQSzrJoBpy1qgwIaC
         dGiZO+i8y/kO0n1i05cMKkG1Y8MDWh7lQYerh3BM1Q5eKhy2js3YkmDnxOzMvs3GeEW9
         /V5H3fsRCymbaFcmVE1hTMzGBUs3zhJ0lK+AiYG2D3fLbQim1wNzLbfhRat9K0IxpX6Q
         E+VEwSoTpeY8GCV7hmTLQJraG+M4fcrcuo+h3CjeHmI0W/Xu2IsVb5Qt46gD/rip9+jp
         EPnDICBl2rcQVO1n4NR0ia9o7UvQyTUx6AFfv3a5UwTpDyOG5NLNio5GPhfzLp/TU7g1
         M3pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id q11si740070edd.57.2019.04.09.02.18.49
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 02:18:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 726B048B2; Tue,  9 Apr 2019 11:18:48 +0200 (CEST)
Date: Tue, 9 Apr 2019 11:18:48 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>, mike.travis@hpe.com,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org,
	dan.j.williams@intel.com
Subject: Re: [PATCH RFC 3/3] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
Message-ID: <20190409091844.yvjmglawf2fmiy3o@d104.suse.de>
References: <20190408101226.20976-1-david@redhat.com>
 <20190408101226.20976-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190408101226.20976-4-david@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 12:12:26PM +0200, David Hildenbrand wrote:
> Let's factor out removing of memory block devices, which is only
> necessary for memory added via add_memory() and friends that created
> memory block devices. Remove the devices before calling
> arch_remove_memory().
> 
> TODO: We should try to get rid of the errors that could be reported by
> unregister_memory_block_under_nodes(). Ignoring failures is not that
> nice.

Hi David,

I am sorry but I will not have to look into this until next week as I am
up to my ears with work plus I am in the middle of a move.

I remember I was once trying to simplify unregister_mem_sect_under_nodes (your
new unregister_memory_block_under_nodes), and I checked whether we could get
rid of the NODEMASK_ALLOC there, something like:

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..f4294a2928dd 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -805,16 +805,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
                                    unsigned long phys_index)
 {
-       NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
+       nodemask_t unlinked_nodes;
        unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-       if (!mem_blk) {
-               NODEMASK_FREE(unlinked_nodes);
-               return -EFAULT;
-       }
-       if (!unlinked_nodes)
-               return -ENOMEM;
-       nodes_clear(*unlinked_nodes);
+       nodes_clear(unlinked_nodes);
 
        sect_start_pfn = section_nr_to_pfn(phys_index);
        sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
@@ -826,14 +820,13 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
                        continue;
                if (!node_online(nid))
                        continue;
-               if (node_test_and_set(nid, *unlinked_nodes))
+               if (node_test_and_set(nid, unlinked_nodes))
                        continue;
                sysfs_remove_link(&node_devices[nid]->dev.kobj,
                         kobject_name(&mem_blk->dev.kobj));
                sysfs_remove_link(&mem_blk->dev.kobj,
                         kobject_name(&node_devices[nid]->dev.kobj));
        }
-       NODEMASK_FREE(unlinked_nodes);
        return 0;
 }


nodemask_t is 128bytes when CONFIG_NODES_SHIFT is 10 , which is the maximum value.
We just need to check whether we can overflow the stack or not.

AFAICS, it is not really a shore stack but it might not be that deep either.

> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 41 +++++++++++++++--------------------------
>  drivers/base/node.c    |  7 +++----
>  include/linux/memory.h |  2 +-
>  include/linux/node.h   |  6 ++----
>  mm/memory_hotplug.c    | 10 ++++------
>  5 files changed, 25 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 847b33061e2e..fd8940c37129 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -752,40 +752,29 @@ int hotplug_memory_register(unsigned long start, unsigned long size)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -static int remove_memory_section(struct mem_section *section)
> +void hotplug_memory_unregister(unsigned long start, unsigned long size)
>  {
> +	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +	unsigned long start_pfn = PFN_DOWN(start);
> +	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>  	struct memory_block *mem;
> +	unsigned long pfn;
>  
> -	mutex_lock(&mem_sysfs_mutex);
> -
> -	/*
> -	 * Some users of the memory hotplug do not want/need memblock to
> -	 * track all sections. Skip over those.
> -	 */
> -	mem = find_memory_block(section);
> -	if (!mem)
> -		goto out_unlock;
> -
> -	unregister_mem_sect_under_nodes(mem, __section_nr(section));
> +	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
>  
> -	mem->section_count--;
> -	if (mem->section_count == 0)
> +	mutex_lock(&mem_sysfs_mutex);
> +	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +		mem = find_memory_block(__pfn_to_section(pfn));
> +		if (!mem)
> +			continue;
> +		mem->section_count = 0;
> +		unregister_memory_block_under_nodes(mem);
>  		unregister_memory(mem);
> -	else
> -		put_device(&mem->dev);
> -
> -out_unlock:
> +	}
>  	mutex_unlock(&mem_sysfs_mutex);
> -	return 0;
>  }
>  
> -int unregister_memory_section(struct mem_section *section)
> -{
> -	if (!present_section(section))
> -		return -EINVAL;
> -
> -	return remove_memory_section(section);
> -}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  /* return true if the memory block is offlined, otherwise, return false */
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 8598fcbd2a17..f9997770ac15 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -802,8 +802,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  }
>  
>  /* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -				    unsigned long phys_index)
> +int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -816,8 +815,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  		return -ENOMEM;
>  	nodes_clear(*unlinked_nodes);
>  
> -	sect_start_pfn = section_nr_to_pfn(phys_index);
> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> +	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>  		int nid;
>  
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index e275dc775834..414e43ab0881 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -113,7 +113,7 @@ extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  int hotplug_memory_register(unsigned long start, unsigned long size);
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -extern int unregister_memory_section(struct mem_section *);
> +void hotplug_memory_unregister(unsigned long start, unsigned long size);
>  #endif
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 1a557c589ecb..02a29e71b175 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						void *arg);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -					   unsigned long phys_index);
> +extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
>  
>  extern int register_memory_node_under_compute_node(unsigned int mem_nid,
>  						   unsigned int cpu_nid,
> @@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>  	return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -						  unsigned long phys_index)
> +static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>  	return 0;
>  }
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 13ee0a26e034..041b93c5eede 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -518,14 +518,9 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>  {
>  	unsigned long start_pfn;
>  	int scn_nr;
> -	int ret = -EINVAL;
>  
>  	if (!valid_section(ms))
> -		return ret;
> -
> -	ret = unregister_memory_section(ms);
> -	if (ret)
> -		return ret;
> +		return -EINVAL;
>  
>  	scn_nr = __section_nr(ms);
>  	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> @@ -1875,6 +1870,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> +	/* remove memory block devices before removing memory */
> +	hotplug_memory_unregister(start, size);
> +
>  	arch_remove_memory(nid, start, size, NULL);
>  
>  	try_offline_node(nid);
> -- 
> 2.17.2
> 

-- 
Oscar Salvador
SUSE L3

