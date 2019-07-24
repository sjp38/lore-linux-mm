Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0E0CC41514
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:45:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F19622387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:45:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F19622387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F9E18E0003; Wed, 24 Jul 2019 11:45:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC086B0008; Wed, 24 Jul 2019 11:45:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDBAE8E0003; Wed, 24 Jul 2019 11:45:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E96E6B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:45:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so30422901edm.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 08:45:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LGJCMJWyLWrRgKdoukzgZ9P3DUyBkfggf10cUsmA/ms=;
        b=qmtXVGwOn1CcsW5DxbH1v0eDYWNfEMm8Q/iFPiLCDL5cMAr7pLeZP7aqBsUYIEaiGQ
         og1NkCmN5b7z3dWf024TFN1mqInZZZHgG5mq9rPSW6YZFmwXwplADhGRrZQ2FsQm729e
         hIVMRl0fU3Y9Yul1Vp1/wGZFpLmHNKOFJYP3mGqIzTjyEGAYQOVHCDEpe3gMgfXYwUye
         Xlx6p6YtctJHCQ/j3nXveNM71GqTzlxqCtJuYCgkxcw29gokzErK6elDDfu8OSK3Lb2O
         w6yP03ufg4dnQy8u7KOJ99XpqTbFi42hXCUAQAxtfJDS4Td06uOE6Q46vWAjoZl5wTkO
         SFRw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU208ocPbOq7kdM4vPAJ/3FgGjAUBk26jvWlMvGDzh8PxqA7E3M
	U9ZMGKTJr6notHaQleL8pqZponcqBiQdMutIyYz0pi4DSW8miYntowHzv0zjhcLhckmRoVLBAa7
	1tuYs/maN1y/TG1vD1vqsmUpLSGDOsOz6eoQUKsoLhYjWBWxlZG88/O/dlyI2X9M=
X-Received: by 2002:a50:fa42:: with SMTP id c2mr73091726edq.48.1563983135196;
        Wed, 24 Jul 2019 08:45:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk5ektYMwYGtLxzmkwWN7qvfmuZhQ60gyQQK8idjWYeu6glyqMZO7njHE2J9zzCsHDk3Y0
X-Received: by 2002:a50:fa42:: with SMTP id c2mr73091647edq.48.1563983134369;
        Wed, 24 Jul 2019 08:45:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563983134; cv=none;
        d=google.com; s=arc-20160816;
        b=PT6XrzNHkPIDW7IRG/tnjJJGTT7osycEfH9AB/Zvvq178tswxtLZgokp+hQ6qB7wgf
         /2Z9w5U3Aw1q6V2Jt/wfcF1/HiNusvhfIM5BE7DNb9myZlEb30emT87Cl5OAaNYZiCYd
         o2IDBkMS5cBoLKpcHgePo+x0X7EC5AJGGBBAVLt/nKFohgzniQmhmKo3nge6I/ToRFGn
         8WcBPm27qqOk3cmUKG5AScprYiGmtZ/GnXp9O990VYfPewcv/CntdZlNa6lChZDyogOf
         cN+hP8PG7ftOIz2ME5HeO9MbSCW4Rg62h1ZmjrpNtINzZVCfzvdPzyyB2B3BBN2fAMoR
         h0jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LGJCMJWyLWrRgKdoukzgZ9P3DUyBkfggf10cUsmA/ms=;
        b=c1ybtqi7aqKTB0yveQE09L2Nbealu6B12iX0ZJjTqF17UyBGxCRt4b2/D1LJapA799
         gWzncwXQkybi3/XnkFF5QUsoTPHkrOCJ12zhk/04z3ARZjhaucecYURfVuELWnPxKaf7
         VgvBERqgGNffpXDDSN/kwR1dn0EWhmBP1kClQLrDmT4cq9RLlAJMUiWBvtPEFXnI4AZq
         IYY3ewqtOx2tOSPHGGxJIO/U1BSvuS7yhxw1jwIxw/cPFyKCCZkjZgi5NMrt+LmrBPWK
         aqiVTvgaoEMYRj1Jn1SuFz5D+b2g9jyy6q4SZAnlzqmG72e7lLnO8IIg/l4tXFTYt7fp
         +NLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g41si9318726edc.339.2019.07.24.08.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 08:45:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 79B36AE96;
	Wed, 24 Jul 2019 15:45:33 +0000 (UTC)
Date: Wed, 24 Jul 2019 17:45:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1] mm/memory_hotplug: Remove move_pfn_range()
Message-ID: <20190724154532.GE5584@dhcp22.suse.cz>
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

On Wed 24-07-19 16:23:24, David Hildenbrand wrote:
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

Acked-by: Michal Hocko <mhocko@suse.com>

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

-- 
Michal Hocko
SUSE Labs

