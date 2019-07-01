Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C2E1C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13DDD208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13DDD208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A27448E0007; Mon,  1 Jul 2019 03:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D6F78E0002; Mon,  1 Jul 2019 03:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89FAC8E0007; Mon,  1 Jul 2019 03:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9388E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:45:06 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id s7so16232896edb.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z3bPTTjh5D9oej1MsSQuB+Jm+X0sCwmRgY43Tjksxiw=;
        b=m68ehRKs8YtPsoj5thhsrixYJexPSyDZfDOjVqCTg4uKRVWVYxaMZErNPhkJS5ix0m
         /UsYBabpcEOdxm7CexO5ZSVg4vlhF3qMcSG4bLtce9SX0lhPyrFy8NUO3+eS0ry8U842
         7xRAcATIA+acDEbcnJxOe1DKhXcwwrk8+aFInlTyHn54Bmgb3wdcILZy3mxaX2K1Sc1A
         GEcycs3xLeI+FvcTVsh2Efk6UaD1atQdqQKx9WTuj7Lfal6XePqJp1hnj9be9zRbycEs
         +EWT4akGdJhvnFfkbKjjY58SJ6vjbwp7SIzOfZ7IDX9Y4pdho9vfEiFuwjPVNoV41cTM
         DWtg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUqNTuvQzkcaN8C5K4LERqmFL+f1HJoMbWF/8I0/pZwyxKkkGqc
	jSKBAq12whf0iEJqzrrrYXA3nRPUI3b/z0V4YK4jv20fMQJzYABl2eiLHGlA3OUAclQIU1nwWQP
	UTP9QALt+azyh1lOqY4V7lA5SMW+8pci5pltbE/rO4yuf1803qnYut4OV1IMDHe4=
X-Received: by 2002:a17:907:2161:: with SMTP id rl1mr13191397ejb.8.1561967105823;
        Mon, 01 Jul 2019 00:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLT7+h3o9dUdksk2fMWTWw+AdtRJeDdE8rgGA3mRHKCyR1JXUHNpitsBlW27JsdBpQFard
X-Received: by 2002:a17:907:2161:: with SMTP id rl1mr13191355ejb.8.1561967105082;
        Mon, 01 Jul 2019 00:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561967105; cv=none;
        d=google.com; s=arc-20160816;
        b=eThBDtzorJzwTU4yDUwIG67Xvh/MmywjWeeClPQw/p/0um7FsOinldopQsRPTqjUj6
         hh6RSbhZvl6p/sz6nTHM/bpaS44NjFN29Sw5JwLy+2dRpsYPhilQrJ/6qrHc7+s2voDq
         U2vkb2K2+ZaTsWROS3WCKDvXc3fNCnDhzFwfRZT/QctNSipBXnAuvOrwXa/H1yDmt2jE
         YaE8apSFHrrnGDBSMwH8cpx4fvRLzZfKA3sYVIiQV5RymPfbfwGthcJi/6cBeZhl5ly6
         zF43eN120YAER3teKBArzf9SKdD4+b7GthgZKy944WTGa5Oc998Mv6L+atYxPc9GAU1b
         Gw2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z3bPTTjh5D9oej1MsSQuB+Jm+X0sCwmRgY43Tjksxiw=;
        b=V451Vf6TDX7lkg+Lumx0jhmXhugMJRb2rUgBuge8jK7UsL7h7mpcCM3ZiGC1XraKTC
         Wqa0lr6pUAr7zvAU1hA6k5eR/PQm9NGBpsN7lyhl7cKqvtFnb0oxiqi85xxE+ylvT5HD
         YMFwTotbmkNEhJT0OpzLSU8GIpFqhT4oQjOKRpXJgGjGBBQLZkORuPOBpHdwNr7Ih/zV
         tlcAu3wddDHX72Rwu5gT/gXFIAQOr7dPMlLN0878Oi2C6+ody2O6q/OAxMJvg1uOQUcC
         Y59GYaSa5gUgfOyVd6E4DUY9uACkHb8/gkG8HRJ1ZALiEqItcl14mBJwHbCZbukWbISM
         tJHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si6491532ejc.240.2019.07.01.00.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 00:45:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9C66EAE48;
	Mon,  1 Jul 2019 07:45:04 +0000 (UTC)
Date: Mon, 1 Jul 2019 09:45:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v3 03/11] s390x/mm: Implement arch_remove_memory()
Message-ID: <20190701074503.GD6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-4-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:44, David Hildenbrand wrote:
> Will come in handy when wanting to handle errors after
> arch_add_memory().

I do not understand this. Why do you add a code for something that is
not possible on this HW (based on the comment - is it still valid btw?)

> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/s390/mm/init.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index d552e330fbcc..14955e0a9fcf 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -243,12 +243,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> -	/*
> -	 * There is no hardware or firmware interface which could trigger a
> -	 * hot memory remove on s390. So there is nothing that needs to be
> -	 * implemented.
> -	 */
> -	BUG();
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone;
> +
> +	zone = page_zone(pfn_to_page(start_pfn));
> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	vmem_remove_mapping(start, size);
>  }
>  #endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

