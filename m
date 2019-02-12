Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E0BDC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A810221B68
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:06:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A810221B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 084928E0002; Tue, 12 Feb 2019 16:06:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 034C18E0001; Tue, 12 Feb 2019 16:06:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8D608E0002; Tue, 12 Feb 2019 16:06:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A65BC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:06:23 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b1so56565plr.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:06:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NUra/8WSkQjuItV8Gl3OvWiaQ7x2zuhVV6sDSa6EdBM=;
        b=E7KZ2VDrGFHz3wlDmoDvhbIqle/AcVMa/DtB6rWzmrXwKpkl1HzYzGqFpgY37/15E/
         Qp7kJD16z0XzBGris9BNHuK5eRUNjYbHUKYOk/entA7MpSq3CBOFIuRNN/RoOgH2n+rU
         xJpx1EBIw2zr/umo73j6z49QSFpJVy0EYosp7sSicpdu/GdykmCqLpGeEJ7FHuLuq8Fe
         fEJYnIek3g1sfhmNREBuhUFwxnraIJWgzKPi8+BHLO34oQD/oB14lKf85KYPjTN/UucZ
         bDUMSWzMV9lqdEyvUrWJCLEMgihJAt4Ox/YcWVgVvS8Tm9BUg+pBPH5YvD0IWaBe8iZh
         cqfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaP1QDOs8zVDSiEBF+rXjziqpsIkNAVH/6HzSaaYBar69UqFr+i
	zV7ghHJGC9e3PmN1PGp2erfEYaqDWNMMO9O/vVh+MVAbbOOELWejo3t2hKOKajBSIekcUwdGqTN
	ngAcMs+M5F5TNdF7hu3mEDtHp1qz+Me/RfwGUPVKvZEQx4fgUm4YvslxDr3YYozsmHw==
X-Received: by 2002:a17:902:8f91:: with SMTP id z17mr5829460plo.300.1550005583345;
        Tue, 12 Feb 2019 13:06:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaSuQ1hkp7tzjlQTd56swIGjYmzo8Uoe+9atFaSa65OehFrt9teivi0GMB7FfEtSYvBg6/E
X-Received: by 2002:a17:902:8f91:: with SMTP id z17mr5829384plo.300.1550005582472;
        Tue, 12 Feb 2019 13:06:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550005582; cv=none;
        d=google.com; s=arc-20160816;
        b=1GkN6Ria5ZlZCbGDNxozlKZZ+QVvDSgaa7FyhmqFNV/1BEseJEdGfNHtnaFVaOdQcL
         /LQGDwnUyewlUvU5DDPNNjo5W58IFgI7ouTL4vJEtfO0TowzRYJESdL9XFO1gyQ3uebF
         7NO5kbsP2lckmCj4fZ0e/lmxn8ePr5XDtGXIORjCimE/VNMkL2EGK+5qgCWDjbxQ21u+
         0GPArVHiy9Tqh5tljqTtZdlFr+yx6fcN9TmAg25qm+3Mxye0KXjkw5BdVDZ16nzBDL3P
         Gls3plCMMTg6Dz3Mzk+8ZpvF4mS8EQgkszV0Pzc3wr/toXyQyoCj0buReK+wgbSYhA5D
         fogw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=NUra/8WSkQjuItV8Gl3OvWiaQ7x2zuhVV6sDSa6EdBM=;
        b=uaLQRVPTSr9XrzxoU11bczQ8K3CVe3UKKiVf5dxwn8c3KO1c1T35p6Njb8bMWoO7av
         jrfAXdKtMs6/m0HwmGFbPuHJ81ZUYCDmo93mTikGT/OTkj5dgWTrC+plxGtOLZ0w4lXt
         gVEnXECb8QzwWNHya18++YxZ8lndd9muyqBKGKoTIFU1kwZVkbr8PsNn48OMcP4Qln5W
         9A1THJHSU+959RAWF/6S67540NBmkdWzFD33f+ENa2RZEuHV5WWjCwaPZWyBgcpg7jS1
         U/EC4yqV3Gi4zU2zmzEuGt7XjAwdI/D5HgkNFj+mgdLGaOJlmp0CIFnC3eBZyVCwTSxi
         ekOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a9si13049009pff.126.2019.02.12.13.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 13:06:22 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id DA135E25C;
	Tue, 12 Feb 2019 21:06:21 +0000 (UTC)
Date: Tue, 12 Feb 2019 13:06:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Metcalf
 <chris.d.metcalf@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>,
 linux-mm@kvack.org, Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-Id: <20190212130620.c43e486c4f13c811e3d4a513@linux-foundation.org>
In-Reply-To: <20190212112954.GV15609@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20190212101109.GB7584@dhcp22.suse.cz>
	<82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
	<20190212112117.GT15609@dhcp22.suse.cz>
	<20190212112954.GV15609@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 12:29:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 12-02-19 12:21:17, Michal Hocko wrote:
> > On Tue 12-02-19 19:25:46, Tetsuo Handa wrote:
> > > On 2019/02/12 19:11, Michal Hocko wrote:
> > > > This patch is ugly as hell! I do agree that for_each_cpu not working on
> > > > CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
> > > > there is a single cpu? Why don't we simply do
> > > > 
> > > > diff --git a/mm/swap.c b/mm/swap.c
> > > > index aa483719922e..952f24b09070 100644
> > > > --- a/mm/swap.c
> > > > +++ b/mm/swap.c
> > > > @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
> > > >  
> > > >  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
> > > >  
> > > > +#ifdef CONFIG_SMP
> > > >  /*
> > > >   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> > > >   * kworkers being shut down before our page_alloc_cpu_dead callback is
> > > > @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
> > > >  
> > > >  	mutex_unlock(&lock);
> > > >  }
> > > > +#else
> > > > +#define lru_add_drain_all() lru_add_drain()
> > > > +
> > > > +#endif
> > > 
> > > If there is no need to evaluate the "if" conditions, I'm fine with this shortcut.
> > 
> > lru_add_drain does drain only pagevecs which have pages and so we do not
> > really have to duplicate the check. There is also no need to defer the
> > execution to the workqueue for a local cpu. So we are left with only the
> > lock to prevent parallel execution but the preemption disabling acts the
> > same purpose on UP so the approach should be equivalent from the
> > correctness point of view.
> 
> The patch with the full changelog follows:
> 
> 
> >From db104f132bd6e1c02ecbe65e62c12caa7e4e2e2a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 12 Feb 2019 12:25:28 +0100
> Subject: [PATCH] mm: handle lru_add_drain_all for UP properly
> 
> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> introduce new API, without changing anything") did not evaluate the mask
> argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
> 
> Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
> implementation. There is no real need to defer the implementation to the
> workqueue as the draining is going to happen on the local cpu. So alias
> lru_add_drain_all to lru_add_drain which does all the necessary work.
> 
> [1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
>
> ...
>
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  
>  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  
> +#ifdef CONFIG_SMP
>  /*
>   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
>   * kworkers being shut down before our page_alloc_cpu_dead callback is
> @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
>  
>  	mutex_unlock(&lock);
>  }
> +#else
> +#define lru_add_drain_all() lru_add_drain()
> +
> +#endif
>  
>  /**
>   * release_pages - batched put_page()

How can this even link?  Lots of compilation units call
lru_add_drain_all() but the implementation just got removed.

