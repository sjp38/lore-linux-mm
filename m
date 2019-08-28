Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F7CC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 20:19:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9949822CF8
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 20:19:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="G7R57zwJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9949822CF8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F80E6B0008; Wed, 28 Aug 2019 16:19:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A9986B000C; Wed, 28 Aug 2019 16:19:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BF5C6B000D; Wed, 28 Aug 2019 16:19:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id EDC396B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 16:19:00 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 839938E4A
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 20:19:00 +0000 (UTC)
X-FDA: 75872950440.07.error67_4e9254f86c128
X-HE-Tag: error67_4e9254f86c128
X-Filterd-Recvd-Size: 4404
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 20:18:59 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id k13so1008681qtm.12
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:18:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XtILyRH8l1LUvlvqjqN9r44tpqWCdmlEVajO5M2YwAs=;
        b=G7R57zwJime+xE+GzBWwJdF//H/oggEzvdCGb3Sm4QSKceQy4xJX36dlajnviEjIGY
         /Chz/Rqpb5TC9IompxAZv9cado+gjUgTNZfirxP6v5BslLLntwCQow/9oG4Fm/QR98tg
         W4eaEhkxGKBgQ7AELZ0p4EzBvy4FOsHKiXM1dAnNwNEncsrHwFFx5/DTvDQeEQH+wp/v
         hOQkrZigJB9531ETS0wPZGkGtmmNhxJxJ0Wd1Aad/xmc9Uzq2ApiBfSRMnR3XDyyBypt
         rhrVvxGhjNTN40Dpka29XdZu6T6xiCodQVec33YIAyWksfo69xBlStCwi4LJcslcoo4V
         qJ2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=XtILyRH8l1LUvlvqjqN9r44tpqWCdmlEVajO5M2YwAs=;
        b=M/GXKCRc1tosx091CUqgeNvq6QXaFlIqUfn0hLx6WLao8QkoASo0NcCxDfybrlD/pn
         IQkZCqogfEoDjmVAK+xoj3tJP6t+sb01dhzo8X7Y69GKRXK8OAnP1B/oukV0pBxRx89t
         MkrKHhziNuQZ2LzSjCUgwvx9vjd8LutxLUjF0YxlHxbkyeFlq805beBtBl5yTZTKswi0
         j+2CsCMtIoxHUVOy1kED5wpPE0sJAdzTz+fGvhqYY4wse2/93dczlp92AfjKRsTK4EyF
         9e3rwzPIC4rA4QkBGcQUw/eqfAzDeqRMHJ8L3/ihH/QSuE6zPa6qsUPAHeeL102a/jsC
         rYQg==
X-Gm-Message-State: APjAAAUg/GEOB/xZoEG7iu66O4loqwo2VWGFbQrynVZqbKcfKkRmYDAy
	k2Q1ginphJRFmEWFM273Q2Zsdg==
X-Google-Smtp-Source: APXvYqzU7b7B+zUOBiS4wMS8VdYSMLF+ly4yTg2sy8ZcKePkRh6wzfscOlpeKWtoEIcjRXIAfVUdzw==
X-Received: by 2002:ac8:1241:: with SMTP id g1mr6305448qtj.145.1567023539198;
        Wed, 28 Aug 2019 13:18:59 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n62sm91932qkd.124.2019.08.28.13.18.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Aug 2019 13:18:58 -0700 (PDT)
Message-ID: <1567023536.5576.19.camel@lca.pw>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
To: Edward Chron <echron@arista.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
  Johannes Weiner <hannes@cmpxchg.org>, David Rientjes
 <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Shakeel Butt <shakeelb@google.com>,  linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Date: Wed, 28 Aug 2019 16:18:56 -0400
In-Reply-To: <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
References: <20190826193638.6638-1-echron@arista.com>
	 <20190827071523.GR7538@dhcp22.suse.cz>
	 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
	 <20190828065955.GB7386@dhcp22.suse.cz>
	 <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-28 at 12:46 -0700, Edward Chron wrote:
> But with the caveat that running a eBPF script that it isn't standard L=
inux
> operating procedure, at this point in time any way will not be well
> received in the data center.

Can't you get your eBPF scripts into the BCC project? As far I can tell, =
the BCC
has been included in several distros already, and then it will become a p=
art of
standard linux toolkits.

>=20
> Our belief is if you really think eBPF is the preferred mechanism
> then move OOM reporting to an eBPF.=C2=A0
> I mentioned this before but I will reiterate this here.

On the other hand, it seems many people are happy with the simple kernel =
OOM
report we have here. Not saying the current situation is perfect. On the =
top of
that, some people are using kdump, and some people have resource monitori=
ng to
warn about potential memory overcommits before OOM kicks in etc.

