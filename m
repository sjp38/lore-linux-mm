Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B756BC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7739820880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7739820880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC3646B0003; Mon,  5 Aug 2019 04:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D776B0005; Mon,  5 Aug 2019 04:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D15BB6B0006; Mon,  5 Aug 2019 04:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 810B26B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:42:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so51054048edx.10
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Xa0gaYwsBgonMG8mg5y+SXvLYUZ5MElxrTVPBeiFBVQ=;
        b=F4bHHVYWvsnIBbPbfL93z5fsC/kqMPDWHggCEUnTfjBvAPFvjlJYiEFHH94IzaD0z0
         ivAIvdrC7Tm8g/9aDTlJvnqpQ498tQZdf+Z5y0iI5Cz2KyzNbMV65LnnTP7xkpR7FUYw
         mvBeALgXSCFq0myDL9Qzhf1vfxYR0L9+fXTsN+TH3qm7a2Y5WKBIyzyHQ3/rbntONfet
         Z3/7vTJina9smry8unax/77lw/sWY1kk6oO5TwHLgZHcN7gQQE0McoxhnPiJxaLZeal7
         WP4lQNtkqe6lI4UZdKuARneLy8Dc47p7p0Sxdy/m8jldEIh+2sDNfNZpwjM21bC2ARl9
         JqfA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWrdCTKvEXkeuFakb/TvwQtgg5u/vSRPlh23yNvphXlic3LZDUf
	Y8jCsvGnjheJB673nXYiEJWeELQ1yYnVYIq+vAKI0iEQvgRlRG2Vkfw3kkZoroKBO1qE/l04dSf
	j7/JW/DX9oJYBID+/A4jwFL2Ffj0WOFJFWZwJoD9Uu5OSInmPDslTI+yw6CaHzT0=
X-Received: by 2002:a17:907:20a6:: with SMTP id pw6mr105632359ejb.111.1564994551963;
        Mon, 05 Aug 2019 01:42:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuEwHzZ9Zi3vUu8Vo/4cVHfe1lemW+g2Cmi5F4G1H4IdsmCyNwEheIvA9QhrBgPl70i3vL
X-Received: by 2002:a17:907:20a6:: with SMTP id pw6mr105632310ejb.111.1564994551049;
        Mon, 05 Aug 2019 01:42:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564994551; cv=none;
        d=google.com; s=arc-20160816;
        b=FaI2aRcdN/Y40QNG3YLb+ZeP52J9u5ozJrH5jiIwDebirFDtxcPtmcP0VfmDBFItnT
         /dtX/xeWY8EnK/5yURWV2XLAdhC03pd0HPKddYhUiIwud1zFnwXHbSsZhd3X5GIjQvY4
         qjgV5jK8h8BuqjDa4DySZY22BSJWYL3Y4isbo7gouZV2ymY+rcPI14SEq4PCI1PDPgRF
         TNXjx5wGbsHgBGRpU2EydSYjiih/lds0ZbyACXMaJnRMTDyIvN/shzu/aQ+5T3CfjwfR
         qAfzNz8c9VNfjgQTQ3y1BtFQT2XCQUPBAoJ/cNFO8Vcltv9UeKPjitvHq1XT75BFNndp
         4jMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Xa0gaYwsBgonMG8mg5y+SXvLYUZ5MElxrTVPBeiFBVQ=;
        b=Dd6cw6DNYXSdvYeGF7iBlwGu/eY2R8XYuIS+3YIbBg/57wq71fOLqFkbXu9m9Aq4vD
         f6gRniFhoVF9dDaI8yrpTTI94Zt2g2W+tQBKMQUl7iHIEqs405bzTankqwwKMIVTQMO0
         FNcgVPlSXBgsWvr4Oh3/c+13/aqJTYOZluI7RpsX63xtayf2kI65c2EWG+OGio9Nbdni
         d/Q5UEVZtvxT7ehnUiUaF0GkoR/aetstN23AUwDCtu9VWuo8wtmVutNX8zadcaEgRSLo
         2Uhwkj0ZKezxJXQdd8+p9oRaDRYeYIQtpgJ6mtbLyoZasibBr98WU65WaDmWI2e9T2bJ
         3PZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x22si24779187eju.379.2019.08.05.01.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:42:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77027B60E;
	Mon,  5 Aug 2019 08:42:30 +0000 (UTC)
Date: Mon, 5 Aug 2019 10:42:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Masoud Sharbiani <msharbiani@apple.com>,
	Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190805084228.GB7597@dhcp22.suse.cz>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 04-08-19 00:51:18, Tetsuo Handa wrote:
> Masoud, will you try this patch?
> 
> By the way, is /sys/fs/cgroup/memory/leaker/memory.usage_in_bytes remains non-zero
> despite /sys/fs/cgroup/memory/leaker/tasks became empty due to memcg OOM killer expected?
> Deleting big-data-file.bin after memcg OOM killer reduces some, but still remains
> non-zero.
> 
> ----------------------------------------
> >From 2f92c70f390f42185c6e2abb8dda98b1b7d02fa9 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 4 Aug 2019 00:41:30 +0900
> Subject: [PATCH] memcg, oom: don't require __GFP_FS when invoking memcg OOM killer
> 
> Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: move
> out_of_memory back to the charge path") broke memcg OOM called from
> __xfs_filemap_fault() path.

This is very well spotted! I really didn't think of GFP_NOFS although
xfs in the mix could give me some clue.

> It turned out that try_chage() is retrying
> forever without making forward progress because mem_cgroup_oom(GFP_NOFS)
> cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, oom:
> move GFP_NOFS check to out_of_memory"). Regarding memcg OOM, we need to
> bypass GFP_NOFS check in order to guarantee forward progress.

This deserves more information about the fix. Why is it OK to trigger
OOM for GFP_NOFS allocations? Doesn't this lead to pre-mature OOM killer
invocation?

You can argue that memcg charges have ignored GFP_NOFS without seeing a
lot of problems. But please document that in the changelog.

It is 3da88fb3bacfaa33 that has introduced this heuristic and I have to
confess I haven't realized the side effect on the memcg side because
OOM was triggered only from the GFP_KERNEL context. So I would point
to 3da88fb3bacfaa33 as introducing the regression albeit silent at the
time.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Masoud Sharbiani <msharbiani@apple.com>
> Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
> Fixes: 29ef680ae7c21110 ("memcg, oom: move out_of_memory back to the charge path")

I would say
Fixes: 3da88fb3bacfaa33 # necessary after 29ef680ae7c21110

Other than that I am not really sure about a better fix. Let's see
whether we see some pre-mature memcg OOM reports and think where to get
from there.

With updated changelog
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..26804ab 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
>  	 * The OOM killer does not compensate for IO-less reclaim.
>  	 * pagefault_out_of_memory lost its gfp context so we have to
>  	 * make sure exclude 0 mask - all other users should have at least
> -	 * ___GFP_DIRECT_RECLAIM to get here.
> +	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has to
> +	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
>  	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && !is_memcg_oom(oc))
>  		return true;
>  
>  	/*
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

