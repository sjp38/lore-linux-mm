Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20ADEC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 925E52075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:20:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="puiOLgLD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 925E52075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 292566B000A; Thu, 28 Mar 2019 10:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 217F06B000C; Thu, 28 Mar 2019 10:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0916A6B000D; Thu, 28 Mar 2019 10:20:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6ACA6B000A
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:20:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l26so20202495qtk.18
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:20:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vay+wlXHA2RDv/GmVToMkpOGJVWOatSpW8U6KZxfJTg=;
        b=KmlOcGaRKzqG5vPO+i/c1om6VkpVUubb5XIsgxGJCXn+C1Z3UfjmYRtBvBfG4x1mH1
         E+J7E52QneIrKYyiznbOr8QVCxlx3IPKsnJdRR9jOQTQQ46iRqhTaUZxlFUoHz1uRuec
         vsT6S2BrQqYrHTY17/a+7sNuRnuw1vwf5zsZuiAugEdyrnnQqGVyQibUVrWkHLyD0eTY
         PCMiJLnlAP/0mphOq/KdxT/ehasAiP5PJjssJymleLU6pCJt0EAq+WNZmH12/jq4iOJf
         ZOQSyBZ20eVuFDu2rYCSmSvCrhHWBXT40E0R9c/5CdMHrKG6MVxE6ISuI//nXlbeOW2+
         m3dg==
X-Gm-Message-State: APjAAAVzPRMeto/+egs/eaT7TSUo7SfgarnGtLdCHfMTyt1s2NRgEZxX
	6M3Ig8BVqGlrDnoYsMeI+BSx7Lu4AL6cDgyzcJ/BQqQuuCSoB+Z9TzByKFt/iAZTG6MOM8+cLI4
	wgV+J2Sd80/DDgwUlUVpWR9yEMdVClxD+i3C4MTOjOV3/IwEcGtzfeCjHlUlfUbk3Zg==
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr36535442qtk.293.1553782819545;
        Thu, 28 Mar 2019 07:20:19 -0700 (PDT)
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr36535374qtk.293.1553782818752;
        Thu, 28 Mar 2019 07:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553782818; cv=none;
        d=google.com; s=arc-20160816;
        b=fdwqLo/dsf8ZGwu/SOIT2vDaGseE3lQXi/mP2mDJswR0y/aPJGJ+nG22pMK2Pr8CoL
         ZSlcvE6MvR7K7sNvVaz35P7At5wIBRzPZsSVm9OFzr1HWqx8R0TOcF3qdTAQPsXOMGpQ
         8ALK/Iefa9CD6kyOp0LX8hWlhNpBEZ0N9rOafTA4DTu2NFKQ7tBb5NSM5J9syF4bQ1Ip
         j84nb6ZjjBst4RX8GYeDsxwIaJVVdwjFE/gF4CqF441ZlzXoxEMrhHyc+zyCYQvzflIg
         qzXnGKwWsAN/KvTQLBmJTLkCWwOwFgQQFcsKlCN5E4NNLTelN/3PCfan+1clzxc6qJMb
         MZlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Vay+wlXHA2RDv/GmVToMkpOGJVWOatSpW8U6KZxfJTg=;
        b=GvhmG4x2ejWvn96n14RzBJEmZ96Dvp1JK9TFefgH6BUfnp1a7Fsqo8xYbp8avLO5/A
         k4ZHxMLPp/xuHkJ4eOlFYWFHUA1q0JjrXmhU/fJfAN7FQthEBfTv+UmdPLWs1qbXwyk5
         skju8EXPOCSNta+xv0fv1OBY113TSMdPUv9IJpK3gZUndjl0IB0aCJRO9HMvV8vm+9Ba
         /EU1FmZ5Uqp7PO9CKNuIoYtiIIVmmtessfILjP9xxAF9Ieptjcjx6dcKydaEm7E4uenr
         oOR/96Fjh6AetOkzT0ZCM3yKd8snJjcmxQuJnYswAy+VhaQqyk3rC7U0oA0dMagtCAzi
         GMZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=puiOLgLD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n9sor25935471qvd.59.2019.03.28.07.20.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 07:20:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=puiOLgLD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Vay+wlXHA2RDv/GmVToMkpOGJVWOatSpW8U6KZxfJTg=;
        b=puiOLgLDpj0bSc2f54cXIGuxXU6pKazOK5o1k39vQn+ZeEz4KVwkNaMdOZl2QonF4x
         i6nfak3BLBpr6aa1isbefs6c4By+Yyo7jZpV6jp+jufyv2pAuDrrQYCpgs6enS98Qrop
         EtsmxyUqI37t2vgmfc5kwNxPDXqK1JhhUGf/aT19eTbWcP9tp3nnfNs9eV0jOud1x4rA
         w4Wk3rumcyZm+8AAqTWef32+ESKofgV3Zn2oNQOyQtpZbR4TbbC+svP6f+PGer2az6kv
         CnBu4dbykTGr8McngNgvcsTkBHhjjamJIkcOrRRGe3mBYsvnhTb6kmISCmk7r0STqzKZ
         gp4Q==
X-Google-Smtp-Source: APXvYqxpyAd5tjFgPujzd9DjVH5NTvlWdlmHYlmfhtRAdB6irEXwI1Q+7D9hS4KkcLf5wd0eY9Hxdw==
X-Received: by 2002:a0c:b590:: with SMTP id g16mr35368705qve.146.1553782818161;
        Thu, 28 Mar 2019 07:20:18 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id p46sm18863869qtc.41.2019.03.28.07.20.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 07:20:17 -0700 (PDT)
Date: Thu, 28 Mar 2019 10:20:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tejun Heo <tj@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
Message-ID: <20190328142016.GA15763@cmpxchg.org>
References: <20190307165632.35810-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307165632.35810-1-gthelen@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 08:56:32AM -0800, Greg Thelen wrote:
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3880,6 +3880,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
>   * @pheadroom: out parameter for number of allocatable pages according to memcg
>   * @pdirty: out parameter for number of dirty pages
>   * @pwriteback: out parameter for number of pages under writeback
> + * @exact: determines exact counters are required, indicates more work.
>   *
>   * Determine the numbers of file, headroom, dirty, and writeback pages in
>   * @wb's memcg.  File, dirty and writeback are self-explanatory.  Headroom
> @@ -3890,18 +3891,29 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
>   * ancestors.  Note that this doesn't consider the actual amount of
>   * available memory in the system.  The caller should further cap
>   * *@pheadroom accordingly.
> + *
> + * Return value is the error precision associated with *@pdirty
> + * and *@pwriteback.  When @exact is set this a minimal value.
>   */
> -void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
> -			 unsigned long *pheadroom, unsigned long *pdirty,
> -			 unsigned long *pwriteback)
> +unsigned long
> +mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
> +		    unsigned long *pheadroom, unsigned long *pdirty,
> +		    unsigned long *pwriteback, bool exact)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
>  	struct mem_cgroup *parent;
> +	unsigned long precision;
>  
> -	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
> -
> +	if (exact) {
> +		precision = 0;
> +		*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);
> +		*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
> +	} else {
> +		precision = MEMCG_CHARGE_BATCH * num_online_cpus();
> +		*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
> +		*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
> +	}
>  	/* this should eventually include NR_UNSTABLE_NFS */
> -	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
>  	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
>  						     (1 << LRU_ACTIVE_FILE));
>  	*pheadroom = PAGE_COUNTER_MAX;
> @@ -3913,6 +3925,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>  		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
>  		memcg = parent;
>  	}
> +
> +	return precision;

Have you considered unconditionally using the exact version here?

It does for_each_online_cpu(), but until very, very recently we did
this per default for all stats, for years. It only became a problem in
conjunction with the for_each_memcg loops when frequently reading
memory stats at the top of a very large hierarchy.

balance_dirty_pages() is called against memcgs that actually own the
inodes/memory and doesn't do the additional recursive tree collection.

It's also not *that* hot of a function, and in the io path...

It would simplify this patch immensely.

