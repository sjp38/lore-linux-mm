Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35143C10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 01:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7CFD2133D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 01:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tnEQvKrW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7CFD2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 843A96B0003; Tue,  9 Apr 2019 21:16:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F2DD6B0005; Tue,  9 Apr 2019 21:16:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E21B6B0006; Tue,  9 Apr 2019 21:16:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 401906B0003
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 21:16:59 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id i188so828607iti.4
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 18:16:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fxvKB3vUz1Lf3105xg8cY/zQjJPWdb/LGlYIzWMDHoo=;
        b=Q19oZ9YC5V2FEJLK3Bz3CzPtJ2gJiJRdJBb18/Gaw35sWVsPFdNRQvn8OA+iIqfkNH
         HstkAQsI+NVLzzTMCVJ0K6pR4H6uM5+Rj1uerwjbmPIc+M9n47JNN+bKeJhTZ9a9oks4
         WzpPyT6Gb59VVeOjZFFVL2p5+TPuwjE/nRI8f05XU4qU3wqrIS3FXUnTExZCY/fSd/iB
         VhOK0dGqm+a91mvr5c5DE3EslF3oULKxq64mavpLmm9a7byScdUrWclldrBdaHcSYVoQ
         HRwAitSR5AGzsOFIQmmuUqlOOtRs0MWbel45gV4IN66l99zDu4NNxRF1KmZ7Vhq1FHUR
         /YQQ==
X-Gm-Message-State: APjAAAUPbUG1w8tb9SbWm2NcpFuraPCVRaoJMtlfMTc/3p5ADTZZ+o9v
	C0Qfdgp6R0bpDaYa/aW4KV2KL8nDv1zb7RJ/Sxkj/QZVSWphBS6MqWNpFb9X2kVD/KfR8wdiyFI
	UpwoO8c/kRZAhWnubtHSmC8mBSJIFrGJxqcmufPm8YTQsYewuBJzgoGImQj89FPdyqA==
X-Received: by 2002:a24:1052:: with SMTP id 79mr1280304ity.158.1554859018964;
        Tue, 09 Apr 2019 18:16:58 -0700 (PDT)
X-Received: by 2002:a24:1052:: with SMTP id 79mr1280255ity.158.1554859018079;
        Tue, 09 Apr 2019 18:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554859018; cv=none;
        d=google.com; s=arc-20160816;
        b=NGLjI+DnaNTATXzI0kmucaAGHc3Woxl63NhrfKkEG1vlMejQMAcIZyJMFAoLVHHxgU
         YEVqWVEyPDtLhMGG0ZDLB+b8X+wWWub27ekDbXK+VWX68sDVlWkZ5uBkOhQBsn7zQwrL
         t2DrWJdjgj7kb4e1izro6XWZVQ0pjfOfBWoeE1slHNk3vfqNNfLwV5/jDRm54NmTIGa7
         Rya9USWwtY6PmgmmKA9WAtWTT0G59mE9hEcU+UKpzhobqxPJkY1r97qizt61W7P/6P+b
         HTqJx5ycOxZzDEl6e15EoCEmOgNywfAhlsAHMzyVdPtfq5GImnVoQg0NTzJ5qbKdPXAa
         ezaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fxvKB3vUz1Lf3105xg8cY/zQjJPWdb/LGlYIzWMDHoo=;
        b=fmZN9vnZbo9B48+hKlgvcvg5YTKflszVFEAkh0W2P+njjxSQEWQCVtNigapeia2Avq
         pLRg6/BFJl2o+xsQfT6iciYLW8B+/J8i2G7wYMQm1pXfKY8rg0otXPzLIUfnojOtLweK
         UgDeye9YEQchWqEUMRJEwzXtponffCIMVLunX7Iv0tmNeZjtNJKM+z71wkdTvcmQ8w/y
         Bs+OB1IA29vH9ZDH0c+wsZGQcMxvbnzO7dodIVJ8KwCOiZjQHN8KKJjnnYMYNidWLSjb
         f+4z+wkJB0KuzxdMbr7n8iGh97nvnYLoYsBcXU+e0SOf1PrGpS1gWOSNFdf4uFCf0T9L
         lwrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tnEQvKrW;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u63sor1240857ita.2.2019.04.09.18.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 18:16:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tnEQvKrW;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fxvKB3vUz1Lf3105xg8cY/zQjJPWdb/LGlYIzWMDHoo=;
        b=tnEQvKrW5hamvF0CAIICDpGB0vtLrwqJzaCIG+F/oo6PLgBwT2+CmiUU2M8KDB199C
         cfTpwjMbByd/zd0IZcWq4SS+MJAEglUIVVS1WK5ZcHqT7nEZ6EtP8SnOm99REw40Wzd5
         EGHSVFZtCgxi8XV7t91xqvr3HSdQyOxmHurYmpzQOsldw7z7iw5HeYbd1kGwsNa655ue
         XfLrU6UOluYHygTt+j1ur3CGdOX9bk8XssuEZPwtZFoogxgAYEh0i+iQrEqxA7Zu3nbW
         wsWaVJESph3vtidAu8TOEHznzLcSOIepaQi7cikYIW2kcN2di+tTc6y+QUeWgLVp05eb
         vbjQ==
X-Google-Smtp-Source: APXvYqwuaYYETNeDo7L70Pf6XV0D2b8XTo7JpPazVVM5zWSLDUmTIeOpAzj6jZIcLQHGhaP+XfBvnaa7YposYioF+BA=
X-Received: by 2002:a05:660c:111:: with SMTP id w17mr1262040itj.62.1554859017876;
 Tue, 09 Apr 2019 18:16:57 -0700 (PDT)
MIME-Version: 1.0
References: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com> <20190409175545.GA13122@cmpxchg.org>
In-Reply-To: <20190409175545.GA13122@cmpxchg.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 10 Apr 2019 09:16:21 +0800
Message-ID: <CALOAHbAz9ZL1vfWOQP7-1YXcko5VGt+-DtCkDikL8gysZy66Bg@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: split pgscan into direct and kswapd for memcg
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 1:55 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Tue, Apr 09, 2019 at 09:13:43PM +0800, Yafang Shao wrote:
> > Now we count PGSCAN_KSWAPD and PGSCAN_DIRECT into one single item
> > 'pgscan', that's not proper.
> >
> > PGSCAN_DIRECT is triggered by the tasks in this memcg, which directly
> > indicates the memory status of this memcg;
>
> PGSCAN_DIRECT occurs independent of cgroups when kswapd is overwhelmed
> or when allocations don't pass __GFP_KSWAPD_RECLAIM. You'll get direct
> reclaim inside memcgs that don't have a limit.

Oh yes.
Plus PGSCAN_DIRECT may also triggered by the tasks in the parent memcg.

'pgscan' here only cares about the memory in this memcg, other than
the tasks in this memcg.
Seems we'd better introduce another counter to reflect the tasks in this memcg.

Thanks
Yafang

