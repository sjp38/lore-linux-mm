Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB183C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:40:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDF3214AF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:40:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDF3214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C84046B0003; Mon, 29 Apr 2019 06:40:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C33246B0006; Mon, 29 Apr 2019 06:40:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B222C6B0007; Mon, 29 Apr 2019 06:40:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 663976B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:40:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id q17so4624291eda.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 03:40:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SFjYUUJZ1VP6zEyJ8XuuNiaAX0L5ImNaXO8eQtgJxYA=;
        b=psVopZ8FLBw5Y0CwpRsYXq0L8y5uxXdUlGBUA+VJR6F/8eDrvwWY4OfM+gfoJQN2yv
         X6cuMJdfpDMPjI5VN+GWW5yYzJw19mVVoQF6d35LjiR7o8l7edjNdgR61ngY3zHJajfb
         XnS3wCe2SsF7/Sfk7tJdhfAYkb/B9xTmCh1bJ0OKRYyEouPM5ZLH2/AKL10dypbL6bmy
         HG5mSMGd3GT8Mhe2qogU/zABBpvlgQWFoKadZSQUidbZxFdMc7ISMG/7hiEuo3CDPyi3
         yqI4FQ8JSHkaQycPshikSmkklWu9YNdHVhpUrCBhLvUKb0EjGIOmFKAOVS8XjovGwk3u
         pHXA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVeO5jDK02zFoNnk9Qg9RfdzO2LL/W7SuhCRXOZDJc1O4flCdv9
	pPfNBNqcyafkbimtsooCfJ3Jh9DEE50IhIYuPgE75aMevHq5dRonI4VCi2QocwkuIbiLPU7RoCT
	CQoRdSqyjAEtLyTZZtGkVW2VORVzODckPr/w+L+G2JARh3Uu2bDuzHiY87Nl3Jgk=
X-Received: by 2002:a17:906:f288:: with SMTP id gu8mr7294320ejb.178.1556534457914;
        Mon, 29 Apr 2019 03:40:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/5mOEpbNayaItf5KHn5sRUAAeHTrUpBAm4zgeE1w9VNd49dW2L7upEYzsYKvsJMhjYvEe
X-Received: by 2002:a17:906:f288:: with SMTP id gu8mr7294288ejb.178.1556534457110;
        Mon, 29 Apr 2019 03:40:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556534457; cv=none;
        d=google.com; s=arc-20160816;
        b=pMGCo7v1KVjnlj5CUhTlYYlKYyJj/hIqUI1XzpPG0n6jPcRajCJOwpliyFTz18pJo1
         MHO4BVUii8OTGeWgqGQHnAv2mYaH+QmOCWhwul6qYj+sZplQEnAr3kwlA/roOv9S9s6S
         qXqc/kX/DTS3WdgZyhK77FH3ot2h1xEE/CFM4obNfcnZ7la7/srplvNv2BaNPWjlReVo
         /szuoDVq1j5436PqCdPQdRoodb3eZxJvAlcF4lMEf9D3UlLPGdpuXnD+NQBNg+1P5jYk
         QVY4P54JhfNuQxgcNocSDnNEw/e/0hyCtXO/ANw5R9+lrIdeOwktolvYJGazE8v8iF2w
         BCCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SFjYUUJZ1VP6zEyJ8XuuNiaAX0L5ImNaXO8eQtgJxYA=;
        b=FJCxn5hkVayQa/KkBAb1CHhailLJM365DIVUylBgwrm7uOrXIRicKs8yObKvTkptm+
         5ovdlTpu+iW40uFvW250SmzgCrICj+3VnjSMV9ej75wGsBONbZSUQVxe6rfHfWfSGJtr
         TNmszFTuOo7chz09QWbGytFmM5XvVhVeH4vvhoQw5Tap+ccc+UThXt3ZMwg0n97QmLe8
         KqSHyy7ValoQg8ffHqAqyMBK4r7yjrGyOE6m2mmCntaXHoqO1WSoZe3/AW1SiYR5xGbN
         VruGwnUHMqmxUi7yyol2p/0jFyUwLVgn8kmXH+Nbhk83pF2E/ZWa47L+X9N91fGGWoh5
         EBoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kb8si449329ejb.113.2019.04.29.03.40.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 03:40:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25CCFAB9D;
	Mon, 29 Apr 2019 10:40:56 +0000 (UTC)
Date: Mon, 29 Apr 2019 12:40:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	mm <linux-mm@kvack.org>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: memcg causes crashes in list_lru_add
Message-ID: <20190429104051.GF21837@dhcp22.suse.cz>
References: <f0cfcfa7-74d0-8738-1061-05d778155462@suse.cz>
 <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
 <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 12:09:53, Jiri Slaby wrote:
> On 29. 04. 19, 11:25, Jiri Slaby wrote:> memcg_update_all_list_lrus
> should take care about resizing the array.
> 
> It should, but:
> [    0.058362] Number of physical nodes 2
> [    0.058366] Skipping disabled node 0
> 
> So this should be the real fix:
> --- linux-5.0-stable1.orig/mm/list_lru.c
> +++ linux-5.0-stable1/mm/list_lru.c
> @@ -37,11 +37,12 @@ static int lru_shrinker_id(struct list_l
> 
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -       /*
> -        * This needs node 0 to be always present, even
> -        * in the systems supporting sparse numa ids.
> -        */
> -       return !!lru->node[0].memcg_lrus;
> +       int i;
> +
> +       for_each_online_node(i)
> +               return !!lru->node[i].memcg_lrus;
> +
> +       return false;
>  }
> 
>  static inline struct list_lru_one *
> 
> 
> 
> 
> 
> Opinions?

Please report upstream. This code here is there for quite some time.
I do not really remember why we do have an assumption about node 0
and why it hasn't been problem until now.

Thanks!
-- 
Michal Hocko
SUSE Labs

