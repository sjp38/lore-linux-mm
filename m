Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1AC7C48BE5
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69CD8208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:07:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lOBd+HVM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69CD8208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 041F88E0003; Fri, 21 Jun 2019 10:07:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F32E48E0001; Fri, 21 Jun 2019 10:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFB858E0003; Fri, 21 Jun 2019 10:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6EC98E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:07:26 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so3694704plq.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:07:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=B9MbqUVZ6G19blzK9C/nkDqisYrvP0LYF0mShhHWuxw=;
        b=DLh7YuAUUKkLdvU56sL+TLnsj0VRnh+uz/P1VmOFjWBCxHf+/6D9SFYJGdTWv/G+cc
         NAPP/pQTRmVv1djd4XdEKntmRaYVxlVAIL7TkykxDq9genU2Y0Rj9x10ePj44MofNKAO
         R4tgfzA3ptrhIMJrqJCRnGuza+PAdE5J6/O7WntGtOF3AjzCqxFjUdm6OvXodyvfTPsC
         hEghve1I9V7uoaL7YA1oyACMla6twkYFHcTabJI3uP4iCekkCFlO+Vpyibx6wot5SQh0
         w6kuCMiqVGhepgxGkaSXrmhKhurG35ARgb3i2mtmDCBi0lLBQFyO9YPRP1UVr5kLolJz
         UjnQ==
X-Gm-Message-State: APjAAAUuDYqdurgu/FoHjPxnesK0otvHfG38RCibPbICX0sCNYJTb9yL
	jWP81qnWc4X4XUZOOvVwSQx5x0hOynYy6Xr9F6WtNStB8KWRd6dMbgZ71Ykj9X2CwqPWva7hzwO
	Dk+l6FXdMZpfH4zlUV96He0ZhLEwLA3b4UhlpsEbErDKkyZ/ffCimirApwuEaxEj2Vw==
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr53839532plb.240.1561126046140;
        Fri, 21 Jun 2019 07:07:26 -0700 (PDT)
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr53839466plb.240.1561126045253;
        Fri, 21 Jun 2019 07:07:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561126045; cv=none;
        d=google.com; s=arc-20160816;
        b=kcd0Q9Pq+8tCsm6Sua+ACKP5VNEWRk+SD9GUIIqVB0W3oukGHQL0DbOrmAUgwD8co6
         8RdrjuhQ7BN1lvdlUGZn+ba4XHHVV3yrrIYRiKWQ/30sELxc3wAAZUWPb9rn0yMQ2CYA
         JPeXsqEHVnS0mjj8Fv/K4JeCfJXk9G0TMxaRUixxK8W9jLrm4o5ysVjJ+GG23pB0LwA5
         8P7C8tFxvknWXQLJ6/y7eMsElMV3JNLeRRU212AraZZh//uud1K/jWsI2DFpNA2TZxhB
         VTO4hL//AYue8PzIMl6i8ibhkBVfh+gFA+JY70aP/RdG0zk+VjIJ4MPaYbblgzjG9UJ1
         ox8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=B9MbqUVZ6G19blzK9C/nkDqisYrvP0LYF0mShhHWuxw=;
        b=QrCRm6SN10aLlmX93eFRlmfTiFORckaWQJOG+wdswCZjhRnBK7goHdgo6cpZe3udMO
         G1SW5KALW0ONBvFzrtXnGhdjKtrhMKkjB3d1CXLUUoRGRmKpvNXbQLoRA7MR5VL48nQZ
         L47k905cYWReAN9wiLN2dShrkf8VJaV2NZV2kkyAoFFbe/+P5bQU6iWF9DaIH1zh7uOl
         KCQqMZbzfOsdamuuQzY2d73TZ9mLnpw4Kmy78vNIjQ6zrmiDd4ojpHAasGhMnHmKr3s/
         B1Qq1AYAW9Xs2TCOZqaQQnf031yxOr+e4uUnJhmkXIFSrne+u0SEm63LOwc11yGHFsWV
         gxKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lOBd+HVM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor4033786pje.25.2019.06.21.07.07.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:07:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lOBd+HVM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=B9MbqUVZ6G19blzK9C/nkDqisYrvP0LYF0mShhHWuxw=;
        b=lOBd+HVMv320N1woFRqwNylMIxbiTQfNRbF/AHuUNBEjxQ7emmCHOkdA8QDk0yLfAh
         aO2GP/DmzWaH4Pg8diNbgfpd9aRePF/Q0xQFQm4ypEqpDDseJ7ogrhg7ogmYI3RPh9I7
         PXsVpwPcJkNnO4FTqXaCs26yhCYK+NKDiWLiUuH1Fxw35ExG6HP1jA5viTTtVW/oyIOd
         s+JdJk6eNsPuy6bhZbdMqmKNfRmn34HWx/VgEHKTxq3fccFUYyCc1CEa1VHYLiWwFBW/
         QT7RzdACqo4tFezRHqjTbdPQX/yAPEjduQwreXBFWMgP6iBIac1GEVLQvo5VrAM4tdOT
         NVGA==
X-Google-Smtp-Source: APXvYqwrRphIx8JSIR9al4LlncdG1rD27NbYACKxsZn0B4B6xTwrmoSIm8B0VLJd/wYsCPFzfkv8qw==
X-Received: by 2002:a17:90a:9b08:: with SMTP id f8mr6983306pjp.103.1561126044926;
        Fri, 21 Jun 2019 07:07:24 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id 11sm3041870pfo.19.2019.06.21.07.07.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 07:07:24 -0700 (PDT)
Date: Fri, 21 Jun 2019 19:37:17 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alan Jenkins <alan.christopher.jenkins@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] mm: fix setting the high and low watermarks
Message-ID: <20190621140717.GA28387@bharath12345-Inspiron-5559>
References: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
 <3d15b808-b7cd-7379-a6a9-d3cf04b7dcec@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d15b808-b7cd-7379-a6a9-d3cf04b7dcec@suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 02:09:31PM +0200, Vlastimil Babka wrote:
> On 6/21/19 1:43 PM, Alan Jenkins wrote:
> > When setting the low and high watermarks we use min_wmark_pages(zone).
> > I guess this is to reduce the line length.  But we forgot that this macro
> > includes zone->watermark_boost.  We need to reset zone->watermark_boost
> > first.  Otherwise the watermarks will be set inconsistently.
> > 
> > E.g. this could cause inconsistent values if the watermarks have been
> > boosted, and then you change a sysctl which triggers
> > __setup_per_zone_wmarks().
> > 
> > I strongly suspect this explains why I have seen slightly high watermarks.
> > Suspicious-looking zoneinfo below - notice high-low != low-min.
> > 
> > Node 0, zone   Normal
> >   pages free     74597
> >         min      9582
> >         low      34505
> >         high     36900
> > 
> > https://unix.stackexchange.com/questions/525674/my-low-and-high-watermarks-seem-higher-than-predicted-by-documentation-sysctl-vm/525687
> > 
> > Signed-off-by: Alan Jenkins <alan.christopher.jenkins@gmail.com>
> > Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external
> >                       fragmentation event occurs")
> > Cc: stable@vger.kernel.org
> 
> Nice catch, thanks!
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Personally I would implement it a bit differently, see below. If you
> agree, it's fine if you keep the authorship of the whole patch.
> 
> > ---
> > 
> > Tested by compiler :-).
> > 
> > Ideally the commit message would be clear about what happens the
> > *first* time __setup_per_zone_watermarks() is called.  I guess that
> > zone->watermark_boost is *usually* zero, or we would have noticed
> > some wild problems :-).  However I am not familiar with how the zone
> > structures are allocated & initialized.  Maybe there is a case where
> > zone->watermark_boost could contain an arbitrary unitialized value
> > at this point.  Can we rule that out?
> 
> Dunno if there's some arch override, but generic_alloc_nodedata() uses
> kzalloc() so it's zeroed.
> 
> -----8<-----
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..3b2f0cedf78e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7624,6 +7624,7 @@ static void __setup_per_zone_wmarks(void)
>  
>  	for_each_zone(zone) {
>  		u64 tmp;
> +		unsigned long wmark_min;
>  
>  		spin_lock_irqsave(&zone->lock, flags);
>  		tmp = (u64)pages_min * zone_managed_pages(zone);
> @@ -7642,13 +7643,13 @@ static void __setup_per_zone_wmarks(void)
>  
>  			min_pages = zone_managed_pages(zone) / 1024;
>  			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
> -			zone->_watermark[WMARK_MIN] = min_pages;
> +			wmark_min = min_pages;
>  		} else {
>  			/*
>  			 * If it's a lowmem zone, reserve a number of pages
>  			 * proportionate to the zone's size.
>  			 */
> -			zone->_watermark[WMARK_MIN] = tmp;
> +			wmark_min = tmp;
>  		}
>  
>  		/*
> @@ -7660,8 +7661,9 @@ static void __setup_per_zone_wmarks(void)
>  			    mult_frac(zone_managed_pages(zone),
>  				      watermark_scale_factor, 10000));
>  
> -		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
> -		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
> +		zone->_watermark[WMARK_MIN]  = wmark_min;
> +		zone->_watermark[WMARK_LOW]  = wmark_min + tmp;
> +		zone->_watermark[WMARK_HIGH] = wmark_min + tmp * 2;
>  		zone->watermark_boost = 0;
Do you think this could cause a race condition between
__setup_per_zone_wmarks and pgdat_watermark_boosted which checks whether
the watermark_boost of each zone is non-zero? pgdat_watermark_boosted is
not called with a zone lock.
Here is a probable case scenario:
watermarks are boosted in steal_suitable_fallback(which happens under a
zone lock). After that kswapd is woken up by
wakeup_kswapd(zone,0,0,zone_idx(zone)) in rmqueue without holding a
zone lock. Lets say someone modified min_kfree_bytes, this would lead to
all the zone->watermark_boost being set to 0. This may cause
pgdat_watermark_boosted to return false, which would not wakeup kswapd
as intended by boosting the watermark. This behaviour is similar to waking up kswapd for a
balanced node.

Also if kswapd was woken up successfully because of watermarks being
boosted. In balance_pgdat, we use nr_boost_reclaim to count number of
pages to reclaim because of boosting. nr_boost_reclaim is calculated as:
nr_boost_reclaim = 0;
for (i = 0; i <= classzone_idx; i++) {
	zone = pgdat->node_zones + i;
	if (!managed_zone(zone))
		continue;

	nr_boost_reclaim += zone->watermark_boost;
	zone_boosts[i] = zone->watermark_boost;
}
boosted = nr_boost_reclaim;

This is not under a zone_lock. This could lead to nr_boost_reclaim to
be 0 if min_kfree_bytes is set to 0. Which would wake up kcompactd
without reclaiming memory. 
kcompactd compaction might be spurious if the if the memory reclaim step is not happening?

Any thoughts?
>  		spin_unlock_irqrestore(&zone->lock, flags);
>

