Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6BC5C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:30:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4720D2173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:30:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4720D2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B151B6B000A; Thu, 18 Jul 2019 04:30:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC4B86B000C; Thu, 18 Jul 2019 04:30:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B5DD8E0001; Thu, 18 Jul 2019 04:30:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 616BB6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:30:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so19509043edc.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:30:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=W5eHjBRZw8gNS2YmyAIfMzof/dyZzkT3ocB8fYxkzoQ=;
        b=Tj90Gl2U11mclW8GV/xnhty/EwwWM1pEJ5kmfGFlpmfM+uBNIOmTBIApDqbMBEHuPs
         NHxfBxBIAoGz6MEfnPvq+o/QFc4tDh7KSmMzcaveR45QibQCpRztQwMadSTj5pVQBKqe
         w6IdG122LC7/qmTjMJfS3BgblEZoHcbE9yh6C4AdZRniJS5R7Q3JDHDVS4FLjB6l/gg8
         S0CGJMI/FLabPJfaNwaIEy6SGZZjHp3rAFgpiY2oFg6yr6lx3n7VMCJYUbdmAqFmdE79
         ppNkzKqz7qrFjy62iyTCTqvbqfgJB2PN+SIaBMdi14CxCa6eEEKLuZ7gf5b8UfxU2OVs
         0dgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUdnRad8TcxhXCk3JqEX2cI3Ima9jfGNpwSEBPiVF9VsKMOmQvm
	tLy+D5PL1CxI/l+dTxubdD9N5sPnw5uaLYvg9ZAi42VFlDOI0N5maAmWBLXIlrH6TSh6R+Dh1s6
	LyIhIoX9K3Js+h+1d/FQ2FUiN5Fn2Uutp/3N7fM298tiCPjojkrGPmkjfomALevvQCw==
X-Received: by 2002:a50:b635:: with SMTP id b50mr39082725ede.293.1563438618861;
        Thu, 18 Jul 2019 01:30:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL1qw7sYcf1GTwov5Cd5V6I33BZfeGOatKS6XHuMRdFc1XQVQcPOsgHBygd+A7BvFhE3s5
X-Received: by 2002:a50:b635:: with SMTP id b50mr39082669ede.293.1563438617951;
        Thu, 18 Jul 2019 01:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563438617; cv=none;
        d=google.com; s=arc-20160816;
        b=LEc1equJrMnEQHbjk3VmxQ7Bs5XKPxQK9pG5C5Wf5tkhrN0xab7ePlVrWKwfZlyPmO
         FePGeFonM7v109gagk8d/VxwGH/AU1LzOdTGB3Z+SvBDky8pcXBIBmo6bnA0ZvEpdIjX
         0BTmMD9kGJ4Ox45E/wcRFKM+gDMG/WrB6EnxmDnykMva/wVGIapU5MjemxrwQHZQ5Iub
         kAftX5wiwBE4uSEO/bXnlkX55ubzQA4ZVkbhel+hvjLbEs+mmdxG3UTmDwasx31/fWQ8
         dMyYS0RTtBpN2x+nZN69fkKhUr9ts+MmPP8W0DhYRFJeS2ybjuod3nrANVcxON63B3oO
         wrtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=W5eHjBRZw8gNS2YmyAIfMzof/dyZzkT3ocB8fYxkzoQ=;
        b=ITif0AGdUKQPhCyz9JeJpkRJ58IgsRCixxWXKZIOrN5CUGkLazd1Rpm3L4xE3ra3kQ
         vn4HjE4bCwQBZ6k53ILfkSQUWHTGoWW2RUywIlbJwl3IdHtYlYYP1sOW+nnjeg/+735f
         yjOzvwB0zinRsWr/ZqlF+8oUJHv79ne6IEi60pIIn7oH7hkXW9F/D0m0Y1zTCEduorYU
         DgVuiH6Fw2JSdeFbiROufRLLeHTiEVLK8oQIWm9+YIibmigTK2cjoPfsNKH/yEAq1f9B
         Gc0lcRKGftObTEw5aso46jCvNvFOJmMv3qC6jvTUvVfR27jAghGr8nLVinnGxlhYEJXo
         icTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si517098ejb.211.2019.07.18.01.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 01:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B239ACB8;
	Thu, 18 Jul 2019 08:30:17 +0000 (UTC)
Date: Thu, 18 Jul 2019 10:30:14 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
Message-ID: <20190718083014.GB30461@dhcp22.suse.cz>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-07-19 19:55:01, Tetsuo Handa wrote:
> Currently dump_tasks() might call printk() for many thousands times under
> RCU, which might take many minutes for slow consoles.

Is is even wise to enable dumping tasks on systems with thousands of
tasks and slow consoles? I mean you still have to call printk that is
slow that many times. So why do we actually care? Because of RCU stall
warnings?
-- 
Michal Hocko
SUSE Labs

