Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56A1DC10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 079B9206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:18:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 079B9206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86C646B000E; Thu,  4 Apr 2019 09:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F36C6B0266; Thu,  4 Apr 2019 09:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66E2A6B0269; Thu,  4 Apr 2019 09:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 406E46B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:18:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q12so2233279qtr.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xIFyU0g7+ujwt19CcuikMcQoyl8oTalouPTnxIrQzLE=;
        b=Q7PqmkZIYHaVaEqLtHk6ybN8C6t8SmBAZHXeOx7Kt8z5mxh/K1+vSg6UXqRyyjQ0kg
         OSwEvNf9l9hS9nJ4jNtnqllM8615n1IbgpwVa4B0luve25HtIRrE27SE/diowYzvoKaL
         jJ5cEL613AqWmawauR/n4cMpLTXgVU3FfnDVaQ4G2MUYA7tDDVTodTQLK8bZdf5sS8dP
         oHfHyGX9dD93ZjCKsySQBi8uH6lRCyyl+KzhcVnEZGVYuXOxey44uxHoOlckClfFyxHt
         NNv4dg0ig9kFPGPNdnlSEtJxVBi3YWthpV/+7AOzxrbKo6nQLnDQbk4hnfMm16BcS4kb
         5uig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUW9V/KXOkxntODbCDtMkO+sbOxCTzb7Nmm8LtprQ9PhtK9frL+
	0F1SXuEb5fvuP5S+TIcwu60UMG2Ni1CqNa56+XQCeTOCmzCCCD7J8ixcMsUclSrnkmYjG7hgiOI
	XNNXEresr57rYYC+sJMPoXwPhY+d2BTn9Fju2ld1+cS20GSVQhyvksDWEwSDf2YJzaA==
X-Received: by 2002:a0c:b524:: with SMTP id d36mr4657055qve.48.1554383885002;
        Thu, 04 Apr 2019 06:18:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Vh8jeYvM+0reYNNsf+uCGQ7aZMEXUDR6jrV+kbxtnkGRLv4Ekz3qhD4VWliXf8n35shY
X-Received: by 2002:a0c:b524:: with SMTP id d36mr4656984qve.48.1554383884236;
        Thu, 04 Apr 2019 06:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554383884; cv=none;
        d=google.com; s=arc-20160816;
        b=ZgOLAun4wJxPlf8uwcoioAzXqdUIjePWNuR8ZGLWW1oTBV7noYIS29bgGKcvUUjPtR
         lsE7F19sdktEJ0UVWhxG+8MgdHhAVtDhQXCb0/DY4R/M4EZ5u5blM5M3M/cS4LIEUG8F
         9p7oKea8MB8K4m44MABMGvmbf5/Y1SXwz98kLvhoLZTrSta2wYXFIpfkidsSHtQWKOo9
         BFW01Fc91op9tT2L9vKhNZAKeiTZHldRdgSmwv3U5o/8WQUo+kySSjt+SSHHVytB+C2d
         aXLX6N816r0EblgW4EASboMYMOjyXVJi9TJ8jr9eAqZXk4oncGrw86Xp0LuOV1f7+wzU
         fTgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xIFyU0g7+ujwt19CcuikMcQoyl8oTalouPTnxIrQzLE=;
        b=NQ6OMZ3weoHhb/86uC3eSixAjt+e3Q57RRs9k8yfXWMkP0sEYA7qpbpOMvNzq2M/tZ
         bMvA9/20PJcdyr8vsX8dVkNya2oyhwtr7bVMCAbmv1BHmqP8KdLgUJYtFG+drlewu19q
         2728eAyQMEh0Vqojpoo2CZ6k40V/2iP5AU/naNr6OuLrTuOxDNySbVr2TkWG6mdkVyN8
         rLM6/Mil1t/tIoZFyUO260FSPH37aupTDStRfoBeDQcoCJvqGSIs5SMHxJtyEeXExeiC
         xaGUYM/0CgnIBbhgcmkBZLeCzKwquTUbKQltGqXjPGJz4kY/+7iA/a5Bsjz0jScscNQ6
         IjAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z64si10965417qkd.222.2019.04.04.06.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 06:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64F84306D338;
	Thu,  4 Apr 2019 13:18:03 +0000 (UTC)
Received: from [10.36.117.116] (ovpn-117-116.ams2.redhat.com [10.36.117.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 360B26C77F;
	Thu,  4 Apr 2019 13:18:01 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-2-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
Date: Thu, 4 Apr 2019 15:18:00 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404125916.10215-2-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 04 Apr 2019 13:18:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 14:59, Oscar Salvador wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> check_pages_isolated_cb currently accounts the whole pfn range as being
> offlined if test_pages_isolated suceeds on the range. This is based on
> the assumption that all pages in the range are freed which is currently
> the case in most cases but it won't be with later changes, as pages
> marked as vmemmap won't be isolated.
> 
> Move the offlined pages counting to offline_isolated_pages_cb and
> rely on __offline_isolated_pages to return the correct value.
> check_pages_isolated_cb will still do it's primary job and check the pfn
> range.
> 
> While we are at it remove check_pages_isolated and offline_isolated_pages
> and use directly walk_system_ram_range as do in online_pages.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/memory_hotplug.h |  3 ++-
>  mm/memory_hotplug.c            | 46 +++++++++++-------------------------------
>  mm/page_alloc.c                | 11 ++++++++--
>  3 files changed, 23 insertions(+), 37 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 8ade08c50d26..3c8cf347804c 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -87,7 +87,8 @@ extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
>  extern int online_pages(unsigned long, unsigned long, int);
>  extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long *valid_start, unsigned long *valid_end);
> -extern void __offline_isolated_pages(unsigned long, unsigned long);
> +extern unsigned long __offline_isolated_pages(unsigned long start_pfn,
> +						unsigned long end_pfn);
>  
>  typedef void (*online_page_callback_t)(struct page *page, unsigned int order);
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f206b8b66af1..d8a3e9554aec 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1451,15 +1451,11 @@ static int
>  offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
>  			void *data)
>  {
> -	__offline_isolated_pages(start, start + nr_pages);
> -	return 0;
> -}
> +	unsigned long offlined_pages;
>  
> -static void
> -offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> -{
> -	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
> -				offline_isolated_pages_cb);
> +	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
> +	*(unsigned long *)data += offlined_pages;

unsigned long *offlined_pages = data;

*offlined_pages += __offline_isolated_pages(start, start + nr_pages);

> +	return 0;
>  }
>  
>  /*
> @@ -1469,26 +1465,7 @@ static int
>  check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
>  			void *data)
>  {
> -	int ret;
> -	long offlined = *(long *)data;
> -	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
> -	offlined = nr_pages;
> -	if (!ret)
> -		*(long *)data += offlined;
> -	return ret;
> -}
> -
> -static long
> -check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> -{
> -	long offlined = 0;
> -	int ret;
> -
> -	ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined,
> -			check_pages_isolated_cb);
> -	if (ret < 0)
> -		offlined = (long)ret;
> -	return offlined;
> +	return test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
>  }
>  
>  static int __init cmdline_parse_movable_node(char *p)
> @@ -1573,7 +1550,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		  unsigned long end_pfn)
>  {
>  	unsigned long pfn, nr_pages;
> -	long offlined_pages;
> +	unsigned long offlined_pages = 0;
>  	int ret, node, nr_isolate_pageblock;
>  	unsigned long flags;
>  	unsigned long valid_start, valid_end;
> @@ -1649,14 +1626,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  			goto failed_removal_isolated;
>  		}
>  		/* check again */
> -		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
> -	} while (offlined_pages < 0);
> +		ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
> +							check_pages_isolated_cb);

indentation looks strange, but might be my mail client.

> +	} while (ret);
>  
> -	pr_info("Offlined Pages %ld\n", offlined_pages);
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
> -	offline_isolated_pages(start_pfn, end_pfn);
> -
> +	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
> +						offline_isolated_pages_cb);

dito

> +	pr_info("Offlined Pages %ld\n", offlined_pages);
>  	/*
>  	 * Onlining will reset pagetype flags and makes migrate type
>  	 * MOVABLE, so just need to decrease the number of isolated
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0c53807a2943..d36ca67064c9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8375,7 +8375,7 @@ void zone_pcp_reset(struct zone *zone)
>   * All pages in the range must be in a single zone and isolated
>   * before calling this.
>   */
> -void
> +unsigned long
>  __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	struct page *page;
> @@ -8383,12 +8383,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	unsigned int order, i;
>  	unsigned long pfn;
>  	unsigned long flags;
> +	unsigned long offlined_pages = 0;
> +
>  	/* find the first valid pfn */
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++)
>  		if (pfn_valid(pfn))
>  			break;
>  	if (pfn == end_pfn)
> -		return;
> +		return offlined_pages;
> +
>  	offline_mem_sections(pfn, end_pfn);
>  	zone = page_zone(pfn_to_page(pfn));
>  	spin_lock_irqsave(&zone->lock, flags);
> @@ -8406,12 +8409,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
>  			pfn++;
>  			SetPageReserved(page);
> +			offlined_pages++;
>  			continue;
>  		}
>  
>  		BUG_ON(page_count(page));
>  		BUG_ON(!PageBuddy(page));
>  		order = page_order(page);
> +		offlined_pages += 1 << order;
>  #ifdef CONFIG_DEBUG_VM
>  		pr_info("remove from free list %lx %d %lx\n",
>  			pfn, 1 << order, end_pfn);
> @@ -8422,6 +8427,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  		pfn += (1 << order);
>  	}
>  	spin_unlock_irqrestore(&zone->lock, flags);
> +
> +	return offlined_pages;
>  }
>  #endif
>  
> 


Only nits

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

