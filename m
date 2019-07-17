Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E8DFC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D010621849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:36:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="s+ad5D3H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D010621849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 687106B0007; Wed, 17 Jul 2019 13:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 639188E0001; Wed, 17 Jul 2019 13:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54D6E6B0010; Wed, 17 Jul 2019 13:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2383A6B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:36:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so12363453pll.22
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:36:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kevqSiJxsbEDhmFvXT17QTCK6a0eC0i3z1ong8Uuwzo=;
        b=Irs/4bT4i/POcYrWbNx/b4+Omnjw4+8bSyWqvrqXnDQWR430DeEVUvW5ZSuW7ly266
         kBiXdlVWq4lz5ixjZx3Dx6pswxjoxAaCbo8Y7hrW2/5VsaAfGwD7+7arJNtDq4HqdcCK
         OEHBWW9rd6ubxnyBEOpAxSN5/dLgpLmxyCWqapUXnbzaFcaWZ70fihrhk937+FShrMhN
         j+cPPZRzGMWugTxGpIT/6G9SLOyrFJLpaitL10gLWbiMbqXVQ7HEBmxwQgpMpEFGHR2Y
         d2dso99Tt4mF7wItp3LQZPbc2mUK30/ljuRI1/RCBaGSI6he6MbcgDeG1WG/JvCZ1cHd
         Se9Q==
X-Gm-Message-State: APjAAAUhlG+eh3wydDIefG+3nBlbsi+ZQ6xN8RQ8p2skP3Ju6CCaDpLI
	zTMivmAQHmlPfq3AvTTvRuWseM9wf3i0oUBWL/umg2H4YWnKrDbcMTralFVWDeQS3PaMYGY1AIn
	oeMpaBa971YuiNu8fylVfh7l94f/g9uo+LVvweUjj9PPgRpM9hB593JvtYrfadu60sg==
X-Received: by 2002:a17:90b:28f:: with SMTP id az15mr44949016pjb.18.1563384988826;
        Wed, 17 Jul 2019 10:36:28 -0700 (PDT)
X-Received: by 2002:a17:90b:28f:: with SMTP id az15mr44948936pjb.18.1563384987770;
        Wed, 17 Jul 2019 10:36:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563384987; cv=none;
        d=google.com; s=arc-20160816;
        b=eEzYLAQxLtuSfZn2qHB0mpkf/jDjVb2D8AA5P01KJwNW3O+RDo21RlNIoVbzEBAfxh
         clu8q68UKv87hZX+bQdsq9jQcv51ktxxZ61UusTA0bL9tpzZmDbZBXwmylW+OQzz6/AF
         vi60eKHymkkETYuZgmB36A+Q4jrJYSeSkaoZoBWxD5nY1fAQPRRvjARx/3PcgNvtzUW6
         rivTiepZVTDN+qxh39Z9+jPZjMv+xLXKxZesNbpfnVa9EvEJ49HhVkgr1ED/H5xQPOm5
         b6TEDUz/vgedbSVo//Qp4rM0y358hWlJuTttxu1BCG7Y4ndRtHsdYF8hCStXsIWHHiLj
         vpsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kevqSiJxsbEDhmFvXT17QTCK6a0eC0i3z1ong8Uuwzo=;
        b=xAeWOOVCsd/B+KZ5V2bo4MKoQpzF5axB9FAyYhQ1QeoQHVQ8weoFKWj26sZFOGwBWm
         l4Yxy7N6X0GrcYxfG8M+IMck9hVuZdYvO9rwWHKE9g2gnNvN+SZQWnH6/RnRuLPwR8e+
         kp/ta3hf+8Vfb/i2crEj61oGlC8SoryAz6Ubamrv6bQTpqQz4pJTEjfJ0JBGOEMa0GRK
         iUnvv0C+g6r2pf8Vxs8wDVp4rlNZ17RFVkkpFTg3a/Qy8GAnJ5tfqreKzfXj7EVmXmC2
         r5yvTADIhZJAO4g1+DFM97DWfOxxfuCMpP75DcBOb+VXKTLUfprKqASB/+ayhW8RugzP
         H6lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=s+ad5D3H;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j5sor30668010pjf.20.2019.07.17.10.36.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 10:36:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=s+ad5D3H;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kevqSiJxsbEDhmFvXT17QTCK6a0eC0i3z1ong8Uuwzo=;
        b=s+ad5D3HLMkro+DDkazkpKnGSOtq0joJ9Dhea4g9PK8M83SoVUqNCj+XFLDhLVFCXN
         LhSDJJlL9veZeJTb8HGu2EHXbdqc3MGn+X2TEylr3LuYoXWRGxc6OV9R31Lal6Ta7siR
         SC4Daabecb3ER5mJq2B/zliFco6r8xtP4X4XixA9e9wg2lQQ0up5OlWsFAEsVcbhUBnj
         sNGlA3yJuWKHnl/gK0iHUOIxG+SLTlurFGvUAQHqzNkSaw+w9MBJJuQY61aFmJwnd5JR
         NCZ7kpch6dnxKmD1mdMCexQZQPR+nirg656XJ2DuCckrTqzD6TBwz0PsSmeP83mAoanB
         yWCg==
X-Google-Smtp-Source: APXvYqyD6WnsaJ0bItM20gy/k7ygrcTP83wuDov/ycTiAnYjvD2WHzA2+KiUtWbJ3BsDF7phWpmP3Q==
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr46121179pje.130.1563384986821;
        Wed, 17 Jul 2019 10:36:26 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:4db])
        by smtp.gmail.com with ESMTPSA id g4sm33697577pfo.93.2019.07.17.10.36.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 10:36:26 -0700 (PDT)
Date: Wed, 17 Jul 2019 13:36:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/memcontrol: fix flushing per-cpu counters in
 memcg_hotplug_cpu_dead
Message-ID: <20190717173624.GA25882@cmpxchg.org>
References: <156336655741.2828.4721531901883313745.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156336655741.2828.4721531901883313745.stgit@buzz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 03:29:17PM +0300, Konstantin Khlebnikov wrote:
> Use correct memcg pointer.
> 
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Oops, nice catch.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

