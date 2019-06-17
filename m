Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5D66C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84F01208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:17:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84F01208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219CC6B0005; Mon, 17 Jun 2019 12:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A37D8E0002; Mon, 17 Jun 2019 12:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 092C38E0001; Mon, 17 Jun 2019 12:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD49D6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:17:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so17077409eda.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Mu+danKZM8caM+1fxN5pXov731LW3X9aAVsH26JPQm4=;
        b=VzeQx4h7vLqo5aB2rpCifoZ8FS4xhcIM2FlKFdXsF+Dwg7zHjbmTYMGl3Pne4gDqVp
         ODxMWr6BrEkv6VViquyAmugl2KHaPVe42U85OskcbFP/S6Aku5wWD8YKVreM+SG8qW2I
         ysBoHPKtS5O0X7Y20Q75Np56ojOOI2Y6fZ5tEX6VoCKXlT5wLQkydySHUpzMeb75yBKi
         FYRrTX4SGbhN1f/FN8svo061+y/7AnvNeh09CRsVuViggyqzYHTR1XDyC4SuAqGxUgPK
         ZVSfuTmIPdid2/RqXZI/x73NFPfTp7z4eDoIBj30NYiQW4ppaDpTdOTKHxMtWf+XCUSk
         i3BA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX6BYG8aLYYdRV7hzZX7UBgTMztbInYa8pA6g2aTP7i2EEjCMxw
	f2LjGD9qOyFBISfk6/HmP1xJ63e/VLZYUDUBdZaa2XO3Rb4GxfCv2gJoOeBjhqGeyNoXBJkLJn9
	7grjsLWnCGSLbD6vgSxmZ8JCu4tv4ZI99TEBevCyowIp2Bb9tFKt38YHwJpq+55o=
X-Received: by 2002:a17:906:c4b:: with SMTP id t11mr18048005ejf.33.1560788225258;
        Mon, 17 Jun 2019 09:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfxRIh2/edYpssUkkAySJkEsO/fMm4qIEEEjo8yk8/1sia85YMbpEbMD81K14ULcoCU1sk
X-Received: by 2002:a17:906:c4b:: with SMTP id t11mr18047945ejf.33.1560788224529;
        Mon, 17 Jun 2019 09:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560788224; cv=none;
        d=google.com; s=arc-20160816;
        b=FMeAVoMni5xlNqbiO9uvxT+ZT6jS5AWkmTPgdD6TXHKHTQo/uszYsj3QNeOkf1KJRk
         EQQ9KoqsKyvsvO3ayCEduRYsjIRLZF3lCA/B47xfHvo5lAbuEWWsOxHaRJj4/EQhyhw9
         rG3uMa73vAKRLXckYdEVKcyxP5woE28ATy8VRV2qofUnlH9Zew9uhJj17kmH10VZcZ4V
         4r9kv7EwrHJTwNYfOb45c5ResRpSwKpxszp5tiZKTHzGgfEBLYljl6PHtyk3hDn85G6v
         rrcWgh7Cu4MYjLzIHkC/EUik7BgCpHzhhvr7yQ1USQAAGtY/P0rEoWUFS5oz74HkceDc
         wEMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Mu+danKZM8caM+1fxN5pXov731LW3X9aAVsH26JPQm4=;
        b=qKfOMTEbaOVWGuF1Wj3b+USFVTANv2mZ0lYJy8f9IbOJh7T81auzxqK6b3wZ9WC8ic
         90CX6TJLeQ8WnkXKM69tzIB8ZDVuM87pIuAf27em3kGEMiHDbKaCyhGBzzzJOS/rlMdl
         NtHMBMlaz9LYblAH9QAIu58+pt/P0tU3FGJ1mqpyklpYTifDCGtJD5FTZ9Zov5mIrhK2
         CFEB36S8ajSzU98gwHSo7bokPFXscfDtW4o+KGg9AX1QwsgeWkNbMfK9wHi4cgPpga/e
         /2xBr5liT/k4qHiGj9Sl24us3D7fA5DGHVYa/bLZy8d3/M9e5pbt0Z5Z+6YRlxTUYCZS
         xoLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec4si7412503ejb.68.2019.06.17.09.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 09:17:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0D5E8AB7F;
	Mon, 17 Jun 2019 16:17:04 +0000 (UTC)
Date: Mon, 17 Jun 2019 18:17:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm, oom: fix oom_unkillable_task for memcg OOMs
Message-ID: <20190617161702.GE1492@dhcp22.suse.cz>
References: <20190617155954.155791-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617155954.155791-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 08:59:54, Shakeel Butt wrote:
> Currently oom_unkillable_task() checks mems_allowed even for memcg OOMs
> which does not make sense as memcg OOMs can not be triggered due to
> numa constraints. Fixing that.
> 
> Also if memcg is given, oom_unkillable_task() will check the task's
> memcg membership as well to detect oom killability. However all the
> memcg related code paths leading to oom_unkillable_task(), other than
> dump_tasks(), come through mem_cgroup_scan_tasks() which traverses
> tasks through memcgs. Once dump_tasks() is converted to use
> mem_cgroup_scan_tasks(), there is no need to do memcg membership check
> in oom_unkillable_task().

I think this patch just does too much in one go. Could you split out
the dump_tasks part and the oom_unkillable_task parts into two patches
please? It should be slightly easier to review.

[...]
> +static bool oom_unkillable_task(struct task_struct *p, struct oom_control *oc)
>  {
>  	if (is_global_init(p))
>  		return true;
>  	if (p->flags & PF_KTHREAD)
>  		return true;
> +	if (!oc)
> +		return false;

Bah, this is just too ugly. AFAICS this is only because oom_score still
uses oom_unkillable_task which is kinda dubious, no? While you are
touching this code, can we remove this part as well? I would be really
surprised if any code really depends on ineligible tasks reporting 0
oom_score.

Other than that it looks reasonable to me from a quick glance but I have
to look more carefuly.
-- 
Michal Hocko
SUSE Labs

