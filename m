Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEB1C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E59E2084E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:21:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E59E2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A56C8E0015; Tue, 12 Feb 2019 06:21:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8550E8E0014; Tue, 12 Feb 2019 06:21:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 743368E0015; Tue, 12 Feb 2019 06:21:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0C88E0014
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:21:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u7so2113547edj.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:21:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=n1jy7aXRGiLD1bR06mvG9WrJvTcyetrPdIeEhtkVZx8=;
        b=GEnymz2CsO51RamGsohatRwb3ebg9Kek2vnzbokZVKJlk07lnJnIzGfLK1UKldiRSy
         4sKImyJ+EMe7hsGdlFw/gYoeGHlWlZ6+1R27bxZirTwTgP5FKHkhMeBufKyxNx9jM2fp
         N5KZIKgbaXvHUR1I/isQ/shI861inhj/tXqzwR/Oeg6WAC5Iy2zdYO7I43f6o06d+T54
         2OugGsATyaIld7B21Y88S/S1bHnlUZ1I2nvgpbDXptnthTk9eg53Cb0VSpUWlgwgK0dz
         qpVc9+VCJ0XFM3qUx7sfkrJk1ZpsPN6Zy8zoeqMMNvj4vmdb76ktLziO3HngmtCdpeoM
         k5NA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYyaIqG+Harl2LWkfbh3xF3vTgeekUIys1bDuWMSf3iFs2oe8cc
	9NxBgSI6iJNxo8UM88Cy39qOe8t3pSgpBBRfMnmKh84/Wrh7ZPROUt1xXc0L2j1BtphZIni5IgY
	TTim/H/GL0bu3zG/NafVlUOlzyZNoWSKpoxrWUGvZk81N6+UthI8KNqXxf1tWw1I=
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr2609265edv.293.1549970481565;
        Tue, 12 Feb 2019 03:21:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZtUzSSBbgmNTb2ZYM+2ghITsyK4KqScc/BPy13rnb/y4NzLlq2hNXNn8MzetZouumEfkp
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr2609209edv.293.1549970480630;
        Tue, 12 Feb 2019 03:21:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549970480; cv=none;
        d=google.com; s=arc-20160816;
        b=RP9PXk10B41s8BhzFhKRKfBl2tYRW0POavMSF6WLQb0lMIqHyjwRPQB6Mh3JUTozMi
         I5kJtRoJgfACeood659+qLlIV6S1ttY3nf3TQMUCK1y8Rzr3pGNhimvMlEgJRnXC+Nxx
         yLnaDm7vo7cJRzkRfHFkwK3D27iz3pimpbWfe/SQkvIdbJutSRwQ4OFrIXmawwTlhVHp
         UIrdW0XuEbGahEeICAQdnnRIlbiSbYBaJGbcMNk06/RL62PVMm7BdrQ0uYAosxfGk+3I
         OhlnSexZ0ZIjwwwwbnZ3MArRFVgVtVb5vBzZ5J64gupwghmosoEnlkqzL9BRJ2uM2AFs
         L50w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=n1jy7aXRGiLD1bR06mvG9WrJvTcyetrPdIeEhtkVZx8=;
        b=hAxeGSLFDmOFXCRw6Ne2Mqvu37n5vdZP99GI+xq/3TwzybL+1bXWHYfkFvn8KB9Xpw
         CoCDXI8Ed0A+vCGy4WZmGPalrJGJ5F+cI00/XqIlkm7g2pkyjYkdrDORxPLHiCk5Mwlx
         MV6iP0WjJ2lwuMdbCODUNN4awCzis0fxcjooiKeVgWVhBwZKNuLOGqegGV0EWH7edYEn
         FaMN9qPkQ7HIn85CAjo6mPVMV/1ZVUaqVJ03nurNC4GhotF5EBOm0yrT4sPkvTUqLMHr
         I0tCeLQCl830VI4jIB6iecxChHR6IS/+fXJ9JS6QRazPv3KaidAWkLiGPjnFzYHVEu+i
         thHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si73102ejl.118.2019.02.12.03.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 03:21:20 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D6D73AFBF;
	Tue, 12 Feb 2019 11:21:18 +0000 (UTC)
Date: Tue, 12 Feb 2019 12:21:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
	Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-ID: <20190212112117.GT15609@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190212101109.GB7584@dhcp22.suse.cz>
 <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 19:25:46, Tetsuo Handa wrote:
> On 2019/02/12 19:11, Michal Hocko wrote:
> > This patch is ugly as hell! I do agree that for_each_cpu not working on
> > CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
> > there is a single cpu? Why don't we simply do
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index aa483719922e..952f24b09070 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
> >  
> >  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
> >  
> > +#ifdef CONFIG_SMP
> >  /*
> >   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> >   * kworkers being shut down before our page_alloc_cpu_dead callback is
> > @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
> >  
> >  	mutex_unlock(&lock);
> >  }
> > +#else
> > +#define lru_add_drain_all() lru_add_drain()
> > +
> > +#endif
> 
> If there is no need to evaluate the "if" conditions, I'm fine with this shortcut.

lru_add_drain does drain only pagevecs which have pages and so we do not
really have to duplicate the check. There is also no need to defer the
execution to the workqueue for a local cpu. So we are left with only the
lock to prevent parallel execution but the preemption disabling acts the
same purpose on UP so the approach should be equivalent from the
correctness point of view.
-- 
Michal Hocko
SUSE Labs

