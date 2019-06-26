Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97DB8C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C4162054F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:12:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C4162054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8FD6B0003; Wed, 26 Jun 2019 05:12:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E59E58E0003; Wed, 26 Jun 2019 05:12:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D21198E0002; Wed, 26 Jun 2019 05:12:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3EE6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:12:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f2so1099765plr.0
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=JlN3E7jHF2JE7WmTFStvYWtAnzwIV6bEYc01gIa3yMA=;
        b=FDQgjYVF3tbc+U3fPBoEYt+bdO7cojOC7LFJ0INN50wfyccPHMtw3EMO1n/44nlL2u
         xzw5fpNL8v95sUM+oNcevm4mfY76RQZQC/ykYkIBB070HP0xMAm/g/0rgJuf1nL10yfI
         OThkwogLeo9h2k/Zco3YQzMMfqwVo55pdQHFwWey6d6E9bxmAkSXdfQF2xvPK9LEwAHS
         5m/TG6we7/OfIF143arYr5M+GIXL2Al/U8FgoJP0IkYajpnSN0fVrV8Re9FxUwWgniZQ
         sGM48Ho7DzUMKLZEJYLTg8F7flrZCJVpZNgN8YISQr9uxIGVZrGRFqXYShQqhn/wagbh
         Ivdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXYuc9d3MtP7nM4iOp6Jo5RvUoEzG2nOCPps0H0dliiZZcpbmIi
	6A02eigAB7+FIoKWqXRWJuKLpArWIkc9r30zS+ugM7yr9xmoFOrtYBgeh3/Pk35g4ALp4YRhwYm
	YQJo065ZShcYQk6tE9u/FRnbrf6aj1drc/WVsrU1Bxg7dz3ZpIGWov9FOJLDDtHpIWg==
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr3480207pjr.50.1561540342294;
        Wed, 26 Jun 2019 02:12:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3gi2a+0femS/HxRKjCs25dQ9k7tf1Dve3mKx586U4OpP2WVCZqILRxKwYwqEyPm/9sH0b
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr3480146pjr.50.1561540341652;
        Wed, 26 Jun 2019 02:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561540341; cv=none;
        d=google.com; s=arc-20160816;
        b=flFMmAObOgkjp7kmIexCo7aKhNU+qI3RhM30QSD7ysh4+J8sd2y0+/vuWHLFTdQW8O
         N52Gmim9Fxb0nunhLY3q4pq+o2iZNZ86/QKoG4XDCLhmu0tYWXgyEGK1odvenFonmnHs
         VNA7CmJ/j/aU7TVEsqjuXkA18GsUhZ9sthqtJ5zNAIBsupdGxzgjemdswUCrsd7HPkYq
         7tw+BAe+Q1j3wzPE/VFiWQGZHNn04gxOJFouU3W/2cEZ100xSLa5rWkYfqsUlWKFc47M
         5gVKS1UMOAIT2KX0ys3Q66w7nothVuSGfHc2YiNjqAadt8Lmmfy3IpGpGlpUuhw173yt
         rMsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JlN3E7jHF2JE7WmTFStvYWtAnzwIV6bEYc01gIa3yMA=;
        b=E0nV70RjSjnp9KgMVLtjYbUwxwdRMxrDcuHjE3VPHeEPoTQELCpWxUme6P01NNsg1B
         BAsms7nMP0Ize50ArTiZBVcjlMMYYHgfCAmkEVDhnjm+1gzhi05K5aqwwcYyVUcFUWh0
         JLitr+FvoMMk/iS6gVaeR/7EayhZjrJyjVTOFG3UQrPWpbCC9kqG0vJqEWt8lu+JDum6
         KeoDdXtwW+eKUfNW3LLoo4RTiTxEcl/ToKahSI++WffeH8B2woFQkcqet504umd2SdZD
         TtvDAilh2YDBhHt8mzLmp3RoKoqhYxYFY0mVP7aw1pq/wP9rSy5Dln++eD0C/pwPMVVP
         a4gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-212.sinamail.sina.com.cn (mail7-212.sinamail.sina.com.cn. [202.108.7.212])
        by mx.google.com with SMTP id m10si1656113pjl.77.2019.06.26.02.12.20
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 02:12:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) client-ip=202.108.7.212;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.246.226.133])
	by sina.com with ESMTP
	id 5D1336F100007A37; Wed, 26 Jun 2019 17:12:18 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 879595394542
From: Hillf Danton <hdanton@sina.com>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Paul Jackson <pj@sgi.com>,
	Nick Piggin <npiggin@suse.de>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from oom_unkillable_task
Date: Wed, 26 Jun 2019 17:12:10 +0800
Message-Id: <20190624212631.87212-3-shakeelb@google.com>
In-Reply-To: <20190624212631.87212-1-shakeelb@google.com>
References: <20190624212631.87212-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Content-Type: text/plain; charset="UTF-8"
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190624212631.87212-3-shakeelb@google.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190626091210.U9g_80cMUeg6PExvsjTNhowZkrCkxoXkN9VzECLPyjk@z>


On Mon, 24 Jun 2019 14:27:11 -0700 (PDT) Shakeel Butt wrote:
> 
> @@ -1085,7 +1091,8 @@ bool out_of_memory(struct oom_control *oc)
>  	check_panic_on_oom(oc, constraint);
>  
>  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> -	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
> +	    current->mm && !oom_unkillable_task(current) &&
> +	    has_intersects_mems_allowed(current, oc) &&
For what?
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
>  		oc->chosen = current;
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

