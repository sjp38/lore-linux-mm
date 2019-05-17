Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F094C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CC33204FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CC33204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95AF66B000D; Fri, 17 May 2019 08:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E2F36B000E; Fri, 17 May 2019 08:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA836B0010; Fri, 17 May 2019 08:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 287666B000D
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:27:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b22so10543721edw.0
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rmnbS2/v+TkJTnmTerKMir1Y3eu4rtG2woG/ZWU2FAo=;
        b=Jhv6ib/Ox9ZsjWViuocrm5I27h3+CdwazNz/bZbsKazW54QasPcP+QclXju8jIBB1n
         q+mlocSTVq0LK9zYzThevzTsdkt0gEAIwG9NzHXi7wDTytbUKcPTveKrs/gxmCxc5nMv
         WYuJxZ8dF+1HO8E4gFLKMDMZ1/D2uLEZOSX7iT8x+MRXPk8UQ+i2uL7AoFNicJzIhTyb
         UV1WacW4gNWVc50luMFrObIvdp2fOjHswTzoHyVxrPydbEv7QHwZWENa9ITYhN1J2a5x
         3WT1FS+BZ7zdx2Zzzbbrxle1KqMaMNcB9+D9xMIUoY21b3I3Ak2IeS9lWXXtZtAjf70c
         9fgA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWo9DFcl2/o+eocqB6EeSjJWY4InvXYmobvB9NWvktYDZoPRc0Z
	++07raBlMd9NfGP6Ydv1rLIfHhTgChwIlOSgqH4j71bvBAfm+7fzWcrfhguQFw/mui4P/b3rKRi
	6jhWSkRWGaK+/0FYr8xRzU79Frz6+e0bVhnhAiiWaW2UXa8p7Y/QJ4sNQp5WCMRc=
X-Received: by 2002:a50:b56a:: with SMTP id z39mr56957942edd.91.1558096027717;
        Fri, 17 May 2019 05:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjzzrn5Dyf0gWFOW1PsqfULLHD7NbgSBADImEcaa2w5YNqKhkFOj8+hNOeBqvtpgH5oSWS
X-Received: by 2002:a50:b56a:: with SMTP id z39mr56957848edd.91.1558096026688;
        Fri, 17 May 2019 05:27:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558096026; cv=none;
        d=google.com; s=arc-20160816;
        b=Qunm1fPzzTYxLgNIUJO9bD+KiYtpqS1jrbX1wkaIxLq0rDlrUngt8ollXPF3iieQti
         5vLzLq+BESEgB5rV+QR7FqaIvR/nLBuOq3Yr6va0WHpbt7U+IhrY0N5UeO/PmEQxUdjg
         Esph6NgbBidnfT+4kI41U8/26HX/leAj56A99QctRqIG2bKdZA+MRPVGY3Fj9pz6ivMg
         nDeuJqQn8EUijvmGJeEOAxGVF4pu7QyeszOUsyfWHZhosoFgZlZhLJqrnbBvDdq7s/T6
         jq3+xnXTq9oHCjRfKLlQ+dsBI5G0nJK+YWE6KBlpiEofvZdsx5V47LaeOGi3B+KUykRU
         L2/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rmnbS2/v+TkJTnmTerKMir1Y3eu4rtG2woG/ZWU2FAo=;
        b=DIdH4zPYchQFzY4vpdj3Xw1RSX7Ge2oMrUImR3129wV4daS5VdrLfsLvNgXr6bp73J
         k/WWFq0R2yHcz27h0e9u5DN0IOUf4Np1vJ9e8E4QpjynI1xFczR76Xe6c4YdCQgwXzKV
         pwjCcXK5w7BgYj5ChKq/6hRmxsxrSA1s4HVR984cAJbN2JoGmuZGo8NFt2bgIJ8ZriwP
         dM9waT50UcpNmlV3UT9PqbYU8K3JbuNsD6LZRZ1bgBeaJyOZFt4LoR9KjuKMKa98PUeT
         PnDsIhi41n4S0t8pmU4QJG/vtiFcZCt0+fbCvA2hPO2nWIZuZvhZKXdUbAx996fu4kPI
         YANw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k57si7737edb.36.2019.05.17.05.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:27:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9D97DAEF5;
	Fri, 17 May 2019 12:27:05 +0000 (UTC)
Date: Fri, 17 May 2019 14:27:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] memcg: make it work on sparse non-0-node systems
Message-ID: <20190517122705.GH6836@dhcp22.suse.cz>
References: <20190517080044.tnwhbeyxcccsymgf@esperanza>
 <20190517114204.6330-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517114204.6330-1-jslaby@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 13:42:04, Jiri Slaby wrote:
> We have a single node system with node 0 disabled:
>   Scanning NUMA topology in Northbridge 24
>   Number of physical nodes 2
>   Skipping disabled node 0
>   Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
>   NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]
> 
> This causes crashes in memcg when system boots:
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>   #PF error: [normal kernel read fault]
> ...
>   RIP: 0010:list_lru_add+0x94/0x170
> ...
>   Call Trace:
>    d_lru_add+0x44/0x50
>    dput.part.34+0xfc/0x110
>    __fput+0x108/0x230
>    task_work_run+0x9f/0xc0
>    exit_to_usermode_loop+0xf5/0x100
> 
> It is reproducible as far as 4.12. I did not try older kernels. You have
> to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
> investigated). Cannot be reproduced with systemd 234.
> 
> The system crashes because the size of lru array is never updated in
> memcg_update_all_list_lrus and the reads are past the zero-sized array,
> causing dereferences of random memory.
> 
> The root cause are list_lru_memcg_aware checks in the list_lru code.
> The test in list_lru_memcg_aware is broken: it assumes node 0 is always
> present, but it is not true on some systems as can be seen above.
> 
> So fix this by avoiding checks on node 0. Remember the memcg-awareness
> by a bool flag in struct list_lru.
> 
> [v2] use the idea proposed by Vladimir -- the bool flag.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: <cgroups@vger.kernel.org>
> Cc: <linux-mm@kvack.org>
> Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Fixes: 60d3fd32a7a9 ("list_lru: introduce per-memcg lists")
unless I have missed something

Cc: stable sounds like a good idea to me as well, although nobody has
noticed this yet but Node0 machines are quite rare.

I haven't checked all users of list_lru but the structure size increase
shouldn't be a big problem. There tend to be only limited number of
those and the number shouldn't be huge.

So this looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks a lot Jiri!

> ---
>  include/linux/list_lru.h | 1 +
>  mm/list_lru.c            | 8 +++-----
>  2 files changed, 4 insertions(+), 5 deletions(-)
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
> index 0730bf8ff39f..d3b538146efd 100644
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
> @@ -451,6 +447,8 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>  {
>  	int i;
>  
> +	lru->memcg_aware = memcg_aware;
> +
>  	if (!memcg_aware)
>  		return 0;
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

