Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5579C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6646A20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:15:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6646A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04DCE6B0007; Mon,  1 Jul 2019 04:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F18DB8E0003; Mon,  1 Jul 2019 04:15:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07BF8E0002; Mon,  1 Jul 2019 04:15:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id 909C66B0007
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:15:10 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id l14so16244883edw.20
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:15:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eXi6yQH8G+hTeFTsFmkYb0RA9aCqp5uVQBWiMGq858Q=;
        b=fkpzn/Qe391LJSYv6VLgExbgc/wxhaaLkGVccnMqsU8Pjv7Vw3JFigI054FYcQZDeV
         lUv5K9dIcUIBtjbcXjZ2k3EKVfyS6aikwDCxHOvkQs2sxsOm8zL4aMZ91Bm1KsC3ttzo
         m9SlpgRcn0hWICe/9H+EKazUh96SJqxCI0wDFb2PmgQPZZyOCTCvCaeYQFELy0QSpfkv
         wyF9wZ07/MSGxhRsg2nBhUGGmer8zp935bLjeJTvU+WrLmE2kygDwe5sLhOGLdmTs2Qg
         3CLum9ZSkHSCxj7+cNS4m0u23YXaVK45YZVWEttdafc2OTBDmrwL9oTh5egyvSwDqdeS
         ajYg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXMvH2f7buPkUzUrJU4e0yvMOh/0bwxCyGvE0sSfcZHLz6UGaEG
	BQzK6nz9NnLZdG2zxGKMwzVGPXictZAoLZaBHSuOiRBWpEGWu9kNVhWOwJ/+jQV4n8jK0LZkPe7
	scwewtWZND8FppAj4oPlwv/hydM1MG38PpRkKowa63a25ut33G02u11fjFlaIhVU=
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr27821244edq.292.1561968910166;
        Mon, 01 Jul 2019 01:15:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBKdgHzQk5caoIB5ijmxYjjwy2DtgiUyUWnI/nPohmwSnnx1awI6jtReaVd78KxRumjSLH
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr27821205edq.292.1561968909588;
        Mon, 01 Jul 2019 01:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561968909; cv=none;
        d=google.com; s=arc-20160816;
        b=RzjNq1Vl6hJIzkD+CzzCKMXhlIHgfVXJsSzceXHudnmYF7gNtjyaUfLDHGT/423WTy
         rjR2vhv8tR7Aqg7VBydRi7OO6c8IoXmyrWofzyg/nZy7sxNJWGVC0AcL3TM+EthAzVjt
         VgqPwBOeYVytm9khdl5EY+fAVUT5KoJvC5j4rY9PREwb0PTQcas7tP3TbqWyKvJSxbik
         hDty2XaN1x401QNU+MQAP5qf7tHB2WeniDUv0t/h6Y4UhWX6JbnCYBFx9EohK+sldYx8
         6y9E63AwjC0TYoX9Iu7Ilof1gY/RisWAWCqjFADJs1zifYf2RNDRfZ/2LpKg81z+oqTN
         yr4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eXi6yQH8G+hTeFTsFmkYb0RA9aCqp5uVQBWiMGq858Q=;
        b=VckhUjqrvRnCXmrYr4Lzg+kSQCgTBlwm/2lk87HZB+QZV0HlgpG+PvuRdko7mV0Tmh
         E8g5CzIGsiYwJiS+P1W1mbUNOFB7B60YgPNA5lezE+z1sKcO35alQKypmQhHbEkcFEaB
         tHKDZvAC2bohLGyyPaWMptgyrlWw9MnVMkkMOBJGpQ2FeVImRkuGS2y5oFWKVXjZ3XjC
         Cy7hW/GrodQaSMk0Z4bJXK/9XcyFWfovU7Pv54d39bz4sZnPDg/vF6/cl+x9v+YNAWOA
         VZP5O87BZc9HOmpNXcgqxBAbLLhGi/+zJ92oOm/B/gyRjUvgtLgV5SRuE54x8s6vGoEX
         YDsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk6si6311477ejb.390.2019.07.01.01.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:15:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 227FEAE60;
	Mon,  1 Jul 2019 08:15:09 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:15:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 08/11] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Message-ID: <20190701081508.GH6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-9-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-9-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:49, David Hildenbrand wrote:
> No longer needed, the callers of arch_add_memory() can handle this
> manually.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memory_hotplug.h | 8 --------
>  mm/memory_hotplug.c            | 9 +++------
>  2 files changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2d4de313926d..2f1f87e13baa 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>  			   unsigned long nr_pages, struct vmem_altmap *altmap);
>  
> -/*
> - * Do we want sysfs memblock files created. This will allow userspace to online
> - * and offline memory explicitly. Lack of this bit means that the caller has to
> - * call move_pfn_range_to_zone to finish the initialization.
> - */
> -
> -#define MHP_MEMBLOCK_API               (1<<0)
> -
>  /* reasonably generic interface to expand the physical pages */
>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>  		       struct mhp_restrictions *restrictions);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b1fde90bbf19..9a92549ef23b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -251,7 +251,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>  
>  static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> -		struct vmem_altmap *altmap, bool want_memblock)
> +				   struct vmem_altmap *altmap)
>  {
>  	int ret;
>  
> @@ -294,8 +294,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  	}
>  
>  	for (i = start_sec; i <= end_sec; i++) {
> -		err = __add_section(nid, section_nr_to_pfn(i), altmap,
> -				restrictions->flags & MHP_MEMBLOCK_API);
> +		err = __add_section(nid, section_nr_to_pfn(i), altmap);
>  
>  		/*
>  		 * EEXIST is finally dealt with by ioresource collision
> @@ -1067,9 +1066,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>   */
>  int __ref add_memory_resource(int nid, struct resource *res)
>  {
> -	struct mhp_restrictions restrictions = {
> -		.flags = MHP_MEMBLOCK_API,
> -	};
> +	struct mhp_restrictions restrictions = {};
>  	u64 start, size;
>  	bool new_node = false;
>  	int ret;
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

