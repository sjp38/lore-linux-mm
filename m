Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81BA6C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CE8F217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:44:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CE8F217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFF936B000A; Thu, 25 Apr 2019 03:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A87AC6B000C; Thu, 25 Apr 2019 03:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94E926B000D; Thu, 25 Apr 2019 03:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C04A6B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:44:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m47so11236785edd.15
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l1W+SmoOhrUxu5jkduQzobxYs+tQf+GIDgB9xzvB/wA=;
        b=NaAp2BSaZwfoo2et6LtE2coC7uU0AGEbKtr1TFIDrBUq+K9pzlDPeRBVREBZbk7nGx
         cOHUUYqAk2qU2FkCu0m2/HX/L0iXWlq5qbAsH+vpOtBqiY7HmBx8I+iVPk00LxfQmMHQ
         NWI27OBIHKRq2X9A3B+VCWjVrLGF6sOUMpQgi60b+b8gZFL7XG6tc5AV8fud/BGIl625
         TW48phRmxq6ryifwjsfcFjekhQum8BTLAfEGzgCt76mIGrpslkay/jXYv/XKldz/jAHd
         fcjxw/eeNLQ7X9pLYJ6KddB7w1XBwlQ7+OUoXgY8B8uAuaavDIvJ6l8GTaYvTm5z+pV0
         Qlyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUnfoELsby8O+RtS4J+vTFRCJl8M8QVpry8RPyFmBk893e0ULAm
	mH42CySH1ifiRIuREu7xG1/6C5hQNXWfV3dP/1Ufh5pLM+fXZJWfD4kvX0Scd8Im59+OACi2aDn
	h7jlCYB0CTJ41ry4BSQAB10gNEd5C4VB3u/aR8vCqj2vfjh+mDTg9NRIxMYSY1bw=
X-Received: by 2002:a50:89f6:: with SMTP id h51mr23250414edh.131.1556174289687;
        Wed, 24 Apr 2019 23:38:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzO7VGXd8zvRbEq8GgabCYtBYvhjv+RcvhR0VRVpM92vNDncDM6IYd4wlO0R064jEiR+XO
X-Received: by 2002:a50:89f6:: with SMTP id h51mr23250368edh.131.1556174288836;
        Wed, 24 Apr 2019 23:38:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556174288; cv=none;
        d=google.com; s=arc-20160816;
        b=DWQd9wsVAWa6WT3p2Khl0pj6EqjaVHNJPT7XVxemg3D2AyymFgnjyK2TsfKUZSUMwX
         oTRZ2y+MUZHkdMUdu09BnXqdsBBXShGI1am6VDVZRnvgt7Tg7A4RtCuO/4VK4xTNavYg
         VxyFizyCfvhG+yFcijNTxNmFDhaj1UynIjpzSvXD0+06HZH5J8AEmDt+ui8b8s3MscMq
         XCqf6fqYmwqzOpdaMwa18EF1U9etdBT/R5CDo0TAj/T3EYm2FmkufOCW5I9kAoFoogCs
         xlqIh0Z6x05vB0KKSOrzA5wOHAMMCW+CQdjrPAma6QufAe2sMdiOK2vSyCjw4bqRWdg0
         arYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l1W+SmoOhrUxu5jkduQzobxYs+tQf+GIDgB9xzvB/wA=;
        b=O3yGA7hgBa0CKfEKi+LnLZNRbxU9DJJ6k0IS2mpWeYI0AnGtlBbJ523zdOWX92rUAa
         TyzsyVkKfRVKila4NdLdhc1rP0iFtUBWt8MDAKLs34bcQ5sCcH/d+pXe6MVP8T9nlP+2
         zj3OOqolv/QFvg/giHB5NkJbm7rpMhSHaK1NkXQuBw7+3VhSD4ro1/TxevzygVzLy3/Y
         hb6VT/okhpknJMMpg43UCp7MVrowhB+QHr/gVr5yNKE+Q4mvIyNNmzYOWBFufOZwR4zI
         BumGncL5vc81GEjMBf58sfTIZnS6cRxa+dahQKKspEsZ2UjNakXV+RBo4B/pdHFjQ8QR
         Vk+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si1274880ejr.228.2019.04.24.23.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 23:38:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5F706AE5E;
	Thu, 25 Apr 2019 06:38:08 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:38:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Fan Du <fan.du@intel.com>
Cc: akpm@linux-foundation.org, fengguang.wu@intel.com,
	dan.j.williams@intel.com, dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com, ying.huang@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Message-ID: <20190425063807.GK12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556155295-77723-6-git-send-email-fan.du@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 09:21:35, Fan Du wrote:
> On system with heterogeneous memory, reasonable fall back lists woul be:
> a. No fall back, stick to current running node.
> b. Fall back to other nodes of the same type or different type
>    e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3
> c. Fall back to other nodes of the same type only.
>    e.g. DRAM node 0 -> DRAM node 1
> 
> a. is already in place, previous patch implement b. providing way to
> satisfy memory request as best effort by default. And this patch of
> writing build c. to fallback to the same node type when user specify
> GFP_SAME_NODE_TYPE only.

So an immediate question which should be answered by this changelog. Who
is going to use the new gfp flag? Why cannot all allocations without an
explicit numa policy fallback to all existing nodes?
 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  include/linux/gfp.h    |  7 +++++++
>  include/linux/mmzone.h |  1 +
>  mm/page_alloc.c        | 15 +++++++++++++++
>  3 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index fdab7de..ca5fdfc 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -44,6 +44,8 @@
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> +#define ___GFP_SAME_NODE_TYPE	0x1000000u
> +
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -215,6 +217,7 @@
>  
>  /* Disable lockdep for GFP context tracking */
>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
> +#define __GFP_SAME_NODE_TYPE ((__force gfp_t)___GFP_SAME_NODE_TYPE)
>  
>  /* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> @@ -301,6 +304,8 @@
>  			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>  #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
>  
> +#define GFP_SAME_NODE_TYPE (__GFP_SAME_NODE_TYPE)
> +
>  /* Convert GFP flags to their corresponding migrate type */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
>  #define GFP_MOVABLE_SHIFT 3
> @@ -438,6 +443,8 @@ static inline int gfp_zonelist(gfp_t flags)
>  #ifdef CONFIG_NUMA
>  	if (unlikely(flags & __GFP_THISNODE))
>  		return ZONELIST_NOFALLBACK;
> +	if (unlikely(flags & __GFP_SAME_NODE_TYPE))
> +		return ZONELIST_FALLBACK_SAME_TYPE;
>  #endif
>  	return ZONELIST_FALLBACK;
>  }
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 8c37e1c..2f8603e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -583,6 +583,7 @@ static inline bool zone_intersects(struct zone *zone,
>  
>  enum {
>  	ZONELIST_FALLBACK,	/* zonelist with fallback */
> +	ZONELIST_FALLBACK_SAME_TYPE,	/* zonelist with fallback to the same type node */
>  #ifdef CONFIG_NUMA
>  	/*
>  	 * The NUMA zonelists are doubled because we need zonelists that
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a408a91..de797921 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5448,6 +5448,21 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
>  	}
>  	zonerefs->zone = NULL;
>  	zonerefs->zone_idx = 0;
> +
> +	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK_SAME_TYPE]._zonerefs;
> +
> +	for (i = 0; i < nr_nodes; i++) {
> +		int nr_zones;
> +
> +		pg_data_t *node = NODE_DATA(node_order[i]);
> +
> +		if (!is_node_same_type(node->node_id, pgdat->node_id))
> +			continue;
> +		nr_zones = build_zonerefs_node(node, zonerefs);
> +		zonerefs += nr_zones;
> +	}
> +	zonerefs->zone = NULL;
> +	zonerefs->zone_idx = 0;
>  }
>  
>  /*
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

