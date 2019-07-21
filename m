Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10E60C76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 05:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CD802084C
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 05:31:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="I6f+R3oq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CD802084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 229586B0005; Sun, 21 Jul 2019 01:31:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 200776B0006; Sun, 21 Jul 2019 01:31:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F0998E0001; Sun, 21 Jul 2019 01:31:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D08D06B0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 01:31:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so21444363pfb.7
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 22:31:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=0Le7BqRT6Z0VrMYQMdMrccYxW568r9HQRKBhivo1yJg=;
        b=OR+7hvBX0tqOkKJ/KpS4Ip0fCC1ZJ0h6PPOim0ANFiu/RmW5OwFukMbcvFplhdvOza
         jl60rLWRgH4sWDCW8AqKB8nVJTr6UmAhfoA6aZCJ3pej23XWukImH26BeGSVfrAvEEox
         y93ssAxduGtUu+yMUv8K5VviG0tSwMKSh66K98s4gSj4yaAI9GuOWF9c955BtvVHVaRa
         KKC5seHuKrkGRFKw1+lZ1yGV3mLPhK/nYdWxrk53fHjy9tXImPdvoxXt0RkEuRJTIUTa
         uU1DJrZXRSN52/4mp137OFzXeXw7pP7jhI2ZrnkU5eX6FKB/EBBJfrebPQ+dPEv4xAP2
         W1dQ==
X-Gm-Message-State: APjAAAX+/zGOEtwU5CiA/aezbeytrDf/UQK2DbOet37zkiZDjHtXyf2G
	YBdEWmlg/RYJXk9Oh2jMVvCvsst76FYVge4192S5o+Io6lpgR9p0iEA2S5b+xESrqoj3udsV2Dl
	LN9PtOCmBSD2TJ2Nr3p0CUMqGGLMsEWSGuX/ArtUvtyHjthJ9oyEWK1MpvPBsXxTuOA==
X-Received: by 2002:a17:902:7791:: with SMTP id o17mr68724138pll.27.1563687080375;
        Sat, 20 Jul 2019 22:31:20 -0700 (PDT)
X-Received: by 2002:a17:902:7791:: with SMTP id o17mr68724070pll.27.1563687079514;
        Sat, 20 Jul 2019 22:31:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563687079; cv=none;
        d=google.com; s=arc-20160816;
        b=HqjbQfzY/jzKjPdIJM/ZqXUp8FIK383L5GR8eMt52uTSNoBBx6HcQ/olPhh8rTIXOY
         MdCV32vQhMokupWqdV7hqqoptV+gjXIjHYP4EgWXx4eA8/Y2MCIlzAu1TMx4LGcHWrVE
         /GsdE8c9F5jiWjLkOba5OTddoc6bnmqGqiXtN3YYdirXaygiw00waQEJETJ5zWO1xtu3
         qT9rVhT22c5m3oW/qoTll6FYdzNWBs2QQ80vkKmkzMeVbj61+Om/m68kM305emYBoPAc
         rkwJWVz5fIWA3j108b0AlQCYEYLGJyoW0gll9nJt9WBysw0mlxsJuCmUMsuVR2iLeoFC
         9r/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=0Le7BqRT6Z0VrMYQMdMrccYxW568r9HQRKBhivo1yJg=;
        b=NjgWi1HrPM/uxwTh+N10g+1wNgcHC90XeTVbc8rNwAgfX1GVe7aj0Ok6YVmXmgc4qG
         ybx0IH18Bjgj4IXaa3gnG95O8uXKqXb+WrG5dhUj0ErqHSkTTGz0Oy5GYuyINGM/5HVY
         IZMTQ6OmNtU65b+VBdXLnN0DVuUlcibv//tJaLFUfrXd4WZNm+F2T8hcvJsfUzzq//vu
         tOkXGSOPWhoRqOupcEiUwYGcRxV2NAJPSa8MKyO8WcAKXt+aq7xHU2dJuodYThmMA2Pn
         SnVjmu9q2TlWaD7MMx8RtEQPzyjDr4n2xkVTdGZEt+25nqrTGabkNpoVggEBf3yhlGwS
         1yzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=I6f+R3oq;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37sor43518798pla.2.2019.07.20.22.31.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jul 2019 22:31:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=I6f+R3oq;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=0Le7BqRT6Z0VrMYQMdMrccYxW568r9HQRKBhivo1yJg=;
        b=I6f+R3oqknatK1iJ86QwGrYUdJOvkd9qoPj1qFPvpbX8CZ2XUkdpP/UOZ4yWz/n1c2
         X8WbLycy1TPVvPobwvAkMEz8K/7u1qn6fFx3mAeF3onx8Yxksxk7f9R7QgDLRySrGTVg
         R5gn8KyJiVzpAnt7xK9XSJMjCeTcgw1U2SCs1B4tOPp0X8V5eIHwNG0F9JpY8T7Ki4jz
         Vb4V2DrH42zxoNQU35vboGuRkONu3RuVqanw1W6o80A6E4gxFRYtR20loYVkbRIC0AUu
         NU5vC9vth9zv5iyUmy4AV+PbS6kRJZd76ElnUdD9BUM1OFNUVjjLOec2eUE3o+TZYm6G
         rsDg==
X-Google-Smtp-Source: APXvYqz7cWhPAArR1h2ZbpIlwLg5H+HTAbbJ3obPU9AqRwpJljq/4AhW/XlqOV7mF/jgf+1t7haPtQ==
X-Received: by 2002:a17:902:aa95:: with SMTP id d21mr65141004plr.185.1563687078830;
        Sat, 20 Jul 2019 22:31:18 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id l4sm35574896pff.50.2019.07.20.22.31.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 20 Jul 2019 22:31:18 -0700 (PDT)
Date: Sat, 20 Jul 2019 22:31:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Waiman Long <longman@redhat.com>
cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, 
    Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Shakeel Butt <shakeelb@google.com>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, slab: Move memcg_cache_params structure to
 mm/slab.h
In-Reply-To: <20190718180827.18758-1-longman@redhat.com>
Message-ID: <alpine.DEB.2.21.1907202231030.163893@chino.kir.corp.google.com>
References: <20190718180827.18758-1-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2019, Waiman Long wrote:

> The memcg_cache_params structure is only embedded into the kmem_cache
> of slab and slub allocators as defined in slab_def.h and slub_def.h
> and used internally by mm code. There is no needed to expose it in
> a public header. So move it from include/linux/slab.h to mm/slab.h.
> It is just a refactoring patch with no code change.
> 
> In fact both the slub_def.h and slab_def.h should be moved into the mm
> directory as well, but that will probably cause many merge conflicts.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks Waiman!

