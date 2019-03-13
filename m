Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE278C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:07:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CE2B20643
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:07:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="NGA3Zsso"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CE2B20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D4158E0004; Wed, 13 Mar 2019 12:07:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159C68E0001; Wed, 13 Mar 2019 12:07:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023838E0004; Wed, 13 Mar 2019 12:07:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9C338E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:07:54 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d18so3086383ywb.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:07:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UvCYDdnf/RFGLbHek+yGIUV6NWeZaltScEJghB6OD0Y=;
        b=ERuOxH2ulBF/ObMtNFlFNrtQGRj+ZgkOl+w9SIibMZFrFd1im6rm8i7JnjVYg47jys
         GN5cDgReTefNYnsXs8KaabEUwnL0dDqD1MY+Qv/Fv2OPEmO0QInEvYRotad0oh+ccgZn
         5D/W/oNUG63+uGOdyWbo1RjaQiZLU2aEfprLL0D+ZjAsR93cjZz5Dh50tQHdQ2hSemC5
         TMGz0JqEsTfF4wWuMpUP1Eo/gYLOCu3f3bJwPZOMdfJ56wT58sXbgIj3PfYLmxuP5s74
         54WzkBlC2g25+1XYPuf0rjE1Da3MJB24OBWdjC7a1+2vpQstjnPEO1yCP0X9DlDkBWC2
         FWQQ==
X-Gm-Message-State: APjAAAUSeegTd9TGaBCj5c//RC1lZxvS31mUgSlu9btm8iOqyM5gGeTm
	tJQ44w/76AcVpxYyHl1XujrCeexcmoQnGDsA4VrTYeAxNpyvDqXeKTA2xAvHT+TmWJ11nM8W/lJ
	uGo7t+AqtL8DDa8w83IO0kVbCYGBsnv9byFiUGSQDCKeC+FJ57GXLA+B0z/rok6DxSIGWUvBIWA
	WzjHh4Eh0n6ei0/H+Zx3gWvLcblEWI1domUmFxTdX/nGU2ZI+EORBT5N6fVc+5u+NpWDInkpgKP
	x5tcxOesfTh5AUbruQYl5FDwosx22dV/zazCUu5fbvDx+P0BeEb0Y2WunopuTof3Zujeio0cPRl
	h1nvLOOAu032MklaVLoBpAiAbo+zOqfOfVdGDnzJbAYlL2SkgibW6iSqJ9lc2gGZdXcZ4G6o8nO
	v
X-Received: by 2002:a25:2556:: with SMTP id l83mr34736379ybl.510.1552493274491;
        Wed, 13 Mar 2019 09:07:54 -0700 (PDT)
X-Received: by 2002:a25:2556:: with SMTP id l83mr34736300ybl.510.1552493273708;
        Wed, 13 Mar 2019 09:07:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493273; cv=none;
        d=google.com; s=arc-20160816;
        b=Zaz3XMymK+33eq2i2TFV0J780e+ao9HA1is1a/QFl89rxlayJOFwo/c8ZDRuhqZeKh
         slXstYmMmxA+ZMdWyX7LnDxqHbSHsW/9rYfo24Suf72IFBb9D1AfVmDR3MaDFmeRaJnK
         W7ZypTDrw1YdzvDuVyKI6VbTHIAwXItXOjXZR5zVyXQ3gsbcsZaNyomo9ogu055tLwc2
         rGFZE5FF7bB8oNWhD5g7SWNaxv/pbIibKXOBfdrdZJRSCaV4UyRn1uaYU9721PxDqU+g
         GTncEzBVB8EWH33gbfA3vjsU6RRflLbMONUTftiRTTJPUl0WY02cLRNXiY8P5XeKECvo
         aroA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UvCYDdnf/RFGLbHek+yGIUV6NWeZaltScEJghB6OD0Y=;
        b=urUUoA/VLBupiCByk5Sx9yHEq4eAVTLH67sD0/cjLKV1oSywoOUvVn3AiPclyMnZHt
         x2033zlAwjrEpCeLYHJLsF4Cm5dyGtz+idR7Kq9ForC5L2yM8pZb/9yd2c6lE2r9nGWF
         6nx/Ji70hcE1IQholTp1/nUlq0Ip1hII655u3nCavyoh58NE0BEyit74tis+0qSvN1AV
         tUKtb8YYlZ+PZuZGGh0oJfv/O84cCRfSL1+vF/JS9uPuTqHr/jGk1pGWUBKbW5s8nb5W
         R+AgnAKnD7gRvmzhN2OcPwlV22NbFsGpY5XgemGfyY0d5vWX7vqfPOUA7eR8uQArZ/1Q
         zTCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NGA3Zsso;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor6233071ybz.150.2019.03.13.09.07.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 09:07:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NGA3Zsso;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UvCYDdnf/RFGLbHek+yGIUV6NWeZaltScEJghB6OD0Y=;
        b=NGA3ZssoNF/S9CAdceP1jG1KWyrw56jfjrQz+ZkNYA/b4MTGXmhZddavjbZpoEE8Tc
         m/r1gIvzg6gmJHVSmepHn8ieLciOciO5GSihS5Mq7DZfF31OIO+vJ1T7UsAz8Kx6CLlY
         spDLc4f7IGXfe72lp3qMD+etk0Cz+ltEYDO+nh9+0mSbxz10yc+Sx8f8fjTYCc1OVV96
         +UVe+ZABsuLQIxrpyc+fKeRrY1UVbtNGZm6J+lMYP0wdvFChFYJVHe+7NKiseJhc3eWf
         vFE7OlTj7FJ3099WcSVXXYJitcCglSYIfSvn1QvBFj8SkPpLhsh5pmfpMG3CD2CEuU1S
         3z2g==
X-Google-Smtp-Source: APXvYqytV8vriWXbd2cv/6S1LiJ2RCYtAwfoGBHfkDec1dlcbynkQD7DF6ZQInBeFxyQolTFnHo6wA==
X-Received: by 2002:a25:2bc3:: with SMTP id r186mr19264999ybr.292.1552493270952;
        Wed, 13 Mar 2019 09:07:50 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:5e6])
        by smtp.gmail.com with ESMTPSA id u185sm742557ywc.1.2019.03.13.09.07.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:07:50 -0700 (PDT)
Date: Wed, 13 Mar 2019 12:07:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 6/6] mm: refactor memcg_hotplug_cpu_dead() to use
 memcg_flush_offline_percpu()
Message-ID: <20190313160749.GB31891@cmpxchg.org>
References: <20190312223404.28665-1-guro@fb.com>
 <20190312223404.28665-8-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312223404.28665-8-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 03:34:04PM -0700, Roman Gushchin wrote:
> @@ -2180,50 +2179,8 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
> +	for_each_mem_cgroup(memcg)
> +		memcg_flush_offline_percpu(memcg, get_cpu_mask(cpu));

cpumask_of(cpu) is the official API function, with kerneldoc and
everything. I think get_cpu_mask() is just an implementation helper.

[hannes@computer linux]$ git grep cpumask_of | wc -l
400
[hannes@computer linux]$ git grep get_cpu_mask | wc -l
20

Otherwise, looks good to me!

