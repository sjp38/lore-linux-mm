Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 358ACC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:42:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 018A320665
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:42:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 018A320665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796806B0006; Fri, 19 Jul 2019 04:42:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 746F68E0003; Fri, 19 Jul 2019 04:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 635458E0001; Fri, 19 Jul 2019 04:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 175F26B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:42:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so21604829edc.6
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 01:42:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=whgd30W8GvIdwxm4U+lHBJixZx3S8CukqvJL0dA/yIY=;
        b=V1yfJaJYycyfOWa4a6+vMXu9kC7mgTtFGZRGoJAHr6rgT0iJg82c3M2NuDV+M5pVpR
         IKdIgFmGI4wDVfyEtlYc4WDwzTmxnIUsWbH+Hzq8KFcggPDCEbZUHzSOVuhWmwdL7MHj
         UMpCQS5byThNXTTL5lBQZbMjcen0F5cpXXPDPI8cZef/GUlQtC1+dl+KJNSrjWvqGG3J
         4i9apc0Tqpc8qm7N2DQfEUOhsLc+7hWH5AM8k+AHXnsECzebpkNmO646w2mvGJOrOKv0
         M8AJYufmhI6dE1ZqPbo9AFHUB8IZDd+tcFPlyu0XqYZEM8zVMLLYv8rvPaoc3hl77/G4
         10Hg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWUrA9zm+sotmFglmRKGMIbGzFNFpNmI/EJEsQeICvxI+CkEXvW
	Kd7DXs46MeJDc6Gxcrbdxj5ozAVHLNGFw+hc64h1MYgkvekcGYlnpaM2sKO1ZvEzaI5hAilVwe+
	PT5oCvbV29Id3SCojvts1drpf57/kFTNi5jqud4+J29RlFWik2W23EpE2fOkSMQY=
X-Received: by 2002:a50:f7c1:: with SMTP id i1mr44930962edn.268.1563525761661;
        Fri, 19 Jul 2019 01:42:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMMCBG2shI+Mlj+n8rY7tYBQ+hX927ZZXUsqRT+QRL3TMRKmXz6uU6sdr7Y4eHwgfmTrf5
X-Received: by 2002:a50:f7c1:: with SMTP id i1mr44930924edn.268.1563525760886;
        Fri, 19 Jul 2019 01:42:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563525760; cv=none;
        d=google.com; s=arc-20160816;
        b=M5fgg562U95kMTHeMe/jqw5YdpumuzWCwxQatp0WD/fQo3nkcUYxfk6RBPBeff51AG
         qBTUsrWTNiqaqOCrNuoM9p24JJowf905jdAYpUBa10g7Hm5b6F/tHz2p+qZ9JBtyPpTb
         R5L46zF3wTUJWitXD9TR2xst12DhKfudBCWyC7y31uQnvE4bTOnzDp0kwRE4qTHEI1kX
         ggpVt7Bo0EIwyeOxk3pyFBwU0okS3MB/bYpFlTlfotP4IpZNCZjxi2AilwUzkBSFycr5
         PB7LVR7WJMeo5zMaiAr9yBJYW7DCKrMrc2KxMmw9ijZ42HcSBbI4tv6zhmbHSmJ71v1B
         8+1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=whgd30W8GvIdwxm4U+lHBJixZx3S8CukqvJL0dA/yIY=;
        b=kgLSBSZoXZ2aIvcQffXJqgkYJYt6vfzYHT9xU5W0/53STRcUEOXvCKtR2mg4mbrPSd
         MskhzHFgJSJ0X7aNZ4xKupFoKxA7+KILdnvY55NPlvC0tgDUAgWvVtCfJxywxk3VNVB4
         ODyuVNlXU1EKNY3+bsWkBAlRALIo9e+BtwpGuiv9oS4SrJ8kFykezS+36zcl5yPE1G4J
         Mz1YhP/aOR4x9FXPEjpyBG6GzE1/l6aMrj1wLTTiRb9PmVlxEO3PScj6FSfqLk4JIZVa
         c/XvNb1wkf7o0y4KzdgCtG4HSbe2CepFdLX100exdMfCb4rffrdQvkuqbR8/J205DmHt
         vQuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d38si127963ede.318.2019.07.19.01.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 01:42:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 58622ACD1;
	Fri, 19 Jul 2019 08:42:40 +0000 (UTC)
Date: Fri, 19 Jul 2019 10:42:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
Message-ID: <20190719084239.GO30461@dhcp22.suse.cz>
References: <20190718142239.7205-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718142239.7205-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
> We don't allow to offline memory block devices that belong to multiple
> numa nodes. Therefore, such devices can never get removed. It is
> sufficient to process a single node when removing the memory block.
> 
> Remember for each memory block if it belongs to no, a single, or mixed
> nodes, so we can use that information to skip unregistering or print a
> warning (essentially a safety net to catch BUGs).

I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
node that is magic. Why should we even care? In other words why is this
patch an improvement?

> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  |  1 +
>  drivers/base/node.c    | 40 ++++++++++++++++------------------------
>  include/linux/memory.h |  4 +++-
>  3 files changed, 20 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 20c39d1bcef8..154d5d4a0779 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -674,6 +674,7 @@ static int init_memory_block(struct memory_block **memory,
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +	mem->nid = NUMA_NO_NODE;
>  
>  	ret = register_memory(mem);
>  
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 75b7e6f6535b..29d27b8d5fda 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -759,8 +759,6 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  	int ret, nid = *(int *)arg;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	mem_blk->nid = nid;
> -
>  	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>  	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>  	sect_end_pfn += PAGES_PER_SECTION - 1;
> @@ -789,6 +787,13 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  			if (page_nid != nid)
>  				continue;
>  		}
> +
> +		/* this memory block spans this node */
> +		if (mem_blk->nid == NUMA_NO_NODE)
> +			mem_blk->nid = nid;
> +		else
> +			mem_blk->nid = NUMA_NO_NODE - 1;
> +
>  		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>  					&mem_blk->dev.kobj,
>  					kobject_name(&mem_blk->dev.kobj));
> @@ -804,32 +809,19 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  }
>  
>  /*
> - * Unregister memory block device under all nodes that it spans.
> - * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
> + * Unregister a memory block device under the node it spans. Memory blocks
> + * with multiple nodes cannot be offlined and therefore also never be removed.
>   */
>  void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
> -	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> -	static nodemask_t unlinked_nodes;
> -
> -	nodes_clear(unlinked_nodes);
> -	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> -	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
> -	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int nid;
> +	if (mem_blk->nid == NUMA_NO_NODE ||
> +	    WARN_ON_ONCE(mem_blk->nid == NUMA_NO_NODE - 1))
> +		return;
>  
> -		nid = get_nid_for_pfn(pfn);
> -		if (nid < 0)
> -			continue;
> -		if (!node_online(nid))
> -			continue;
> -		if (node_test_and_set(nid, unlinked_nodes))
> -			continue;
> -		sysfs_remove_link(&node_devices[nid]->dev.kobj,
> -			 kobject_name(&mem_blk->dev.kobj));
> -		sysfs_remove_link(&mem_blk->dev.kobj,
> -			 kobject_name(&node_devices[nid]->dev.kobj));
> -	}
> +	sysfs_remove_link(&node_devices[mem_blk->nid]->dev.kobj,
> +		 kobject_name(&mem_blk->dev.kobj));
> +	sysfs_remove_link(&mem_blk->dev.kobj,
> +		 kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
>  }
>  
>  int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 02e633f3ede0..c91af10d5fb4 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -33,7 +33,9 @@ struct memory_block {
>  	void *hw;			/* optional pointer to fw/hw data */
>  	int (*phys_callback)(struct memory_block *);
>  	struct device dev;
> -	int nid;			/* NID for this memory block */
> +	int nid;			/* NID for this memory block.
> +					   - NUMA_NO_NODE: uninitialized
> +					   - NUMA_NO_NODE - 1: mixed nodes */
>  };
>  
>  int arch_get_memory_phys_device(unsigned long start_pfn);
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

