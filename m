Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24856C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA2C722ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA2C722ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 714616B0003; Fri, 26 Jul 2019 07:09:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C57B6B0005; Fri, 26 Jul 2019 07:09:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DC1A8E0002; Fri, 26 Jul 2019 07:09:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 128236B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:09:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y15so33917461edu.19
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:09:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dDbcwl7Bs+mn1YNTK1xlD989BeivSdEtGkH/XWYFPQg=;
        b=oansGGuA2WYaCauFf0LaD2b63GCbeNu+hMPAolzMjLh+bw2Ko3o8bd18yC7pWyVhWJ
         mXIwDJFZz7J1ieVH6y+rkF+yBLwxcePCAnoAcGw0qsXQIShpc8BeTQ2ZN76Mnl1ET6EC
         SfOFh+hDb34Zt0lS+uTUkESoIOGcyBfSTh9z+KoksuyzWjDWhFG/EWFSokIOCcN9m+CU
         t34xai2kwneElbPyMJ8yICnZQlugOJeHM0KkRXoU/1ldUlC/H9U8Phko8/y4q5paRR8k
         2YNaUvBEllVS9QubbgWZwdhrmzpA2sHAAtp2biPUj1wTYI4yt1UZguZztCCkIMjU1+EI
         e/9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVdyP54tP1Cnkqiog+SM/7Pdy9Kfb0WLQYTOqeJp63SI9i6bhNO
	cQWYb1gIIzeTd50bUQw4zRrFW3RtVZ0kbgA+L8Bmgo+Lw+Zx5FCnwYdOkdzWT3s5xcApbWnYlcw
	f1yNYI2SLL/fAAmiK6+rJ3s6swfrT/jNfkPP+bnswG5pPMdo3TMfsJqamwTbb6ESWDQ==
X-Received: by 2002:a50:b48f:: with SMTP id w15mr83170144edd.260.1564139381663;
        Fri, 26 Jul 2019 04:09:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGEndIION52yqvyYsBFg04H8ujB+H9hx084pTCaCtxqWnEpxJjMo4Kpi7GWLBAN4HR0NhS
X-Received: by 2002:a50:b48f:: with SMTP id w15mr83170079edd.260.1564139380869;
        Fri, 26 Jul 2019 04:09:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564139380; cv=none;
        d=google.com; s=arc-20160816;
        b=VZJRWH0UzMZexrmTwomLmIpSOQPlvd11w6DedYTQGTUEWYVvMp1n2jeOTHWMzCt2yg
         SONUMGn492yi0incIejohod4bSGLWzLumOV+81/6T7MwR6PlMTOTQ8OpZ9gJQ/LgkK3W
         n7Hit1DZp8gYVlstjrSv5FLLqCyo/KBS6wWvm3Ylj4kYfLGwNr8/oT2d3vZoyZ4nnOpw
         xvZ03GbHf4Wz3iS2o7Jakqjq2L3ao0LZVnzWIzqQ+SSDfDBqTOt9NqQay0EFgKqOWREe
         W8KalfnnijF/rKDFolL1bH9uN2teoP4IcC0o2s+maMIwrCuZgIGNiX/kEk66L9S4+U3J
         tvwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dDbcwl7Bs+mn1YNTK1xlD989BeivSdEtGkH/XWYFPQg=;
        b=UCrGB3JXsGXxqJXV32vs/WczCb/s61uf/zeLj9Qelx8UIU+KktMH3o6f4ZbJ6uvo1d
         OGeykdtGmHls+hpRWvRZcxL5FuKF8T3aFL2P954W9lT/0ru9QSArMUR1TXnav+fHX86l
         sn2MX+Yltf3TmSaS4HhKM0INNBBL51tVyzWc8SbWqRz7AGi9RfRpkAqbFUicRp2UUKNF
         TKEDKPpZweElRYsiJ6r8y/sNK68zc6mOGQ7iDiCPWFWp1i8xEBjur8GCGqxswjQnTd5a
         Dj1PgUIdG7c2V/BSZ5gLouTAJr3DVs7QocdaZpsQEV5UEPHKd6THB7jRxo5i+22DVk0M
         t61w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mh23si10615312ejb.224.2019.07.26.04.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 04:09:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9229AD12;
	Fri, 26 Jul 2019 11:09:39 +0000 (UTC)
Date: Fri, 26 Jul 2019 13:09:37 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1] mm/memory_hotplug: Remove move_pfn_range()
Message-ID: <20190726110933.GA27545@linux>
References: <20190724142324.3686-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724142324.3686-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:23:24PM +0200, David Hildenbrand wrote:
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

Reviewed-by: Oscar Salvador <osalvador@suse.de>

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
> -- 
> 2.21.0
> 

-- 
Oscar Salvador
SUSE L3

