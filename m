Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C120C74A23
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:24:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA8E82086D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:24:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA8E82086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D0558E0079; Wed, 10 Jul 2019 10:24:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 381678E0032; Wed, 10 Jul 2019 10:24:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2706F8E0079; Wed, 10 Jul 2019 10:24:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAD748E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:24:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so1504027edc.17
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:24:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ck/YeyAaKtna4PjEWRnG32x3dv0rmRssT+mcO4Vtd3k=;
        b=a3J9wNdXUyaJXkhsPOXQMhtBKzDE/jke3CXPISfJax3Z9XMk8dMC9oWiYTNdUpRA1/
         m6HJ8vLK370sqL29lGeyUimYxaxQ72+WpZQqEmfamq9UTVCy3XMrd24FzZUYBQ6gAZcF
         7LKHyolO538bzQSoD0nD7/xQmTVHzl7iiJK+fr1/1VOfJ4taPFKmVGUbfkaBgH95KyJq
         k8Bqh8RKksVusCWgrsnt5lfQfU8tjVUyq20FSfZBaTfwvKM6A7aBftHlTZ2ZbUlM8tGp
         RCOlTJ5LHEHsvxGUGVrJ+jwsy+qX8aPb9zGEcLa0q9DWhuJmWiiAwtZ0RUDaZ7zXr0QU
         l2zQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXyj0nEmIUiHzhB7CCcOxYdKNEVTxLC5vCFPTA/KOGrupuw7dqW
	ZFcNqtnYETIYN8tyh3iuE9+iXKDWU9VwVPrShrsIVA3DsVnf7r7pUxNFKDddPpe0ZdjeBnhllt7
	v8FR6r7kFquhBFPqeZ0o2S5j94wDO88kjRsRhLfwAhqwurkV1ttWGCVUieqbF2vU=
X-Received: by 2002:a17:906:6b53:: with SMTP id o19mr3830400ejs.27.1562768695305;
        Wed, 10 Jul 2019 07:24:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVwhOnpIj7VQgb2MLEvwJXSSmXnzeSNz3Fk0FKY8P4KdYH13bpvjsys9YSU2nd0oUCF36y
X-Received: by 2002:a17:906:6b53:: with SMTP id o19mr3830343ejs.27.1562768694528;
        Wed, 10 Jul 2019 07:24:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562768694; cv=none;
        d=google.com; s=arc-20160816;
        b=nBrMmb/pDbxXbb6/uKR2q5P7dNP7kAFo5av1/aeO1ciDpuzrNuiR8vqSq520i3HRmi
         wNezSBxVFXfdumrDrkTDyl5NaSvGo/dBl63x61Mah5H2g2g4aL1zMkvGKgNeaGpBbHPh
         vROAo8buFCGJhcHxVB74pGYk496Zqiz3p+axp6wcKhub2WXrqwjh6jNlXfCOaaW39Bd5
         jjyIvSGFBj24GtZCRZBBG08OSxBnHCWK0yrw049d9nFQz55S4AdPqacgf3bLlkWs8xyb
         EBUmPp7qPsg4G9ZmcLBw09TCnNGDGaG/650jHcnIR4AiC6zbdKppkGoFnzhYLhQa1/UC
         mLpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ck/YeyAaKtna4PjEWRnG32x3dv0rmRssT+mcO4Vtd3k=;
        b=MxObi6SCcz42Zt/zWeKVO72NfJJQEXuqynZRhU2YSLKwgtueiXMw9vU8ocWePeWbag
         1u/CrXT+O0sE+muhYTOCoP/GjFoOmKgy8BISs1iSf2nP65U9Cxr5pjgmc8MQ2kFeDXIX
         aQW7hcgSojXTRGdM/k3Do7BPFj2acDXghLvnFLMJSaAl+jztNTrap0EBgUYRQnHCp5F9
         xHb9tCDq7xZ7068Y/d7QFhdC9xJAdmtmkFBWdUKlGmFp/bMBdu7w59BUBEFirAUKOaBW
         jsikgXIBBGrnqVSlVlO/4MmyYZD82930TdGX07hrmHze+1OnuUOd8HK40vViC7iYmxGk
         6yBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si1270013ejz.322.2019.07.10.07.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 07:24:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98CBAAE62;
	Wed, 10 Jul 2019 14:24:53 +0000 (UTC)
Date: Wed, 10 Jul 2019 16:24:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Denis Efremov <efremov@linux.com>
Cc: Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: remove the exporting of totalram_pages
Message-ID: <20190710142452.GN29695@dhcp22.suse.cz>
References: <20190710141031.15642-1-efremov@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710141031.15642-1-efremov@linux.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-07-19 17:10:31, Denis Efremov wrote:
> Previously totalram_pages was the global variable. Currently,
> totalram_pages is the static inline function from the include/linux/mm.h
> However, the function is also marked as EXPORT_SYMBOL, which is at best
> an odd combination. Because there is no point for the static inline
> function from a public header to be exported, this commit removes the
> EXPORT_SYMBOL() marking. It will be still possible to use the function in
> modules because all the symbols it depends on are exported.
> 
> Fixes: ca79b0c211af6 ("mm: convert totalram_pages and totalhigh_pages variables to atomic")
> Signed-off-by: Denis Efremov <efremov@linux.com>

I have to confess I am not entirely sure what the export actually does in this
case. I _think_ it will simply create a symbol and the code will be same
as the static inline. But it certainly is not what we want/need.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8e3bc949ebcc..060303496094 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -224,8 +224,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
>  	[ZONE_MOVABLE] = 0,
>  };
>  
> -EXPORT_SYMBOL(totalram_pages);
> -
>  static char * const zone_names[MAX_NR_ZONES] = {
>  #ifdef CONFIG_ZONE_DMA
>  	 "DMA",
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

