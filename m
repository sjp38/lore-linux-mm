Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5035EC4649E
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 15:52:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7F7216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 15:52:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="pmbWR2rZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7F7216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEC368E0003; Fri,  5 Jul 2019 11:52:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9B3F8E0001; Fri,  5 Jul 2019 11:52:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98A808E0003; Fri,  5 Jul 2019 11:52:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBC18E0001
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 11:52:42 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id s19so2640899wmc.7
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 08:52:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yxeDn3omZDASV5TPIJX6WDwy+V0DYxxm+ivyAUGtHnM=;
        b=cFTRm1hRDEdWjmGPmANC5Apbx9utCnS2bxM3xovV0VaYojPA7XZCzUB0kzndor7J/E
         k9c/J9eBCLzpyhaV4V5kFm8xxcg1NF6zMk097UjtJ8bQnT1VTPR6iQ8/BrN/YkGQ+8x3
         C/eDQ8gv+s+2ri/LAN76SesNRboWDOVhM6IWNRHH5tKITv/zlrSgBw9Hw6pmxcdctSvs
         WmX0Tbnhm3hwj2RJqni8n6okflF2tZAILbn9q88Qd67L05/HmU3mA9JdKigrzoWC528d
         XVL7Qnrg1P19+dEm0MtIDibL6lXYoIQKKY+jYwwSAb8wMlUsvncCjqkfXlYhwWOt36lB
         bDlw==
X-Gm-Message-State: APjAAAUPH5rQed2935PAkhu+BiNehTB2zgQSSxuAU1KNzcDxEsvYHZN2
	i020SHw5AX7CmotkGuWOfLuA4DrSuOl8kHYJiXIdbAnM8sA7DIhhsQFjAG5RiPsOn4wA4vVhYmu
	W6jCP04igp20sqhUibKW1i7n//9+X9BjMz3WLnOUJJWatka34wISg/8ZI7K9Cu85cig==
X-Received: by 2002:a1c:448b:: with SMTP id r133mr4145523wma.114.1562341961889;
        Fri, 05 Jul 2019 08:52:41 -0700 (PDT)
X-Received: by 2002:a1c:448b:: with SMTP id r133mr4145489wma.114.1562341961133;
        Fri, 05 Jul 2019 08:52:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562341961; cv=none;
        d=google.com; s=arc-20160816;
        b=ZI+9oPIon8u8q6Egx6z0vwsAGy3+G6a7rQqAyFc0PncXHKTuO561lmRE1iJyA/Sm9e
         h51T8E23+HaLhGxMn6NG3co+mO1229eHXR3FrvVFWoQOyf6A8TxSaNt1IKu3GZjZazAP
         otxJdRlxnYU18nWnITr81ZiPRqozwv9jK+pxhGsUZ8w2DHXvuOGpQBLwiTii7Wr4js0I
         kTXx1AzdHaTffog6Qrol/75yU3ustAavDbe2ZLfeH6sEtwiGM3e+TEyqNgliZRtykqZS
         GQiQyca7uSPVji1mMMiIyUpTvSf+BGlZJm4AkdMVfbc+uuBroy6+Y8Jp7N3k9uIlUTCr
         vbrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yxeDn3omZDASV5TPIJX6WDwy+V0DYxxm+ivyAUGtHnM=;
        b=eYFWGbyrBUa5ulzC090iae+4jX+Bs/wmvgcza4xHjEXkfRuJvgrmJ0xHrRHoHdUnIz
         GXmnoiAggzFjf6V2YrjjYJ4hFPOUNXWU3glrIZ/HJ12sF9otqEGet6rK1VCDlR2Pjm0N
         uPbZnRK3cs82pAYsfMXCRzNHrWrlHRGz5YOb9VVWJGd8QDLQl9DD7HsV45lZZ7YgnyAz
         d4DrOEJ/9K38tflgdIsSFPbZkWp6FX1P04/IUbNcdJrGYL5S9NieKPBBAMSh2mGHlOJn
         G1clMkb0DJdrrjiMuIYNPmeETzc1GtRs7sAeDGl0eghcDo/Brn+U8f3fuBT8dTSk9Ohq
         gDXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=pmbWR2rZ;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v17sor7133048wrw.44.2019.07.05.08.52.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 08:52:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=pmbWR2rZ;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yxeDn3omZDASV5TPIJX6WDwy+V0DYxxm+ivyAUGtHnM=;
        b=pmbWR2rZ96zCWqBywO5tBsLFDu0cTvqu4TdanVzpSWUVN/gYu5AkG4t/O/SZuUiFd7
         fkYXo+el81P61XMz45+6FgQu+1qcw2Inl9NNrMoA3dUVciG5+8ns0eclhq7P4JStfHT+
         pwGKg11mhR0gU+h198Fc2mH8s1UEVKDxntr3I=
X-Google-Smtp-Source: APXvYqzqnCAUiDwHCeuXJUahY/4HU2LXpyk6UjQ2Ay4NSextLvLHR2uu7rfvGqlCREpoURzSBepaTQ==
X-Received: by 2002:a5d:43d0:: with SMTP id v16mr4457975wrr.252.1562341960595;
        Fri, 05 Jul 2019 08:52:40 -0700 (PDT)
Received: from localhost ([2620:10d:c092:180::1:7d8d])
        by smtp.gmail.com with ESMTPSA id h6sm9962003wre.82.2019.07.05.08.52.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Jul 2019 08:52:40 -0700 (PDT)
Date: Fri, 5 Jul 2019 16:52:39 +0100
From: Chris Down <chris@chrisdown.name>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705155239.GA18699@chrisdown.name>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yafang Shao writes:
>> Cgroup v1 API is considered frozen with new features added only to v2.
>
>The facilities support both cgroup v1 and cgroup v2, and what we need
>to do is only exposing the interface.
>If the cgroup v1 API is frozen, it will be a pity.

This might be true in the absolute purest technical sense, but not in a 
practical one. Just exposing the memory protection interface without making it 
comprehend v1's API semantics seems a bad move to me -- for example, how it 
(and things like effective protections) interact without the no internal 
process constraint, and certainly many many more things that nobody has 
realised are not going to work yet.

And to that extent, you're really implicitly asking for a lot of work and 
evaluation to be done on memory protections for an interface which is already 
frozen. I'm quite strongly against that.

>Because the interfaces between cgroup v1 and cgroup v2 are changed too
>much, which is unacceptable by our customer.

The problem is that you're explicitly requesting to use functionality which 
under the hood relies on that new interface while also requesting to not use 
that new interface at the same time :-)

While it may superficially work without it, I'm sceptical that simply adding 
memory.low and memory.min to the v1 hierarchy is going to end up with 
reasonable results under scrutiny, or a coherent system or API.

