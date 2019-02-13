Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAE84C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E012222AE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:43:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E012222AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BB338E0002; Wed, 13 Feb 2019 07:43:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B3F8E0001; Wed, 13 Feb 2019 07:43:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 281D18E0002; Wed, 13 Feb 2019 07:43:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4E0D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:43:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id p52so937351eda.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:43:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FN827bFLtYpfTb1JOMoC3e9mlr65sMeqI32C/KPwydk=;
        b=JCprqA06Zc61p1dK/Odd9SrwOBUmavbqyVnf61Wao42iERXhAVJr15tm8XvdWGIM0+
         zCdJ7V1Q/g0xNtSKIC/bh/0OXznu8fIVqC7EzRpARW17yAjbxhKm87yPKoEl5BBN2QAA
         v1R0rwsO6yhqhli+zh9ehMRkluPf6vfCI0CBFpC5wBuUmepJJqQ39jFtyMVRJzF3ZIxc
         6EP/5GXTVvuQdcqq9t91ezbIpuR/2yxs1KtzbUnrTDpU+qCVrW7PBbAhXjyJqZIfZqzD
         4JHv08td08UToefs8+BEJ+Q4WWb7tVgpvmHtCNN3M6MTiaDtvOaIPlBMcUOOY25oXb3f
         ilJw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaIsZtOx3igv7nv6B0lYZmdyrAHcLF1ULpujEdIjdPhIlpssOTi
	bz4c0RekowE/CvYDIXC459Lta8Ffi9rFx/NH/fU5bBxT5gp+vWn9wFO9Q/KL1Y6HK9UYhVH+s4d
	BalMJz1x+7W48oLosgJnlXph04Ofk8JeYN4+YxA7sIarVUAxV3Pp1fcCRCX4o63Q=
X-Received: by 2002:aa7:c5d0:: with SMTP id h16mr239729eds.107.1550061820352;
        Wed, 13 Feb 2019 04:43:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDdRPGQsDJzozFSUIkIVymqF4NHtybIA3m6q6lG12q4FvskoKdmF1Ab9ikLAIE8YmKBVEA
X-Received: by 2002:aa7:c5d0:: with SMTP id h16mr239677eds.107.1550061819451;
        Wed, 13 Feb 2019 04:43:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550061819; cv=none;
        d=google.com; s=arc-20160816;
        b=znwEkj98EVWBsMS/wJxYn9g9QBGX123Qh6atfD52D7x0lZUu2II1sX8MQQz7sri3ae
         ws+OmMX6wvCoxaHr25Ghuamt7kQNnVmJTDA3nE06dLMJqlS8D600T3xEH++TX3RwsXFS
         NlKs71OF5zk0jWFXnGhgOJRiQzwfsuIJrbxp5D9lv/NmyviAU0Ry9XtyIRx0hm2HcqWi
         vdJhetH07sONaK4O/HJ8u6jvwVpuFbiDzeyVHVEJQjPbQpVKl9vHJDGFa8GL/hRFNZNW
         UJZ33g2wRsGQ31WKScfXUVHthe3pNBs3popzSEXuHVKwN4Jekhn5kBcy2iBodQC2eYQ3
         2Ihw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FN827bFLtYpfTb1JOMoC3e9mlr65sMeqI32C/KPwydk=;
        b=nLxKkqHljWQgfTBam6jD0h6FYDjBtBAnA26g82fUoTk7y7F+20nYw4bmadPXqyjPgZ
         IofFw0IGA1SziV3dKha4v3cZbAUhS9W1K2SgIfp6izyZQpy8jMXU/qXrJ81T5+YC/OaB
         8yvYwMMG0hP6rDDcGHXrsdrEGbhIBD+9nF/4e3yzPBAQMEFHUY0JB1f/KpiwQF+VK9ng
         Lq9HzyCDYxnOrVu7LbCLAUllGfVWceeyWH1PIFnDdtX2NM+3ZI3p+9CkkjBs1hSL0FXO
         bXMZm4iMpIczLqOv/kxefH0NtWgcVXu/ybXYUdZz+EZOoEuVIm2n58oIg+jGbMlOdpH2
         XKnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h22-v6si5462899ejp.326.2019.02.13.04.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:43:39 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AE2FBAEC8;
	Wed, 13 Feb 2019 12:43:36 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:43:34 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
	Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-ID: <20190213124334.GH4525@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190212101109.GB7584@dhcp22.suse.cz>
 <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
 <20190212112117.GT15609@dhcp22.suse.cz>
 <20190212112954.GV15609@dhcp22.suse.cz>
 <20190212130620.c43e486c4f13c811e3d4a513@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212130620.c43e486c4f13c811e3d4a513@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 13:06:20, Andrew Morton wrote:
> On Tue, 12 Feb 2019 12:29:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 12-02-19 12:21:17, Michal Hocko wrote:
> > > On Tue 12-02-19 19:25:46, Tetsuo Handa wrote:
> > > > On 2019/02/12 19:11, Michal Hocko wrote:
> > > > > This patch is ugly as hell! I do agree that for_each_cpu not working on
> > > > > CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
> > > > > there is a single cpu? Why don't we simply do
> > > > > 
> > > > > diff --git a/mm/swap.c b/mm/swap.c
> > > > > index aa483719922e..952f24b09070 100644
> > > > > --- a/mm/swap.c
> > > > > +++ b/mm/swap.c
> > > > > @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
> > > > >  
> > > > >  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
> > > > >  
> > > > > +#ifdef CONFIG_SMP
> > > > >  /*
> > > > >   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> > > > >   * kworkers being shut down before our page_alloc_cpu_dead callback is
> > > > > @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
> > > > >  
> > > > >  	mutex_unlock(&lock);
> > > > >  }
> > > > > +#else
> > > > > +#define lru_add_drain_all() lru_add_drain()
> > > > > +
> > > > > +#endif
> > > > 
> > > > If there is no need to evaluate the "if" conditions, I'm fine with this shortcut.
> > > 
> > > lru_add_drain does drain only pagevecs which have pages and so we do not
> > > really have to duplicate the check. There is also no need to defer the
> > > execution to the workqueue for a local cpu. So we are left with only the
> > > lock to prevent parallel execution but the preemption disabling acts the
> > > same purpose on UP so the approach should be equivalent from the
> > > correctness point of view.
> > 
> > The patch with the full changelog follows:
> > 
> > 
> > >From db104f132bd6e1c02ecbe65e62c12caa7e4e2e2a Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 12 Feb 2019 12:25:28 +0100
> > Subject: [PATCH] mm: handle lru_add_drain_all for UP properly
> > 
> > Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> > introduce new API, without changing anything") did not evaluate the mask
> > argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> > hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> > ("workqueue: Try to catch flush_work() without INIT_WORK().")
> > by unconditionally calling flush_work() [1].
> > 
> > Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
> > implementation. There is no real need to defer the implementation to the
> > workqueue as the draining is going to happen on the local cpu. So alias
> > lru_add_drain_all to lru_add_drain which does all the necessary work.
> > 
> > [1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
> >
> > ...
> >
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
> >  
> >  /**
> >   * release_pages - batched put_page()
> 
> How can this even link?  Lots of compilation units call
> lru_add_drain_all() but the implementation just got removed.

Yeah, my bad. Should have compile tested...


From a13b4420f064abc9fe86dbb33f2fe3b508c9fac7 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Tue, 12 Feb 2019 12:25:28 +0100
Subject: [PATCH] mm: handle lru_add_drain_all for UP properly

Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
introduce new API, without changing anything") did not evaluate the mask
argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
("workqueue: Try to catch flush_work() without INIT_WORK().")
by unconditionally calling flush_work() [1].

Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
implementation. There is no real need to defer the implementation to the
workqueue as the draining is going to happen on the local cpu. So alias
lru_add_drain_all to lru_add_drain which does all the necessary work.

[1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
Reported-by: Guenter Roeck <linux@roeck-us.net>
Debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/swap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1be60e..12711434a1b9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+#ifdef CONFIG_SMP
 /*
  * Doesn't need any cpu hotplug locking because we do rely on per-cpu
  * kworkers being shut down before our page_alloc_cpu_dead callback is
@@ -702,6 +703,12 @@ void lru_add_drain_all(void)
 
 	mutex_unlock(&lock);
 }
+#else
+void lru_add_drain_all(void)
+{
+	lru_add_drain();
+}
+#endif
 
 /**
  * release_pages - batched put_page()
-- 
2.20.1

-- 
Michal Hocko
SUSE Labs

