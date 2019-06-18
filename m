Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43A21C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3F82085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:14:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3F82085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37A006B0003; Tue, 18 Jun 2019 08:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32A1D8E0002; Tue, 18 Jun 2019 08:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21A538E0001; Tue, 18 Jun 2019 08:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C75316B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:14:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so21041062eds.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zs0nSU0sAL9bMuLzucrALijyf19mqPFTd52Cw8w4qYY=;
        b=bo1V9aNo9CntltkYMqFI4EDKY6s7D6wRNCCPIenghQgROcsZCejjxPIC746UrlMO9a
         v41ipNOV8IDlIZxEeW7EKA0ST/fgLRNBdIjeuOWhw1miWNQeBU8DuM/jKoXdp+B9FD4O
         tP7PY9f2ydcatNuMWyI1ZTv+g5tcixPyXP5aeMKn4rIApBXazv2rhnFLUMcoBbAl6O/A
         Tr9yUSLPHc4g4xA1q99mqqGH4Bpj9fK+m13jj7QYoF39lTyMNMXXrDKZDigSjuhnueRG
         RVgymxDJKN4gi2F++MNeh/yZSEPg9gxxijB/tdKO0aWTLKUW6C24mJdJ6GCWzPBZ0dU5
         uMTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUkI5uiPTZ3Xcz5qAsyKez1CRFEEe76pKVtB7BCi4nYWcPt/bH8
	EtQczPYe9GvNHiXMiTc4mbWgVmkynsR2IWdIzhLeusxachCTFHWEjostnOq2/ouIh1b+XJ/861i
	PuouO4vHvqyNzJEGz48r4GM40BZ8PDUxsYpVuoZZj9iI1X+ryoGr3C4/rlYVXtczbTQ==
X-Received: by 2002:a17:906:951:: with SMTP id j17mr74523384ejd.174.1560860062262;
        Tue, 18 Jun 2019 05:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+GvtUChqTDLHVJw9NuiQjSPp+vtBXLiNB4vUzTH581B3trf+UyLw2iFUEcVrtrDpxJqkQ
X-Received: by 2002:a17:906:951:: with SMTP id j17mr74523325ejd.174.1560860061357;
        Tue, 18 Jun 2019 05:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560860061; cv=none;
        d=google.com; s=arc-20160816;
        b=L5oP8r863cAIb77p+wHaWcIbP+b2rRPsnwQj4zWnoz0e9XioIrh81Ptc6ATSh5oyDR
         i1pUlHI7OpLDjm4M2Gpurtp30sSMxCqIj0+I265hO6QWEftCAgLr3eaPT37ClCEpHmI0
         OHmxRsljswAigacDykbiuM2XoqbHyNwsyBpznNPxYGadQYoAqPqM798TtyYsxVoD2liv
         gOr/HnfXrZOVWfwZry33GuLUZN1aFVQWEmr+ZLTEqBOMpWhFCOglXKP+6xTxte7YkIUZ
         BTcV42pkTjBiV78DqKI7dpcw13SLAwZR6StXxV6mbSEK/Njy7KiWrXDsxK+UPhUsq18B
         FNhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zs0nSU0sAL9bMuLzucrALijyf19mqPFTd52Cw8w4qYY=;
        b=hMDY+T8AS8wI59+icAQrZSJJDz8m+vTEWl6HMOKrB7nx3UZ66h7Yx/RP5lr1Nb4HlF
         BfrLj+BeQk3aYLCOeIKixjxL939zpR3Q9NtOWa5LCkIBDwG/og1RpIGiGGc6KqXjna4E
         xbLKy7XBk1U9hOOyBF9AN5PYvDF94Ir+Em8hASeUeguvuACJBOhSsGuXp+wN4NEOccKC
         f6GGjU5oKC+rWynrD6cxsPw4wc+96bITRL6b96gUR2msSja2nL5mW8zoxzzONn0uHVRr
         BG6g8G99cvBar3+cYQpCdxcbfybk+HQxMk8knXXKDWgBRWvmAkUGYG9TZclqZdc/pvpi
         7AqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si8897560eja.306.2019.06.18.05.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AA00CAEE9;
	Tue, 18 Jun 2019 12:14:20 +0000 (UTC)
Date: Tue, 18 Jun 2019 14:14:18 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Greg Thelen <gthelen@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: oom: Remove thread group leader check in
 oom_evaluate_task().
Message-ID: <20190618121418.GC3318@dhcp22.suse.cz>
References: <1560853257-14934-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560853257-14934-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 19:20:57, Tetsuo Handa wrote:
> Since mem_cgroup_scan_tasks() uses CSS_TASK_ITER_PROCS, only thread group
> leaders will be scanned (unless dying leaders with live threads). Thus,
> commit d49ad9355420c743 ("mm, oom: prefer thread group leaders for display
> purposes") makes little sense.

This can be folded into mm-memcontrol-use-css_task_iter_procs-at-mem_cgroup_scan_tasks.patch
right?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Greg Thelen <gthelen@google.com>
> ---
>  mm/oom_kill.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 32abc7a..09a5116 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -348,9 +348,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	if (!points || points < oc->chosen_points)
>  		goto next;
>  
> -	/* Prefer thread group leaders for display purposes */
> -	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
> -		goto next;
>  select:
>  	if (oc->chosen)
>  		put_task_struct(oc->chosen);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

