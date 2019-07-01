Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55EAFC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12363208C4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:52:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12363208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A7886B0006; Mon,  1 Jul 2019 04:52:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9596C8E0003; Mon,  1 Jul 2019 04:52:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81F4E8E0002; Mon,  1 Jul 2019 04:52:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id 35C316B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:52:33 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id y3so16360929edm.21
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:52:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JEej5XKfmDYhCLRfey3JFTW9Om3gnuSkjK+xcG6vL/k=;
        b=HO/L0J0+YbOYG/gRuLKm1WD4jXtgKPz+3OhrouCmbZmYL5ixzRfFDdvnUlPuQ7V0mf
         YyyeQ6Dmc/C4ewgGZ0aHmMnclgSUD5mErBIRonK/GYttx5VaANnT493LLIGLmdLBT7YJ
         r9PSKE0+fqoDgtZGLAkbJU5JOPceHQlPUXH3jpJ9XJxzZQUbYzeKWah4Vz+MKa5D4DJG
         nEYYCvcSKB2Eqog5Kmo/AojC+NBdUXyICx/+FmPQAarwbsVh/D7s4NYUtkcTEr5MccUU
         mwpiryKzhiKg6UGWJNa/j5u9y4jjGPJ3EBDDuukeN73s/3kv2VPdsytyf6rvF0WTKyM9
         liOw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVjqj6GFTm4fws9Gz4G0XSTweDzxxzyYdA7U4UpDolaaJSuTtfw
	zyMPBLidQppFa6i/0a/j5GBwKW83lULKqv8nF3pcfRQ+O/7YIEGh9Uf5G7PFDNFQ+n8gNQovgE8
	F3qPlJw4n5IZz2FNdLVzzgCqxxJoZSp2FW6CjZw0pB26B5kRdGHPq9Kv4nPoH0jk=
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr28206295edt.149.1561971152775;
        Mon, 01 Jul 2019 01:52:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBjNVF+QpVjsYPTijZavNhCd+o5M8wwfZlb8oiFifPtHzZwqohEL4cU1qfpgPw4cB80N5Z
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr28206252edt.149.1561971152125;
        Mon, 01 Jul 2019 01:52:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561971152; cv=none;
        d=google.com; s=arc-20160816;
        b=wFcjS2vLmxFvrYWebFBqIm2Z3pL20deYsQpoT/u5hr4WMhyz1l9XDKZJVOG3LXCFG6
         ODfKb7CZtbHnp3RbhsVRQUNNtEs/3owvarfq3PjPERGXzYr3RR4H6GVxsD0SG1JeyYjK
         gv/qCYxiaBifwRzMs6bCON2qZk2C3Dt1VSlxVfhu5+zr8JIeQPPrKGWTh+tnaSJPkih/
         6y/ZzOhkxy643TTSxxIo9ycuBmey55jHWoZ9pURVhKn24ogK9vNgnFvaQnnFvpHGFEgb
         8NPk19emZFsO7Y2ZX+YZHS2RoivO8SmcsJIRuWZeY9GL8UwE4P9zkehAZC9ea3BIAxLG
         XEuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JEej5XKfmDYhCLRfey3JFTW9Om3gnuSkjK+xcG6vL/k=;
        b=TjQP3c+C7bNV901JA9NM00PfVp2Tj5c9k0ggg9S/ivS1UqPgz5bJNV7Rdr4P/VOWTB
         /+1f4G8S3YRTbIns/1msHoXWm6fR7fLpQRk7ia96M6uAqgjvm/wuuz2awTRM9l8PoK4u
         CTQhjJWxZN5/tUG0YKR1Ux5ks9ZH5SJMv1gnU/Z9B6GHnodyQlMdPkiAkjgpKopPcUL/
         czPkY+LMk/wFZJH8t7Fkpdggghse8agITTh8bVVMRJYlnW5p/P2HDg4wph8xmx2JZ4Gt
         KC6+UqvUFbZc/0SLKPZeTZk2Gr2fuEGGiHGZKglpnFuoU3IMwoA1HNBZtrw6lMo22GGR
         AscQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si6918240ejd.385.2019.07.01.01.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:52:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AE529AD23;
	Mon,  1 Jul 2019 08:52:31 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:52:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH v3 11/11] mm/memory_hotplug: Remove "zone" parameter from
 sparse_remove_one_section
Message-ID: <20190701085231.GK6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-12-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-12-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:52, David Hildenbrand wrote:
> The parameter is unused, so let's drop it. Memory removal paths should
> never care about zones. This is the job of memory offlining and will
> require more refactorings.
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memory_hotplug.h | 2 +-
>  mm/memory_hotplug.c            | 2 +-
>  mm/sparse.c                    | 4 ++--
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2f1f87e13baa..1a4257c5f74c 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -346,7 +346,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern int sparse_add_one_section(int nid, unsigned long start_pfn,
>  				  struct vmem_altmap *altmap);
> -extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
> +extern void sparse_remove_one_section(struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
>  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
>  					  unsigned long pnum);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 82136c5b4c5f..e48ec7b9dee2 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -524,7 +524,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
>  	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>  	__remove_zone(zone, start_pfn);
>  
> -	sparse_remove_one_section(zone, ms, map_offset, altmap);
> +	sparse_remove_one_section(ms, map_offset, altmap);
>  }
>  
>  /**
> diff --git a/mm/sparse.c b/mm/sparse.c
> index d1d5e05f5b8d..1552c855d62a 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -800,8 +800,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
>  		free_map_bootmem(memmap);
>  }
>  
> -void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
> -		unsigned long map_offset, struct vmem_altmap *altmap)
> +void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
> +			       struct vmem_altmap *altmap)
>  {
>  	struct page *memmap = NULL;
>  	unsigned long *usemap = NULL;
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

