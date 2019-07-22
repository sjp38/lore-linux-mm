Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6609C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 12:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F242184E
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 12:00:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F242184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30EFC6B0007; Mon, 22 Jul 2019 08:00:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BFD38E0003; Mon, 22 Jul 2019 08:00:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B0198E0001; Mon, 22 Jul 2019 08:00:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF2056B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:00:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so26174951edc.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:00:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=a2cbxEoHUsQfp8fK0M5/s35Nvpsx8ZujEmvfSebKNaA=;
        b=jEc1peMs+VyaV4Q6qZ9bsmslQ0edQnW0ZU1wut5XCcd5KoPQE4KPda1upkDdy9RmOv
         3bpyRBauOwm0NkzcSKN/TRGQnJENObqgsI7HwMRBQ3udW0WA63+75oU0jHDjBMcyv8K2
         pATFxOHPfb8HyNsoOBrIlitrIjB9HmZzZCQN3XCCkFifjd8zVkUwwRDEksQ350A5ox7v
         QuYNofFZ+AXzT1ngAK08ya3mJ4wf5KDk2o2A2YNLMNtkVyo5GsSyBN4FHGX0r3tE0Oje
         +jwu/UZbxxyxTBCanPtDhhwVY3il8iW36w4xUR5cgSIDQcNtb3DFQGgvAixzAwlrdnxK
         evyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWA0lK9+B6BbrU1MwN1QxIp5eEG34w+vg0jWOGSNeequVsRTcWT
	m/cAz1A3/z64aQ0fQDnYklJg9nvl33RqDvPXIt/GoHxOFsec3Ge4zxEmm4sVvklzoMObMXVmHUg
	bvb1nqcdkhSAMG7+OcdpFRHQkxMBExMSV7o92kqyvX/Y2mv3ZNJxqmSnbE+5ok5s=
X-Received: by 2002:a17:906:244c:: with SMTP id a12mr51452867ejb.288.1563796822353;
        Mon, 22 Jul 2019 05:00:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+Ky46WSSOauYHqJrVML9u4E1ncWMDTjT+sqDArdqZ6QhoYLBgcnt16xa9hU2f29UEaUPz
X-Received: by 2002:a17:906:244c:: with SMTP id a12mr51452697ejb.288.1563796820588;
        Mon, 22 Jul 2019 05:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563796820; cv=none;
        d=google.com; s=arc-20160816;
        b=yC3Ca80ZevnWW/uQB+8s3MKYU3p+KhAKTyw/qUncp1aeX0/o+u9SLruVB/oEYlWyJB
         d+W/pSmyAFcUSCdXgvQJ22gAD5mrQmW1kLTNY6irFgcE7r9LN86clgIw3ObGEyOa9uqC
         2a0dxr47Ton5Q+QuVDD01wKTcgg9qj8w023gzn4hHP0UeoETw5csqtVkoBLrrDil7nNU
         yK1aaPloFo1VY6LfTtAibq6CLX0JHLNxqmuRNZqvOsSw4H820QyHdvNaRYQagU9PHwWZ
         chM2YSv62OWkbsRYQdvOYqwi6+LbvY4xEPDeowSohPjv8WIZVDQS7OrnBPEzwqQhbB2H
         VZYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=a2cbxEoHUsQfp8fK0M5/s35Nvpsx8ZujEmvfSebKNaA=;
        b=nULgWwWhj6uxLVLYtBK/E2hC3cNJjCN9gGmzYuqqMbOwiSeXdJoMIo79MDsBLs+dEc
         qMZ72Fkujui5SsCB27brkOLg444s4e0OgPrOFJWEmJ3or4NGN15AXjN8/EH7J3jj6jbJ
         atQZcH6TMklPioAWJl4tBERw1XpasN9KvHtqA5XB0q1a3q75Cu92luVO+DLpHE5XcP4q
         WhIVjzLP4Txs2fRFqrtNBLML9C/iWgommNqiC6bik2TzjvDQmW5xjuuAeoMQie9wWJO7
         iPJ2ugzam0WDm/2OcDdWUlmluNlmy599TgF7Uxa0mWveefHC+2J7PHQue9M7C1YcWWNt
         20FA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si4573801eda.107.2019.07.22.05.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 05:00:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 905F2B048;
	Mon, 22 Jul 2019 12:00:19 +0000 (UTC)
Date: Mon, 22 Jul 2019 14:00:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: shakeelb@google.com, vdavydov.dev@gmail.com, hannes@cmpxchg.org,
	ktkhai@virtuozzo.com, guro@fb.com, hughd@google.com, cai@lca.pw,
	kirill.shutemov@linux.intel.com, akpm@linux-foundation.org,
	stable@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: check if mem cgroup is disabled or not
 before calling memcg slab shrinker
Message-ID: <20190722120018.GZ30461@dhcp22.suse.cz>
References: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 01:45:26, Yang Shi wrote:
> Shakeel Butt reported premature oom on kernel with
> "cgroup_disable=memory" since mem_cgroup_is_root() returns false even
> though memcg is actually NULL.  The drop_caches is also broken.
> 
> It is because commit aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab()
> calls in shrink_node()") removed the !memcg check before
> !mem_cgroup_is_root().  And, surprisingly root memcg is allocated even
> though memory cgroup is disabled by kernel boot parameter.
> 
> Add mem_cgroup_disabled() check to make reclaimer work as expected.
> 
> Fixes: aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab() calls in shrink_node()")
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org  4.19+
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f8e3dcd..c10dc02 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -684,7 +684,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	unsigned long ret, freed = 0;
>  	struct shrinker *shrinker;
>  
> -	if (!mem_cgroup_is_root(memcg))
> +	/*
> +	 * The root memcg might be allocated even though memcg is disabled
> +	 * via "cgroup_disable=memory" boot parameter.  This could make
> +	 * mem_cgroup_is_root() return false, then just run memcg slab
> +	 * shrink, but skip global shrink.  This may result in premature
> +	 * oom.
> +	 */
> +	if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>  		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>  
>  	if (!down_read_trylock(&shrinker_rwsem))
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

