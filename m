Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA15EC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 11:17:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9459C2146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 11:17:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9459C2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25C046B0003; Mon,  1 Jul 2019 07:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E5668E0003; Mon,  1 Jul 2019 07:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AD558E0002; Mon,  1 Jul 2019 07:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id AE6016B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 07:17:10 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id i9so16630358edr.13
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 04:17:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Jn/nNRsGwBJPvZTWucyEahZLP0x8dXUIYWMOWrlbYi0=;
        b=EE0/2KhXT864QzWDVCF4BMbBABSyISH2HWFQB8ZDbkdcM+hwpHNhsQgBQB3liORR+N
         NjrfP1UbdQVD6JLUS740D8S8tDTnH/pVG8H5kjxHP8LU6fMgNOMOB140NVehZbT5lDzM
         JvZ8Keppj3iJ0b5q8i5hTivnIPSU6/cIm6rnynDgrxJmq57KO7ZczWorrVON0c5ngDYs
         6PmCtaRnSg0abSiyou1+Dw8+tVMSo/TImmdkef3Ct3f7OEIIGoJ0CG2Rqs3/BxzTXQEw
         J8YRW2UrJTAAG5Mx5WZH2syLuzFCGAn3w8cTmtHe20c33OnF6bbXk4jVXE1w2X6XSX+Z
         /oEA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWDgXg8TWxkPyCLFnnEjfh/dMb3HLOJnL9XEhppbUmb8J9y7kHm
	GEs9/jWKeZckZeISn58V/CN998zEb5jdKJDmpGMcJBCLpZcRrpt34Xk2pCTkazyLIHz94MKRjtj
	9GOlNXKkDw8yWikMs6Cr3zpmT5rHIvq3q7M8WN6WZ4El/tDP6WFjWLBiXw6fj5dI=
X-Received: by 2002:a17:906:1286:: with SMTP id k6mr22912657ejb.183.1561979830261;
        Mon, 01 Jul 2019 04:17:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv+xviunjrTv/re3rmo6hOOm7W1zG2BT1hT4AgBG2OpbB5NLOeM9C4PjQtuBza3CbtK8nw
X-Received: by 2002:a17:906:1286:: with SMTP id k6mr22912577ejb.183.1561979829270;
        Mon, 01 Jul 2019 04:17:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561979829; cv=none;
        d=google.com; s=arc-20160816;
        b=CBcZuF/6J3GHFiFy4tItcoCbHs9yAgztH/J4bzHcq4TufwmbzuHDQNmFP/jCZGKS+p
         ++pTgp7WLzBde0VKTLCjOWD+1dSZbnWKYl6sYn1TO9J1Tpzo/LoY03xQj4CaDj2YPqhO
         R22TCuqro2rS61Vg0+dHDRA9wvgPCyI976tcO7MOIupohqRmENgM6cfUEskZW8vW5IZA
         vEQWdz0e+YFmhnkNeGpwqs4lb5LZt6tEpBDzxPRkLZ/6ynSjvit4SM4FAJLCrhTbbxDb
         5ibgiH6uZUUP5genKI7yN5egDpSQ54LQd2U2MCNbnZ0BEHjZjaQA9a+yrz5U8jrCq844
         IfFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Jn/nNRsGwBJPvZTWucyEahZLP0x8dXUIYWMOWrlbYi0=;
        b=sMlIer+eedXQi2AkmgMV0KlZwGQKOoch9Bm3aYkkRVLTljC85ADy6D5t+eGSQ39rHG
         eQ4xY5fk7bdGhVhD+EqU/6ndo3mmb06TQWB6Nrg8LIh5amZ8HFDM2LxOQKNQvfhPeFt/
         Ha+tguG17AVmDbj2bJo8sLLE+aBj3R/ZcHW1GcFlm2LTYWZxyz5KKdRWjneiRr0oPOtx
         9yI8Uc2YUB45cmx8F1d2WBmQjuff6OSirUdjcGhw9tmyfyfvdv+po3V0KHIRIXnEbIhq
         eS7BGvSAixEDXc8WJ7nWQ3lU9/zWKy7L2AGsCQO/9iEVLeqIQZ/1pu2pGvg8XJLBNCng
         XK/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si6676562ejc.257.2019.07.01.04.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 04:17:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B4C4AD08;
	Mon,  1 Jul 2019 11:17:08 +0000 (UTC)
Date: Mon, 1 Jul 2019 13:17:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190701111708.GP6376@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 29-06-19 20:24:34, Tetsuo Handa wrote:
> Since mpol_put_task_policy() in do_exit() sets mempolicy = NULL,
> mempolicy_nodemask_intersects() considers exited threads (e.g. a process
> with dying leader and live threads) as eligible. But it is possible that
> all of live threads are still ineligible.
> 
> Since has_intersects_mems_allowed() returns true as soon as one of threads
> is considered eligible, mempolicy_nodemask_intersects() needs to consider
> exited threads as ineligible. Since exit_mm() in do_exit() sets mm = NULL
> before mpol_put_task_policy() sets mempolicy = NULL, we can exclude exited
> threads by checking whether mm is NULL.

Ok, this makes sense. For this change
Acked-by: Michal Hocko <mhocko@suse.com>

> While at it, since mempolicy_nodemask_intersects() is called by only
> has_intersects_mems_allowed(), it is guaranteed that mask != NULL.

Well, I am not really sure. It's true that mempolicy_nodemask_intersects
is currently only used by OOM path and never with mask == NULL but
the function seems to be more generic and hadnling NULL mask seems
reasonable to me. This is not a hot path that an additional check would
be harmful, right?
 
> BTW, are there processes where some of threads use MPOL_{BIND,INTERLEAVE}
> and the rest do not use MPOL_{BIND,INTERLEAVE} ? If no, we can use
> find_lock_task_mm() instead of for_each_thread() for mask != NULL case
> in has_intersects_mems_allowed().

I am afraid that mempolicy is allowed to be per thread which is quite
ugly and I am afraid we cannot change that right now.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/mempolicy.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d8..938f0a0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1974,11 +1974,10 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
>  					const nodemask_t *mask)
>  {
>  	struct mempolicy *mempolicy;
> -	bool ret = true;
> +	bool ret;
>  
> -	if (!mask)
> -		return ret;
>  	task_lock(tsk);
> +	ret = tsk->mm;
>  	mempolicy = tsk->mempolicy;
>  	if (!mempolicy)
>  		goto out;
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

