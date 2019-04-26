Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21D1CC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C592077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:04:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C592077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88BC56B0005; Fri, 26 Apr 2019 10:04:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861096B0006; Fri, 26 Apr 2019 10:04:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 751A16B0008; Fri, 26 Apr 2019 10:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 294E36B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:04:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r8so1560020edd.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gJe3w0QjKk9/wtqkCDLvOIpFoBBTFN+6WG5P6TRG3Do=;
        b=lxa2Uz2aThr+SXyQ21yJ7jhyQYe3WYIrYO8HqDSsuzgeQL/sshJvj9DQJVYBoLBKDp
         ql15sbH4JqdVpbvPiMDTxKKdpcI6Pi5gTj/5DooYvhlTV7rRHHxf1UZJlIxbc/Cv2ShO
         NiQQ9nuv/vJHe0ARkXAsfRqJUpCqTPqXLMNFzw+mlXj1S3kGifUhDKeGIGPa1lCsPLt4
         TjfRqP8cMNrAFOSldYk+Pt7+h1h0q+r0C6RCu/hKBMzPrSNdyPjpLxPJVw1Q9htWEOMh
         i2UGktqErQAa0MZOFes5RM1ukXToTkv0CxrgiazgbHs6jCCL/CBNcxOUS1nFY255717/
         7exA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUz6zgWqVGpHNxOAKX3RfPj8C+nXGW4JIstxYKB1IVszWt2O9qe
	68biiNoT8+bqJZeolJaHIC7Hcoh+up254btMqQER4Fuq0THeWnJqOZEPMP+19NltMZjby9+vCQE
	qmFi1EgnelHWjfiUJ8qZIQr+edJxIXN3v+i2hwvpn+k9z98ihp2kfFlt3+FTXsTQXxw==
X-Received: by 2002:a50:d69c:: with SMTP id r28mr23441227edi.150.1556287483730;
        Fri, 26 Apr 2019 07:04:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3T5MqIsIO1dbh7b1n+HismlvpM2PVMF2K9YN8JsEtoqLc9z6JSRuMjv2pOEct7tA2GwNi
X-Received: by 2002:a50:d69c:: with SMTP id r28mr23441187edi.150.1556287483089;
        Fri, 26 Apr 2019 07:04:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556287483; cv=none;
        d=google.com; s=arc-20160816;
        b=tvom1Hc93ORihSSfDC2Q4T/Te5xiE7WMWpLbyybyJRvxPSgreQ5/12T47jVYmXoaBa
         4iWXauQZV98BNdJgdwI+7juYPDegMFGT+G7AIt27nHIW5JY7xcCf/myzY016yefbMCbs
         m2mxlfwX7Z3uptGv9/Spt0DQ8X4QBl48gxrFNM1cGqu0v6Oz9C5TX8B7Ct/X17IwXnJe
         GNMp5k6aTdrlgga+0ayc9XXTtwIx3ki4NWKoQ/QU7s5SAgPsrZsYXkcDmB8PKnGj2yaa
         k1KUKszdt72nXw2CwByNVrf9YsIjqxqeHYPT0GbcWOgyq+lQPG0dMwVV+LjGrD8vzrAj
         UK1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gJe3w0QjKk9/wtqkCDLvOIpFoBBTFN+6WG5P6TRG3Do=;
        b=KEakqjfgFtMxhSzIXseklo0Tju41zU95Fuk9gXH5mIqaGBNSOvw5UqEXhBRyvSDCde
         KhBTzvN0A2pF18GvIRdUIZTUf8/SbRPEHJqwKrm5uRqB3YByy506DY6poVL0mJe//xmX
         9nWh3VhdmFy9uNlPCFE8Pqml+PLW1l08KWcp3wb/P9W5yJksyg8z25kgEv5XBDl0p76k
         v37aoOx7JqE86VlZzInxigm/GsR7tQLfWu4XC8vfCovP6D9yZvtpNbs1pPH4SIvY6/EX
         ybLxZZP+io1jOTIN9vqHVQwtabEr1dhMZusbJ6GgyzmeOtsuBPINxM5D1qXPa9rnh3MW
         TUOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si2790965ejb.101.2019.04.26.07.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:04:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 37162AF3A;
	Fri, 26 Apr 2019 14:04:42 +0000 (UTC)
Date: Fri, 26 Apr 2019 16:04:39 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	David Hildenbrand <david@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 07/12] mm: Kill is_dev_zone() helper
Message-ID: <20190426140439.GC30513@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:39:32AM -0700, Dan Williams wrote:
> Given there are no more usages of is_dev_zone() outside of 'ifdef
> CONFIG_ZONE_DEVICE' protection, kill off the compilation helper.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  include/linux/mmzone.h |   12 ------------
>  mm/page_alloc.c        |    2 +-
>  2 files changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b13f0cddf75e..3237c5e456df 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -855,18 +855,6 @@ static inline int local_memory_node(int node_id) { return node_id; };
>   */
>  #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
>  
> -#ifdef CONFIG_ZONE_DEVICE
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return zone_idx(zone) == ZONE_DEVICE;
> -}
> -#else
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return false;
> -}
> -#endif
> -
>  /*
>   * Returns true if a zone has pages managed by the buddy allocator.
>   * All the reclaim decisions have to use this function rather than
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c9ad28a78018..fd455bd742d5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5844,7 +5844,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  	unsigned long start = jiffies;
>  	int nid = pgdat->node_id;
>  
> -	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
> +	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
>  		return;
>  
>  	/*
> 

-- 
Oscar Salvador
SUSE L3

