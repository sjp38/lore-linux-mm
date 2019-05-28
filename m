Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45FA9C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 20:32:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0219D20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 20:32:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="jALHoOYb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0219D20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AC726B0286; Tue, 28 May 2019 16:32:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85D136B028E; Tue, 28 May 2019 16:32:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74C826B028F; Tue, 28 May 2019 16:32:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2156B0286
	for <linux-mm@kvack.org>; Tue, 28 May 2019 16:32:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e6so85720pgl.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 13:32:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6BVjplRJjVAtzerMfL/A1WtErQukGLzsV7QIdL5tHLg=;
        b=bVM3TLzh3CJmc6bACWhO2r/66MKyyEzny7AnWI8v+ZqTik65OoXPC9NIUP+SaoqC1j
         5s4x5RkloKd/eozAMBHJitUYH4zCARwG2WDb7GdCc2PIzSNAiJlYxiWVZrz1MEXLDmze
         txu1S07V2/aZ3069voCJGFS5J6ybvXUH0WwU1tpTezi3mhHNLTsYYYeyyA85SSbi14w0
         vrXSqFNCDsWT9zH61Eib0M6FHBJCjhA1rNIJm6lJm7e0kztn8Jss5vBaAWBbkXuWwNV7
         XQiBTgEa104Gv6XuCkc2clYnKSDemJWjP5tbY76wO47KwKb1IlKlsgr6RLPsj8vdfZfy
         B5wA==
X-Gm-Message-State: APjAAAWxw4+pKGeKy9hSqO22HUkImkNKBC+xxUCXsgls3mzxIpkPBaIA
	qP2QIwy5fVMBTOxCQUi0ay/lJ1y+JetfxzzYjwn9copmP14S3iECzhDBUUfgdmb+Ff1TPOUfpWQ
	F9YSzkPEgfYQcnS9RmIc0jhnvamCoHAtldkgDXw2M43z+JvOV+cS+/f7l853c9JdtIQ==
X-Received: by 2002:a63:dc15:: with SMTP id s21mr45121876pgg.215.1559075544760;
        Tue, 28 May 2019 13:32:24 -0700 (PDT)
X-Received: by 2002:a63:dc15:: with SMTP id s21mr45121828pgg.215.1559075543886;
        Tue, 28 May 2019 13:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559075543; cv=none;
        d=google.com; s=arc-20160816;
        b=Dgw3YaxIVkQyQM27EaDOzdqFpPkHRh3nEWpWK/wOgqF2IWvIkbNdYk/Rwiq3jYu1Sn
         9cxEenKQbbfdZp39YkCNCgKpTU1J/QzVVkahhLvPX5HzoHFElpFrFJmE1+nj0z7eo2l+
         z3c3zC0HC01wIU2giOZ7j0SLImno6++c3w3C1E49kGJLL2tWY0VpEKsv0CZEzGKs/b39
         +/lyA9KWGfymFltc/85pB1fioKSC9/7Gv3g+PYy6DsUZBNcNyTQqqXkWTobPUNzW53kq
         KpBITd6Ju04W6xNg/+CJiZB913KDnGvHdl7u0iTycT77sgbZVrmZPv2ODsEVrzwP6AN6
         g6eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6BVjplRJjVAtzerMfL/A1WtErQukGLzsV7QIdL5tHLg=;
        b=uVmpOAyecoLEZJaWcD1XVhKLrMRStMTAi7IMbqHPNsEfcD4JcgiovCfQUU8RjNYqhU
         DfCJbgdDZoD7DPB3nYZ7CuGEg7ohHCYwWgbJ2BkliKiZRMU1HwrlxokQXEYc8+3v7nY9
         1stozcD3qljgdGA5y7d2VJofIx6JcJphaPRVK8wOlLAeUz8Vm5+6ZlCxSLh82PSr15mh
         EyyuD9JFTmpsy5GEjh0xEEqWuAyKc5TgxlhZNEvlkU5KT5KzISgiTAbBUUayz+ISfBA2
         C3j/j6poekPnT43aOVgVil2ekqIsTBbaO3Zs3sFTAkVu9V0/iIBgcDCmaV15YsTyuZiX
         8s4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jALHoOYb;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor16513424pgt.21.2019.05.28.13.32.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 13:32:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jALHoOYb;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6BVjplRJjVAtzerMfL/A1WtErQukGLzsV7QIdL5tHLg=;
        b=jALHoOYbd78sWqXXZgYaR8eLxuPF63IYkarb8Baf2n7TaE6XnnepYOIMqCLibAQqG/
         0ZJcwCe35su/Un1bvTKr+H9yfbCkChIWYtLnHoLbFPQ+U51SOhGPOu4PDiNGWKDyuQHL
         0/Bh3Wz253mmN/utA/8DiIGX5r6qBJPfGgk2oct7Uvpyn5Aq64Mj1G8+uxa7XdNfHW+L
         8fhCvz7JKJm3Xx8NvpGLGFD4eU7BVn/g6ehW/Z+dcsnVXOV+p0CbvsIyL5hTi4cc4/M+
         4pbItZvCXZDDcetGaQGkGh6Bfg4tzcbzzSbFPSqysI8fYYPgfmUXhZy7tlj2NzsFGGpx
         tXyw==
X-Google-Smtp-Source: APXvYqw0vMIiMqx3gefPlogq+TldEzNcR68Fc/ANu9jAbQ2F1nOLyVOiuJNwa6AgdrcS475hYpQKwQ==
X-Received: by 2002:a63:4f07:: with SMTP id d7mr83629540pgb.77.1559075540928;
        Tue, 28 May 2019 13:32:20 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:6316])
        by smtp.gmail.com with ESMTPSA id c15sm15664515pfi.172.2019.05.28.13.32.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 13:32:20 -0700 (PDT)
Date: Tue, 28 May 2019 16:32:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kernel test robot <rong.a.chen@intel.com>, LKP <lkp@01.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>,
	Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>
Subject: Re: [PATCH] mm: memcontrol: don't batch updates of local VM stats
 and events
Message-ID: <20190528203218.GA20452@cmpxchg.org>
References: <20190520063534.GB19312@shao2-debian>
 <20190520215328.GA1186@cmpxchg.org>
 <20190521134646.GE19312@shao2-debian>
 <20190521151647.GB2870@cmpxchg.org>
 <CALvZod5KFJvfBfTZKWiDo_ux_OkLKK-b6sWtnYeFCY2ARiiKwQ@mail.gmail.com>
 <CAHk-=wgaLQjZ8AZj76_cwvk_wLPJjr+Dc=Qvac_vHY2RruuBww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgaLQjZ8AZj76_cwvk_wLPJjr+Dc=Qvac_vHY2RruuBww@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 10:37:15AM -0700, Linus Torvalds wrote:
> On Tue, May 28, 2019 at 9:00 AM Shakeel Butt <shakeelb@google.com> wrote:
> >
> > I was suspecting the following for-loop+atomic-add for the regression.
> 
> If I read the kernel test robot reports correctly, Johannes' fix patch
> does fix the regression (well - mostly. The original reported
> regression was 26%, and with Johannes' fix patch it was 3% - so still
> a slight performance regression, but not nearly as bad).
> 
> > Why the above atomic-add is the culprit?
> 
> I think the problem with that one is that it's cross-cpu statistics,
> so you end up with lots of cacheline bounces on the local counts when
> you have lots of load.

In this case, that's true for both of them. The workload runs at the
root cgroup level, so per definition the local and the recursive
counters at that level are identical and written to at the same
rate. Adding the new counter obviously caused the regression, but
they're contributing equally to the cost, and we could
remove/per-cpuify either of them for the fix.

So why did I unshare the old counter instead of the new one? Well, the
old counter *used* to be unshared for the longest time, and was only
made into a shared one to make recursive aggregation cheaper - before
there was a dedicated recursive counter. But now that we have that
recursive counter, there isn't much reason to keep the local counter
shared and bounce it around on updates.

Essentially, this fix-up is a revert of a983b5ebee57 ("mm: memcontrol:
fix excessive complexity in memory.stat reporting") since the problem
described in that patch is now solved from the other end.

> But yes, the recursive updates still do show a small regression,
> probably because there's still some overhead from the looping up in
> the hierarchy. You still get *those* cacheline bounces, but now they
> are limited to the upper hierarchies that only get updated at batch
> time.

Right, I reduce the *shared* data back to how it was before the patch,
but it still adds a second (per-cpu) counter that needs to get bumped,
and the loop adds a branch as well.

But while I would expect that to show up in a case like will-it-scale,
I'd be surprised if the remaining difference would be noticeable for
real workloads that actually work with the memory they allocate.

