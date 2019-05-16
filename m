Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C25FC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:59:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AE7F20848
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:59:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AE7F20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C602E6B0008; Thu, 16 May 2019 09:59:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0F766B000A; Thu, 16 May 2019 09:59:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8576B000C; Thu, 16 May 2019 09:59:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC896B0008
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:59:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so5482748edd.21
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:59:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0cibE++XujKfriozpjImYCIOus5tgrqkiGYFn4PuMwQ=;
        b=hletkMg8zZmaXANHwclIVSs7Y1XpNxEDCqawfJmri4sQ7iqtowuLnAYCBSDLFrhx+F
         aj83jReXJErbMH8F8qZSD5XTGPV7NqdM69gJz57ztdiYu1dksQ+qtCDBOWC7R423U8I3
         7rlmGudmCA44GQSqFvCFee7KRxFv0y88Z9AAiN6m7XOQcO8oIboIGlQUxRYfkeqi8g6n
         eGEaf5gAbErDobhivopkeTgpPOv89jR63q4rKjpwykTLd1pFAWJTMhssuXT1rQfTTRYH
         Y/J7vN/bpxszZaRRCM4DIAIpPPdGwPg/b2lJIXPCgPtvNYwtBkuxWs3K0Cxvy4j3mbFG
         fvhA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUjubsbUuh9VfqHapR6luiYRREIMhV2ZbTA7p5Qtb5toxG6AQF+
	kUfg6JxqMRnnHgWVqR0SAxHezENkkWsUC8sPLF7uhwTiTTUCxTxBsK3a9rauVt5e04uSfchBnDR
	IQTm8lgiOH4VFFdYFtCN9OK04Q0K3d9qxDVx/HPVShkYWLtGzaJxZI0YEF54F8vw=
X-Received: by 2002:a50:fb19:: with SMTP id d25mr50661201edq.61.1558015165958;
        Thu, 16 May 2019 06:59:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZAw+oALvYD5PAQzWCzATL5V3P89oMx2Lsp1NTnZW930afurrkST0cD29Al/cCe0wDl1K/
X-Received: by 2002:a50:fb19:: with SMTP id d25mr50661110edq.61.1558015165107;
        Thu, 16 May 2019 06:59:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558015165; cv=none;
        d=google.com; s=arc-20160816;
        b=aT2U8aqdxI6/Ki+KRn97hyNV4Dm02jOLIs5KpndxJS85RK7K8c4RNsxKRIsjF2aZAl
         qAEN197NI+7hxETevrPihq/mleI0j3FGKI983Ccj4FfDnhx967e/Co4Sgmt8NPLLiifK
         vta38p7tA4wx63+9v98IhZW8aCoALE9zSHLhi5Sv0UIC6cmiyDdEhgQaglxaQq4MbkWk
         q6f8TAB9RO933uT+VLE6gYKrYsWBLVIqTpIuTQbMzVkB9G0eus92cy0wA0i7vvRL4j7W
         CfJHbIZGcLNpj/Fbi3uNGFRRJt0+kl7kgEF80sHfI78LhVh8x/GqCA23X+F5VXrhcxcF
         s1Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0cibE++XujKfriozpjImYCIOus5tgrqkiGYFn4PuMwQ=;
        b=KZ0CQJEqcxkAac27cWHqgAnsLKmYVLkMT04ZP28oKdt0xEgLMkBYOAbSeCXZqqZOZ0
         1DPgRU0LeHV15fmPn//8nzvslG0u21fBtsuyMlSaBy8QfERS8cnCOOSqOjtGWZXGTOAi
         70UVxFquaXCfbJWzeoHIju2nWIDCguPD1xOIFec4YKL54FLmIERi8XUu3uieGiCzoP6l
         0p0CiRRV8OMXi4zr3vP9vYjvhjSNDofhviy/B3igplh82CE7UeDEZgun+tTaIHhlsAdR
         FI8f7HVw02n8KL+56HWrm8o4lzDV/SehBc8kS0FCTppvkX8f0/eG/XqsscGfqKRLK27h
         jptQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si2667074ejy.279.2019.05.16.06.59.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:59:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 52070AC8D;
	Thu, 16 May 2019 13:59:24 +0000 (UTC)
Date: Thu, 16 May 2019 15:59:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
Message-ID: <20190516135923.GV16651@dhcp22.suse.cz>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190509122526.ck25wscwanooxa3t@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509122526.ck25wscwanooxa3t@esperanza>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 09-05-19 15:25:26, Vladimir Davydov wrote:
> On Mon, Apr 29, 2019 at 12:59:39PM +0200, Jiri Slaby wrote:
> > We have a single node system with node 0 disabled:
> >   Scanning NUMA topology in Northbridge 24
> >   Number of physical nodes 2
> >   Skipping disabled node 0
> >   Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
> >   NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]
> > 
> > This causes crashes in memcg when system boots:
> >   BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> >   #PF error: [normal kernel read fault]
> > ...
> >   RIP: 0010:list_lru_add+0x94/0x170
> > ...
> >   Call Trace:
> >    d_lru_add+0x44/0x50
> >    dput.part.34+0xfc/0x110
> >    __fput+0x108/0x230
> >    task_work_run+0x9f/0xc0
> >    exit_to_usermode_loop+0xf5/0x100
> > 
> > It is reproducible as far as 4.12. I did not try older kernels. You have
> > to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
> > investigated). Cannot be reproduced with systemd 234.
> > 
> > The system crashes because the size of lru array is never updated in
> > memcg_update_all_list_lrus and the reads are past the zero-sized array,
> > causing dereferences of random memory.
> > 
> > The root cause are list_lru_memcg_aware checks in the list_lru code.
> > The test in list_lru_memcg_aware is broken: it assumes node 0 is always
> > present, but it is not true on some systems as can be seen above.
> > 
> > So fix this by checking the first online node instead of node 0.
> > 
> > Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: <cgroups@vger.kernel.org>
> > Cc: <linux-mm@kvack.org>
> > Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> > ---
> >  mm/list_lru.c | 6 +-----
> >  1 file changed, 1 insertion(+), 5 deletions(-)
> > 
> > diff --git a/mm/list_lru.c b/mm/list_lru.c
> > index 0730bf8ff39f..7689910f1a91 100644
> > --- a/mm/list_lru.c
> > +++ b/mm/list_lru.c
> > @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
> >  
> >  static inline bool list_lru_memcg_aware(struct list_lru *lru)
> >  {
> > -	/*
> > -	 * This needs node 0 to be always present, even
> > -	 * in the systems supporting sparse numa ids.
> > -	 */
> > -	return !!lru->node[0].memcg_lrus;
> > +	return !!lru->node[first_online_node].memcg_lrus;
> >  }
> >  
> >  static inline struct list_lru_one *
> 
> Yep, I didn't expect node 0 could ever be unavailable, my bad.
> The patch looks fine to me:
> 
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
> to check if a list_lru is memcg aware looks confusing. I guess we could
> simply add a bool flag to list_lru instead. Something like this, may be:

Yes, this makes much more sense to me!

> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index aa5efd9351eb..d5ceb2839a2d 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -54,6 +54,7 @@ struct list_lru {
>  #ifdef CONFIG_MEMCG_KMEM
>  	struct list_head	list;
>  	int			shrinker_id;
> +	bool			memcg_aware;
>  #endif
>  };
>  
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0730bf8ff39f..8e605e40a4c6 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
>  
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -	/*
> -	 * This needs node 0 to be always present, even
> -	 * in the systems supporting sparse numa ids.
> -	 */
> -	return !!lru->node[0].memcg_lrus;
> +	return lru->memcg_aware;
>  }
>  
>  static inline struct list_lru_one *
> @@ -451,6 +447,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>  {
>  	int i;
>  
> +	lru->memcg_aware = memcg_aware;
>  	if (!memcg_aware)
>  		return 0;
>  

-- 
Michal Hocko
SUSE Labs

