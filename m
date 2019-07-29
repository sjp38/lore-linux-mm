Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06C85C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC05B20C01
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:33:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC05B20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44C318E0003; Mon, 29 Jul 2019 06:33:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FBA98E0002; Mon, 29 Jul 2019 06:33:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C58E8E0003; Mon, 29 Jul 2019 06:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D25CA8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:33:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so37966100edd.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:33:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cP168jQU2woUazlHlOWFKLmLo1ka6ghcLnX/xNvPtVs=;
        b=p4UxYT87sONLJ5SFESsPM3Yoqhix91jlV7unW5Ld7uktLPqGkqwAhLaxnioo04/7Bf
         1bOVWE+QCBvvYwccjqPpF9L62FG7KgGnn3Dc9cbjMH6nm0lr6Ak4zgnupdNqzX8xYD2F
         Doz/MTIq/W52qRC+zKm0B7nFY4K7ULkYyIA734Rag08sy6g7E5Oyg2+RHfZWnJD/dU47
         SU/Y4h8f5/hCwaHfXmDX+hNeQozBvf38Vhb0r/UwO75GLEV7GVpzr9P9cuM5QtbIDm3y
         BRC9MXUtQ9Mie5YX2qvMSBqssAadUOif7KdFnWOOO1Gjt9bJSg+OOr/wimU4s8dEVuBm
         eakQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUwlAVF0ccKmK4aRqb/tZW7GOmuYrwEux7GxxWv1nnmTyNOd5zc
	cCxYI9cIAjedbmria1qlWkezASho0sd+B33DQ96WFMIU0HeDmofrUsqJI4vmLTiyCU5RUICnZRO
	b92c8kMMSjBkTsvT8UjE6Tpvy52geitF2QpjPgUQzGiDy06NNO/c8t1QxSHUPLIQ=
X-Received: by 2002:aa7:c554:: with SMTP id s20mr92908365edr.209.1564396389402;
        Mon, 29 Jul 2019 03:33:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYWIghwB0VpZusRvXdgz7Cf24douQnTFJlLr43R69CTPQCYQZt3fwamnCaBy3jkPqZiqZb
X-Received: by 2002:aa7:c554:: with SMTP id s20mr92908302edr.209.1564396388534;
        Mon, 29 Jul 2019 03:33:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564396388; cv=none;
        d=google.com; s=arc-20160816;
        b=IYyfRPCW9ooli/voWOVJ6br8hufPaBbbDu2qhb0ykY49ZH3liRsy+ZeQmauj/b21yu
         fruNogNHVU8Vm6XZN0s2lmZoGyW4lWY5RovPthNvIUwahhE4Kfli8w95Pn5U9aiLW84C
         E7AOtlc3O+Vq7UZjWBct4nV39uvb0GZdzrqNNc6OakJ+b0Tn2tC1gpoK8LAeptGzO50o
         YpXSgMdtXoGbrncT5RFcKa1iqV5yalu2iNylyzjkZuWP0di8ttVUC3770MywTb9rEdvZ
         ocXvZGLdU3dWAi3leAiB1qfBO21VC8I/5Cg9osWas9vnZM/Oj347LjwrfclEvL6MnwHr
         +rQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cP168jQU2woUazlHlOWFKLmLo1ka6ghcLnX/xNvPtVs=;
        b=gMNSLZAb6msnd6JSMfKN/WObMI+AOoraLLZJYsdPM6whxmYwF/fhkBYEHPPqKicOL3
         yTPVMv9047rbhx8ex40uMIi/8G8ZdmroJ+HeysYIw8ZcWV9UvlFPSmX1lPWmJPZxQGXY
         B83uHVxsy6UgABfPlhCYtYKwilILKzOQw6+O3QHC7pANFuO8pciTZBoeO2gUF9k0jSr6
         hg44JdPMMhiGo/076txlTtcrEqVL8KvlYTjS70xopCN+Ed8sLyRBrNY/BNJGd4BfPOil
         ocC+9vilmd8HE56v21Z1plMXXVrvEv7pT//Yd+Voa7fth7VD2f0VRyfvIQ82IVjNl60X
         TjRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g24si17535612edb.391.2019.07.29.03.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 03:33:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BFE98AE1C;
	Mon, 29 Jul 2019 10:33:07 +0000 (UTC)
Date: Mon, 29 Jul 2019 12:33:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190729103307.GG9330@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 12:40:29, Konstantin Khlebnikov wrote:
> On 29.07.2019 12:17, Michal Hocko wrote:
> > On Sun 28-07-19 15:29:38, Konstantin Khlebnikov wrote:
> > > High memory limit in memory cgroup allows to batch memory reclaiming and
> > > defer it until returning into userland. This moves it out of any locks.
> > > 
> > > Fixed gap between high and max limit works pretty well (we are using
> > > 64 * NR_CPUS pages) except cases when one syscall allocates tons of
> > > memory. This affects all other tasks in cgroup because they might hit
> > > max memory limit in unhandy places and\or under hot locks.
> > > 
> > > For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
> > > of pages and push memory cgroup usage far ahead high memory limit.
> > > 
> > > This patch uses halfway between high and max limits as threshold and
> > > in this case starts memory reclaiming if mem_cgroup_handle_over_high()
> > > called with argument only_severe = true, otherwise reclaim is deferred
> > > till returning into userland. If high limits isn't set nothing changes.
> > > 
> > > Now long running get_user_pages will periodically reclaim cgroup memory.
> > > Other possible targets are generic file read/write iter loops.
> > 
> > I do see how gup can lead to a large high limit excess, but could you be
> > more specific why is that a problem? We should be reclaiming the similar
> > number of pages cumulatively.
> > 
> 
> Large gup might push usage close to limit and keep it here for a some time.
> As a result concurrent allocations will enter direct reclaim right at
> charging much more frequently.

Yes, this is indeed prossible. On the other hand even the reclaim from
the charge path doesn't really prevent from that happening because the
context might get preempted or blocked on locks. So I guess we need a
more detailed information of an actual world visible problem here.
 
> Right now deferred recalaim after passing high limit works like distributed
> memcg kswapd which reclaims memory in "background" and prevents completely
> synchronous direct reclaim.
> 
> Maybe somebody have any plans for real kswapd for memcg?

I am not aware of that. The primary problem back then was that we simply
cannot have a kernel thread per each memcg because that doesn't scale.
Using kthreads and a dynamic pool of threads tends to be quite tricky -
e.g. a proper accounting, scaling again.
 
> I've put mem_cgroup_handle_over_high in gup next to cond_resched() and
> later that gave me idea that this is good place for running any
> deferred works, like bottom half for tasks. Right now this happens
> only at switching into userspace.

I am not against pushing high memory reclaim into the charge path in
principle. I just want to hear how big of a problem this really is in
practice. If this is mostly a theoretical problem that might hit then I
would rather stick with the existing code though.

-- 
Michal Hocko
SUSE Labs

