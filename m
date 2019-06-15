Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8864FC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46AB82183F
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="Yo6/9UyM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46AB82183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C65296B0005; Sat, 15 Jun 2019 12:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEE488E0002; Sat, 15 Jun 2019 12:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40C68E0001; Sat, 15 Jun 2019 12:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC936B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 12:08:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so3448750plp.12
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9I928AV16ooo9jWnHVJ+TbU1BzYjl5gqs5k1AXR35Ps=;
        b=YtnnmEx6mauUY4TgZFuj0pyT+Q+gn6w5VUuCoqPPkMvTJn+RiyGH3HkzfwbHCgU3gX
         T9c7pSj4CV39Jk/iOhRAiKVK9OM+CYTa8q/xC6tXi3vJ5gHrPaxxBrT6pUVuZucQpxSJ
         J+OHwPytMCCoGgOcZRgnDKhf5KM97ZNaT9J4FDKRLKsA6L5av0DCxv31v/qf9SUFIFyT
         Z1raO/4kM1NyW0xP4gRa3BDaKs9YKsX2ONoDm3drGuEJecYEq1TdUGqygTi11woKEHqs
         u7YSUSKyx14pKL7QXie3vPdZ+lXPwlpdXSLdOLXAHKkVT9uhh1wP7hEU4w12nBdOF5fR
         nFvg==
X-Gm-Message-State: APjAAAXOuqVSAfK+7R2GNXREgtmlyPNUDW+ZCKLcfps3NXhYcHH3Sank
	oIhp/v8jRexEEgLDQxIdr++OkkaD3ahr/6/r6+q69S3XMGwVb1DwgGNuUsJl71O/tVs9txzeQgb
	xHzAtEhvIjdQRAEBFh8rRIq7Ie9b8mi2PCvgapIEjX++d3U/PWbDIQVx1X/pRHzpMVg==
X-Received: by 2002:a17:902:8205:: with SMTP id x5mr355016pln.279.1560614905922;
        Sat, 15 Jun 2019 09:08:25 -0700 (PDT)
X-Received: by 2002:a17:902:8205:: with SMTP id x5mr354979pln.279.1560614905329;
        Sat, 15 Jun 2019 09:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560614905; cv=none;
        d=google.com; s=arc-20160816;
        b=r5HoKfiAhZWzQFuSVgxXGSqzYYMxuI2zLeiQ4ZbC4yjE4ocf3xlynnVzsR64luJxf0
         kLGBRlqLrdARtfBPth2NWFH//klNXw02vJW69ucUuvUU/MK0OcxInqw5zKGZEhl/MgW0
         3h6y05n56CnPtVlEn7ic3HZ9WRQKZA26lQTXP08+w3LNBwO6Zt4vT4kVXZpu3VTvmqiB
         Ei6uxjNsjcH/61jBgPVJM9MO0Xuor9z+IfDpNL9rNntyfZk43ACPwJNUtueFn7KCTtu/
         4mnE53hDndWAGUDERurpQoGwwFSyLMXEBwNgI2tLixc5uRg1RfaVR2qh91nDIKYoH/ZO
         /kqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9I928AV16ooo9jWnHVJ+TbU1BzYjl5gqs5k1AXR35Ps=;
        b=z4KBu/BKxpNZvFAjB+CWeTuiSpWR0SmbGhmrHHUP133GVVFBUOlqeXtHp2AbL8HA9T
         D6noDSnEtvdipbh9zYPwkeaGsoj9hJqKhP+vsIKn7fVx/fezDAYyR6WX+SrXm1Stn14N
         shYDtniW/P5XQoH30E24zhMYjulqnpB7zFj6yG0vweEgK3QIX2XtKGcpT5tWd9D/GrD3
         XiQL6ANck5mYjEodAWkgQL4Fv92aP1yw5ffMLKUKBtx3w5P+T26SSgubojLjMBDiMw1L
         93omPahLA8TrhxHgtUmkmyprCjoj4KeQ3d49cHuCz1/veDjcKuUaE83VkVR/NkswycA2
         PZKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="Yo6/9UyM";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor7783604plp.4.2019.06.15.09.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 09:08:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="Yo6/9UyM";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9I928AV16ooo9jWnHVJ+TbU1BzYjl5gqs5k1AXR35Ps=;
        b=Yo6/9UyMOSre2p9e2TlPcj5kPGAPwe0jyHAYNg1xpnQC6QoXxEXlu5DHEQqYKZGJ+o
         eTsctghCJ9Gqwhw7P2J/7QQirAPJhd8amp1PjtjqTqhINbzoWY9zclMYpPwwdyvovgE6
         U0YT4KT6spSRayg9itsoKCz+i/JW1RRf06hI8=
X-Google-Smtp-Source: APXvYqxBTJ37ihL2DutojGbYbJbHsnfGkRbUmjSx6gSy91LHlFif6NhzN1Dj8LyE8MOq8FIkngDD3A==
X-Received: by 2002:a17:902:25ab:: with SMTP id y40mr43063854pla.268.1560614904698;
        Sat, 15 Jun 2019 09:08:24 -0700 (PDT)
Received: from localhost ([61.6.140.222])
        by smtp.gmail.com with ESMTPSA id s15sm8391955pfd.183.2019.06.15.09.08.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 09:08:24 -0700 (PDT)
Date: Sun, 16 Jun 2019 00:08:20 +0800
From: Chris Down <chris@chrisdown.name>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] memcg: Ignore unprotected parent in
 mem_cgroup_protected()
Message-ID: <20190615160820.GB1307@chrisdown.name>
References: <20190615111704.63901-1-xlpang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190615111704.63901-1-xlpang@linux.alibaba.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Xunlei,

Xunlei Pang writes:
>Currently memory.min|low implementation requires the whole
>hierarchy has the settings, otherwise the protection will
>be broken.
>
>Our hierarchy is kind of like(memory.min value in brackets),
>
>               root
>                |
>             docker(0)
>              /    \
>         c1(max)   c2(0)
>
>Note that "docker" doesn't set memory.min. When kswapd runs,
>mem_cgroup_protected() returns "0" emin for "c1" due to "0"
>@parent_emin of "docker", as a result "c1" gets reclaimed.
>
>But it's hard to maintain parent's "memory.min" when there're
>uncertain protected children because only some important types
>of containers need the protection.  Further, control tasks
>belonging to parent constantly reproduce trivial memory which
>should not be protected at all.  It makes sense to ignore
>unprotected parent in this scenario to achieve the flexibility.

I'm really confused by this, why don't you just set memory.{min,low} in the 
docker cgroup and only propagate it to the children that want it?

If you only want some children to have the protection, only request it in those 
children, or create an additional intermediate layer of the cgroup hierarchy 
with protections further limited if you don't trust the task to request the 
right amount.

Breaking the requirement for hierarchical propagation of protections seems like 
a really questionable API change, not least because it makes it harder to set 
systemwide policies about the constraints of protections within a subtree.

