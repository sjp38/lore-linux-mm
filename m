Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C42DFC41514
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72F1921951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72F1921951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16B8F6B0008; Wed, 24 Jul 2019 11:49:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11DFE6B000A; Wed, 24 Jul 2019 11:49:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25BF8E0005; Wed, 24 Jul 2019 11:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0E076B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:49:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so39622232qkl.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 08:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=u3WNZO46Qtub2HafaFp0g7WtD3dqViZQ5ES67Yb4H7g=;
        b=FnL+zPv1OhVLUdMP5Pczj4s7setZzne0O4l2yzRARpKpQEpzIUN+ashqwtQBHc9zIl
         YzoCkPrLosuWnajOHKR/ZCi52OCzbFn7gXExMx/3GKUvY4/nLzaxpBJX4jnwQh7mwB/i
         saVc46zkKPPrTDbElcp/Vrw0OLT1v9JiWQBm6Qm+vwtFAEu8/t1Ay489Jv9Pm5StzTqg
         L7xuGtXC7l6lf51sMFYnrYL5JPxlpcc34bkAKyanL62bqYgFkspX0myWhtRKVYRlD0r4
         smzDYA1xKEWHQKnrYLGMiVASucC4YpI6cov9Tiwgw+CxL/YF1vdUHVC3adm1P/akqWxL
         IB2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVAfoEAIuruW+JQvrc+AiJTpniaDeWuWTPYRWleNjADlRknhS6J
	Fr9ImmHDw1+j0nQBeQ0n8NVRUDq7PZfl474Y0n6T7gTNCeedgcNEc6Quwx2QjzzctxjSwmctQps
	mW8smTlEms8bAvctkf3pBIodMz8YP3VG/ienuNCXk4T+D1ICzCKCyq+EI8xkV38J8SA==
X-Received: by 2002:a37:648:: with SMTP id 69mr55102721qkg.248.1563983358642;
        Wed, 24 Jul 2019 08:49:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmxwSj5GovLDVc0HKTjQfGlWD4lQfVo9h4RpQgAroM8s9x93N42jBU44qsTV6c07x0P502
X-Received: by 2002:a37:648:: with SMTP id 69mr55102684qkg.248.1563983358079;
        Wed, 24 Jul 2019 08:49:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563983358; cv=none;
        d=google.com; s=arc-20160816;
        b=HFZkPAa+wfPxAV7X7rB0+dVYWvKRTWxbWSpE2UW0I3isGaOk4AVDnMwjonYiGaL9fZ
         JKjOIHDF1USwgG9I1BpGSsBSIIzBeZd/A2HsWVk1cN3Qn3KzARDFHtxpOQz4GNt2KCgu
         T0ZvSLzTL4YqnjbA7Hi1m29KWC9Bx8hrLw9EnPvIkKUJYspvA9KIhlNn0IRDn6pSa4rL
         WDfXdtLdRZ5op2uPlMftEVgHxIyO9DYIbOqiUzKOrY4dlk3zGGWasHvpbOpEiCAYMoFx
         NrFCp3Caw49bhcLva5Dt59ZGhoiM3/QfuPWdPuDImWDTjCuokU513XxALCvhBvpS5UrC
         mZPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=u3WNZO46Qtub2HafaFp0g7WtD3dqViZQ5ES67Yb4H7g=;
        b=Spl3jI4/2pVZwCBKlEEgVYOOqK1iZjb/jhcc3dwieGIdzjYmkqmFqrDMHCE8QVq5BX
         67h8Cl89YfwR6vgszJwwrioGpUbMg3prWErbSfZaCnu7ZG39rwGw/e4hQHg0mmreu52a
         NNHjV+8FMMyaB6AskWhAST5uzvdZEFA6LOXxDaWScAgo03MzgWhEbcld/IiKilar4fOX
         RfxXS9TUkonC8BfoMAYQSugwq+RhAAf4TgpshgWjLjvhMvkD+fqVDoVFOLEimzkAlRvk
         sjtmqzNXtP7gKr+3G8bZXVrwGN6nQzfPzFsdnLpK/cG/dk0n2yexpF2gXLH92s3jEU6h
         m6RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p125si26813931qkc.197.2019.07.24.08.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 08:49:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 362EC30860BD;
	Wed, 24 Jul 2019 15:49:17 +0000 (UTC)
Received: from [10.36.117.47] (ovpn-117-47.ams2.redhat.com [10.36.117.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9D25A60605;
	Wed, 24 Jul 2019 15:49:15 +0000 (UTC)
Subject: Re: [PATCH v1] mm/memory_hotplug: Remove move_pfn_range()
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190724142324.3686-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <13696564-d696-111d-0cf5-b0c9e1a2e051@redhat.com>
Date: Wed, 24 Jul 2019 17:49:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190724142324.3686-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 24 Jul 2019 15:49:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.07.19 16:23, David Hildenbrand wrote:
> Let's remove this indirection. We need the zone in the caller either
> way, so let's just detect it there. Add some documentation for
> move_pfn_range_to_zone() instead.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index efa5283be36c..e7c3b219a305 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -715,7 +715,11 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
>  
>  	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
>  }
> -

^ whoops, deleted this empty line by mistake - it should stay of course.
Can resend.

> +/*
> + * Associate the pfn range with the given zone, initializing the memmaps
> + * and resizing the pgdat/zone data to span the added pages. After this
> + * call, all affected pages are PG_reserved.
> + */
>  void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap)
>  {
> @@ -804,20 +808,6 @@ struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
>  	return default_zone_for_pfn(nid, start_pfn, nr_pages);
>  }
>  
> -/*
> - * Associates the given pfn range with the given node and the zone appropriate
> - * for the given online type.
> - */
> -static struct zone * __meminit move_pfn_range(int online_type, int nid,
> -		unsigned long start_pfn, unsigned long nr_pages)
> -{
> -	struct zone *zone;
> -
> -	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
> -	move_pfn_range_to_zone(zone, start_pfn, nr_pages, NULL);
> -	return zone;
> -}
> -
>  int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
>  {
>  	unsigned long flags;
> @@ -840,7 +830,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	put_device(&mem->dev);
>  
>  	/* associate pfn range with the zone */
> -	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
> +	zone = zone_for_pfn_range(online_type, nid, pfn, nr_pages);
> +	move_pfn_range_to_zone(zone, pfn, nr_pages, NULL);
>  
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
> 


-- 

Thanks,

David / dhildenb

