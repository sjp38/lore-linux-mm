Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6E14C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 13:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A3DA2793A
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 13:59:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dr4zne4H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A3DA2793A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29E016B000E; Sun,  2 Jun 2019 09:59:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 226E96B0010; Sun,  2 Jun 2019 09:59:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A0B96B0266; Sun,  2 Jun 2019 09:59:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C54606B000E
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 09:58:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 93so9763549plf.14
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 06:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9ONWqLNyVEgxdlkWmoBEEgBfGAAROFdHUnt1EMHezTI=;
        b=RHnjqX0oCm7LQReoo8+gj6yDL9Wb7xDKoimDCjCuiAIjWbNgy3d36sMLiuqpszjH9k
         Uu6IZTKbbJDTxfdTnpgTlEeOgMM2n+Hl3no7YpckN8Sa25tvtG1vNAGheZTe8goAheGs
         JLHpoKffK9LV+tcKEc6sfCNyBgX36gHFf2HbSOlCMaFZXAVSTaFzK9xotippVohbt3w7
         auMi/qW2MEqs0RaUpfxcG5IkGlkM4szazfNpK0hUL6ok9vSJggPRJB1ja9tcnJGjlpDs
         hrgWFeWyu4eLkVLgdrRz4LFZfotDjs7Z5/RxLGfzgS4Q5QwCUhysx9jap4uA4z4CQ9cz
         C+Kw==
X-Gm-Message-State: APjAAAXKV2vUXGavEuvjZpRLg9Cgc70S6yPqVq1ULmr6ipDeAdt7OiOm
	h51gsvhAKBsjWqfiEwJQzYQDv7D2QYsADig/Wp9hUaaEO1XMJTvNcqpHidWS17Fky1newy8Qy5F
	EIJJlliU/+W7POueBpf2vN75XpQCqR+0nCax/mf9tKhYsNCXr0WdU/z+/emPLO6WJ+g==
X-Received: by 2002:a63:2315:: with SMTP id j21mr22056259pgj.414.1559483939323;
        Sun, 02 Jun 2019 06:58:59 -0700 (PDT)
X-Received: by 2002:a63:2315:: with SMTP id j21mr22056167pgj.414.1559483938432;
        Sun, 02 Jun 2019 06:58:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559483938; cv=none;
        d=google.com; s=arc-20160816;
        b=RjoVct1AqIi8zTaHdFDctCTYbnzoHWfaO/4jcy4F3zhglG5UvfpR3XCPihrYxKFBQ7
         sVShxl9BHw7nt6G/r1kQQv0dHGuq8iKIXMCfXKMnPaX5yheduZUvmELGI71XEskJUBNd
         HaG9YuPtqOEFNf/lmjPuaLenbDmdVx2x+9kPzMFlKY9As8x41ABENnHuXfUzIBafyqAS
         BPxS/7pdb6qGdI/Uh7WAG18BRt2bhfe1OnZjVUk92T0yAo8f1gjH4ahuQQS8q4tmVr/m
         Q6ByIt0pjVtUlGaQWPfY3FtSh+1rRzdjfWCmYUiQ5zHHHkMR8LBUALSD+sZA5uIzvr5q
         OiwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9ONWqLNyVEgxdlkWmoBEEgBfGAAROFdHUnt1EMHezTI=;
        b=SjmL/RMOhALe63OKd9FQ/LxynQP/5SYCObsRirXJp+nlCEvB6kA+aINLwcrQHQxiPy
         KJiuT7hZdOghN/zta4jxQlc4oNA36dFyQ9TigAyDQWE9IWa6QU2awxgrdQUpmvjca6J/
         TgfICw0qCr0PT7A7py34XC8O+6joHYtPiPjkXebZuT87zAjvYmt8wnaUrs7cdmn97iao
         lQqwpOCWgAzJ1kImFJ3zc9X6NmoMviHv6Mq3G9XLQ2onaZX+QILjYYtdkq++ZqeOW5P+
         oHRlCt+M3wAdve/WDmo45zcGmKqQlPCIQGolbpAahQqxdApPfXpuVIa51YOmBwLWu830
         BquQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dr4zne4H;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor11787092pgd.67.2019.06.02.06.58.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 06:58:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dr4zne4H;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9ONWqLNyVEgxdlkWmoBEEgBfGAAROFdHUnt1EMHezTI=;
        b=dr4zne4Hpmbp5zbK/HZVaoPqkv+Q/J6QvMUJsdsfx9+XMMJfaPQCm9hv9/u72/mtpJ
         Hc3lhkikxG6yflrZowYP1yDuz/ud8EKfTIMP70zcOhscVUDtsHy0NUHJxt/PCGyHlPJy
         p/ZwMDGsOn+Hzm+QyqrQYy+lOTH9Z5AgJeOCo+e2JlVzZ7HYiqB7nZdSGxQawF00XMxi
         jL8GqvopM7xeezqf65J3fXckiYxj6SgTf5GKpgRatJxR0gysj+F8giwhxsCQoXCGUFDh
         L+s5eo2//sgrL1HVYvHPHPhDoCRzuMGWYn7b+L0FTsxYHDcUIDUEOwcQWgE76jo/st6l
         42oQ==
X-Google-Smtp-Source: APXvYqwl5rc6/q5rnzwt7G5O2VElP2V+PQoL+0/IPsAO/RkxvnvM+qWG5URT7Az8WTMCDG5Sy5uTfA==
X-Received: by 2002:a63:7508:: with SMTP id q8mr21190649pgc.296.1559483937851;
        Sun, 02 Jun 2019 06:58:57 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.35])
        by smtp.gmail.com with ESMTPSA id i73sm10813308pje.9.2019.06.02.06.58.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 06:58:57 -0700 (PDT)
Date: Sun, 2 Jun 2019 19:28:52 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH v3 3/3] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190602135852.GA24957@bharath12345-Inspiron-5559>
References: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
 <1559467380-8549-4-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559467380-8549-4-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 02, 2019 at 05:23:00PM +0800, Yafang Shao wrote:
> In the node reclaim, may_shrinkslab is 0 by default,
> hence shrink_slab will never be performed in it.
> While shrik_slab should be performed if the relcaimable slab is over
> min slab limit.
> 
> If reclaimable pagecache is less than min_unmapped_pages while
> reclaimable slab is greater than min_slab_pages, we only shrink slab.
> Otherwise the min_unmapped_pages will be useless under this condition.
> 
> reclaim_state.reclaimed_slab is to tell us how many pages are
> reclaimed in shrink slab.
> 
> This issue is very easy to produce, first you continuously cat a random
> non-exist file to produce more and more dentry, then you read big file
> to produce page cache. And finally you will find that the denty will
> never be shrunk.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/vmscan.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0c5669..d52014f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4157,6 +4157,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	p->reclaim_state = &reclaim_state;
>  
>  	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
> +		sc.may_shrinkslab = (pgdat->min_slab_pages <
> +				node_page_state(pgdat, NR_SLAB_RECLAIMABLE));
>  		/*
>  		 * Free memory by calling shrink node with increasing
>  		 * priorities until we have enough memory freed.
> @@ -4164,6 +4166,28 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		do {
>  			shrink_node(pgdat, &sc);
>  		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
> +	} else {
> +		/*
> +		 * If the reclaimable pagecache is not greater than
> +		 * min_unmapped_pages, only reclaim the slab.
> +		 */
> +		struct mem_cgroup *memcg;
> +		struct mem_cgroup_reclaim_cookie reclaim = {
> +			.pgdat = pgdat,
> +		};
> +
> +		do {
> +			reclaim.priority = sc.priority;
> +			memcg = mem_cgroup_iter(NULL, NULL, &reclaim);
> +			do {
> +				shrink_slab(sc.gfp_mask, pgdat->node_id,
> +					    memcg, sc.priority);
> +			} while ((memcg = mem_cgroup_iter(NULL, memcg,
> +							  &reclaim)));
> +
> +			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +			reclaim_state.reclaimed_slab = 0;
> +		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
>  	}
>  
>  	p->reclaim_state = NULL;
> -- 
> 1.8.3.1
>

Hi Yafang,

Just a few questions regarding this patch.

Don't you want to check if the number of slab reclaimable pages is
greater than pgdat->min_slab_pages before reclaiming from slab in your
else statement? Where is the check to see whether number of
reclaimable slab pages is greater than pgdat->min_slab_pages? It looks like your
shrinking slab on the condition if (node_pagecache_reclaimable(pgdata) >
min_unmapped_pages) is false, Not if (pgdat->min_slab_pages <
node_page_state(pgdat, NR_SLAB_RECLAIMABLE))? What do you think?

Also would it be better if we update sc.may_shrinkslab outside the if
statement of checking min_unmapped_pages? I think it may look better?

Would it be better if we move updating sc.may_shrinkslab outside the
if statement where we check min_unmapped_pages and add a else if
(sc.may_shrinkslab) rather than an else and then start shrinking the slab?

Thank you 
Bharath

