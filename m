Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7CCDC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:47:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B806820881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:47:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B806820881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370DB8E0002; Thu, 31 Jan 2019 01:47:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31FB38E0001; Thu, 31 Jan 2019 01:47:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 210158E0002; Thu, 31 Jan 2019 01:47:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE9088E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:47:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so871468ede.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:47:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8Bl2/VI7OFywD7LEFPhh6EmryvSnC/C/hrVp2tQ+wJA=;
        b=DcjTeJkgj3Jx2CK5iG2QLEKLpzhAO8W1iO4fcNgQ16BGirqDtRu6eBkss8Lu4of2wJ
         Z+hMnU2mB0wwCkwcZban1oQ25sEjlx63owQl4AIWqGPhg2rRKCP0J4hWDVB1cNKiB5zO
         ZEXIif4VY5UXaRamAqz8x2yoLqli1/y8evHQHVlrRNw710HlqDc3RlhNYMjjgKiqQElb
         vJXxEpZegQOZDS6IRebWFXcLi9P0gfmFI6H5ZEnpVASgrNWtwviutTzsQ6gyS8R29XjF
         1egRDxEbqrKm+seXUrX6Y2+6ucTnGhiEsQzmixd3BXanpoH5h8bJmoHQmA/nRLwbzzo/
         NHXw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukelj2mPUtt8/2jMJk/uxR8AJSCsqcROUQEUTFQIj0SXtK5x5shY
	bXUOTjKCTXh5v6TQ0tSYuawW8HRfzxLyyWGlfgmeU/VLmoqsQtPuD5NAw4MFHoH3afG7Lhi3p0J
	kN/lddsGK4gt00+rMBrBb7GqIQ7BPx/vpcJcLnjSFmTyNfugBYqR606u190R3ExU=
X-Received: by 2002:a50:9977:: with SMTP id l52mr31403513edb.277.1548917256214;
        Wed, 30 Jan 2019 22:47:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ojOkuYojOt2pICo+pQW7ia6iQczO+fhK1NM6Mm98UzQK6jEK7dDAfNtYDGod/gWwcQwXa
X-Received: by 2002:a50:9977:: with SMTP id l52mr31403471edb.277.1548917255347;
        Wed, 30 Jan 2019 22:47:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548917255; cv=none;
        d=google.com; s=arc-20160816;
        b=PcS9K6ULD8PZNz+mjtiwu/z/+k7xEnKsFLurrb0FyaDRLEQ+7Ff5xP8PkbNL1qs43d
         8lQaYI42HGXMqoZy0Yl+5bY448GDJCAmVYrnLU0MryEUweCryXaNKFnccFlrXrkbxJeJ
         VxSN1eyDfPSx2z7NKJhqtLr9wqwDSBClWOMxEVOxaKuhFV9oo5z7ljdC1dwayoI4skYE
         8BHdr8l3ocub/A31y/znJFUn3TV6oHr9iH9fXz+/T7iB2QyeVdM3psgdwQ0nxCIQV726
         los1sraeLjtyFOW0TBkkpbM/7z3ht+vVUE5k5dnxH30x/gPR/8xBjybO/2hftWB55kRJ
         Ws7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8Bl2/VI7OFywD7LEFPhh6EmryvSnC/C/hrVp2tQ+wJA=;
        b=aBVQRh6woEEHNlzS5D3sbwxfsbLMK5PsACV+Mxx3jdiEx63WcNJWPbhfGu9hqrwbLF
         7Hvtj1HOc+DDUhyPe5ucU8wju06Ihk9ht3p4cfue7Hhg2F102koJQ1dbjnJvzREjAIr+
         y381JgZpM7J8k1Rph7xrNGjtKM8/2DrA3cLJsfPPgGq8lJfz9u13dVti6O97tek6EmKK
         S1knAQsK+6iG91XaQLbBMexYMcfvgnMlW7dBsNhx7K6ll8aWNrvVFycbEoXwociSaTjh
         LJlT6Ip10VIodl20IQkmws1kl12JdOjMH8xLS4mBELcKotU9AI97Yt+VpENCC8EkdR/6
         xOAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si2103278edm.118.2019.01.30.22.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:47:35 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C6088B0EF;
	Thu, 31 Jan 2019 06:47:34 +0000 (UTC)
Date: Thu, 31 Jan 2019 07:47:33 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC v2 PATCH] mm: vmscan: do not iterate all mem cgroups for
 global direct reclaim
Message-ID: <20190131064733.GL18811@dhcp22.suse.cz>
References: <1548799877-10949-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548799877-10949-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 06:11:17, Yang Shi wrote:
> In current implementation, both kswapd and direct reclaim has to iterate
> all mem cgroups.  It is not a problem before offline mem cgroups could
> be iterated.  But, currently with iterating offline mem cgroups, it
> could be very time consuming.  In our workloads, we saw over 400K mem
> cgroups accumulated in some cases, only a few hundred are online memcgs.
> Although kswapd could help out to reduce the number of memcgs, direct
> reclaim still get hit with iterating a number of offline memcgs in some
> cases.  We experienced the responsiveness problems due to this
> occassionally.
> 
> A simple test with pref shows it may take around 220ms to iterate 8K memcgs
> in direct reclaim:
>              dd 13873 [011]   578.542919: vmscan:mm_vmscan_direct_reclaim_begin
>              dd 13873 [011]   578.758689: vmscan:mm_vmscan_direct_reclaim_end
> So for 400K, it may take around 11 seconds to iterate all memcgs.
> 
> Here just break the iteration once it reclaims enough pages as what
> memcg direct reclaim does.  This may hurt the fairness among memcgs.  But
> the cached iterator cookie could help to achieve the fairness more or
> less.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v2: Added some test data in the commit log
>     Updated commit log about iterator cookie could maintain fairness
>     Dropped !global_reclaim() since !current_is_kswapd() is good enough
> 
>  mm/vmscan.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a714c4f..5e35796 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2764,16 +2764,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				   sc->nr_reclaimed - reclaimed);
>  
>  			/*
> -			 * Direct reclaim and kswapd have to scan all memory
> -			 * cgroups to fulfill the overall scan target for the
> -			 * node.
> +			 * Kswapd have to scan all memory cgroups to fulfill
> +			 * the overall scan target for the node.
>  			 *
>  			 * Limit reclaim, on the other hand, only cares about
>  			 * nr_to_reclaim pages to be reclaimed and it will
>  			 * retry with decreasing priority if one round over the
>  			 * whole hierarchy is not sufficient.
>  			 */
> -			if (!global_reclaim(sc) &&
> +			if (!current_is_kswapd() &&
>  					sc->nr_reclaimed >= sc->nr_to_reclaim) {
>  				mem_cgroup_iter_break(root, memcg);
>  				break;
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

