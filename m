Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 751D6C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:29:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D26D2080F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:29:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D26D2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBE7D8E0015; Tue, 12 Feb 2019 06:29:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6C4B8E0014; Tue, 12 Feb 2019 06:29:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5D068E0015; Tue, 12 Feb 2019 06:29:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA4B8E0014
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:29:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so2162044edb.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:29:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CRWja/HqdPzlpv2X1CYoIQBTHL9d8k28RXgGJ6allYU=;
        b=GTa8cnt9uM4PopzMaTX5zmwH+Cd+QwFar30LxFC6mhBndmYnYGgSS8MjDefUMjJw4+
         h7p6CjDQEZ7lbSWJglof1mUrm/trkb0iL2Xh4z/mJABpjrxfnfNnqef+xaDloBzv86Db
         9vkuusqlFijbUtiol9wIU2D/j4F3umpcxuteL7XuAeVoLhYHannw53fIJ2GV9cN+T9UE
         loPt9zA+XcUgfKenyC0wmVwQxQ1EMZvag12J34GDlavvixHohElAgWgdgcyTnTFJrQNK
         BU40aatDiyTNT33eJ7K4/mT3geSvWcYzbu0kamYKX/LUyg9nVlFeQIlscXyG1lN8jsMR
         kL8w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuY9vMMgLU/b7DYUGB5+UGGtjgUS2bnfsG/nsJaBzfJ30nP209yF
	+DpqJhhip/TVlMZOJ0wbsy9ICj/S3NfuOI3bS+ZnekoFRv8NhFllFBdtHjdFPs+BzBGaGGySmz8
	2n+kzdIMYIHwX/ybK7+DTzeNoZQg/3lUKtcRHWn8XPQswb8xeUiSdfwdPziR0s0Y=
X-Received: by 2002:a50:b1db:: with SMTP id n27mr2698887edd.65.1549970996925;
        Tue, 12 Feb 2019 03:29:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZtml3omhjmUbtd4zFvVR4ikGF/FTfGQXboASb/ykfDvE9wTctAS7B1OKkgu2dOg8VE3XYk
X-Received: by 2002:a50:b1db:: with SMTP id n27mr2698838edd.65.1549970996080;
        Tue, 12 Feb 2019 03:29:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549970996; cv=none;
        d=google.com; s=arc-20160816;
        b=EyOD+pjhgQYGVXBDX2Oz48us0GMZ5VDvUXRjMPgC57IqwGwlK//RVEVfQ4eVkXdPKk
         Pmewtm9YigqO/JUGs75fL5Fm00ONUV4xsE1rD/Ltio/zDwhbGZo7hX5MM/ag3tWoVHcy
         /rlkawM5LMeyvCW4EVocuA9uKdyHWK061bei55Dy5XNFEx/kGwEZIXYiqZlr+EWv87JC
         cmam8WBsZHtyFFxOZkx3pR6dLspv+2FSnFk1qZYCwpOSJch/FZolVl3FjysZef8Gf9aX
         4dBBDo1add23mk0WMkp2MgdQVhUo/v9PdE1fMQRuE6MDVQuNJJNH84m1kjHcxqcOr99D
         OUMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CRWja/HqdPzlpv2X1CYoIQBTHL9d8k28RXgGJ6allYU=;
        b=TeHadTv1j1eDKgMWOCXBfwl9ECJMwzWj/ITVFz2/6HPy7NCfYaXrJMupytaWtqAX2b
         Itk48VpKVeAF9lNBcBaQoks01KfHgA1F3YsCgMowGh4IXKQF9kDu58rOFemCKyE9AAmk
         NGIPrTG5WYZjwKbWUvloaRJJAtjaY5mV0QvKqzl0Q3WpmWNBcsQZhsXCsWTfkVQJrPWG
         KaPK1FP+Wegu1UfnUA6XgmNLLK4uBPZU35kjG+TIz2fQd6ys1QxkC7bI9gup9EU6D2sV
         H9aonEse53NG2mFoQ0xruuLZTgigCM/GhV1pf3EYu5JOI/64JPqVw2CynzlJOTWViNyW
         QkIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17si2601645ejj.243.2019.02.12.03.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 03:29:56 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51ED6AFC8;
	Tue, 12 Feb 2019 11:29:55 +0000 (UTC)
Date: Tue, 12 Feb 2019 12:29:54 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
	Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-ID: <20190212112954.GV15609@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190212101109.GB7584@dhcp22.suse.cz>
 <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
 <20190212112117.GT15609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212112117.GT15609@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 12:21:17, Michal Hocko wrote:
> On Tue 12-02-19 19:25:46, Tetsuo Handa wrote:
> > On 2019/02/12 19:11, Michal Hocko wrote:
> > > This patch is ugly as hell! I do agree that for_each_cpu not working on
> > > CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
> > > there is a single cpu? Why don't we simply do
> > > 
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > index aa483719922e..952f24b09070 100644
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
> > >  
> > >  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
> > >  
> > > +#ifdef CONFIG_SMP
> > >  /*
> > >   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> > >   * kworkers being shut down before our page_alloc_cpu_dead callback is
> > > @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
> > >  
> > >  	mutex_unlock(&lock);
> > >  }
> > > +#else
> > > +#define lru_add_drain_all() lru_add_drain()
> > > +
> > > +#endif
> > 
> > If there is no need to evaluate the "if" conditions, I'm fine with this shortcut.
> 
> lru_add_drain does drain only pagevecs which have pages and so we do not
> really have to duplicate the check. There is also no need to defer the
> execution to the workqueue for a local cpu. So we are left with only the
> lock to prevent parallel execution but the preemption disabling acts the
> same purpose on UP so the approach should be equivalent from the
> correctness point of view.

The patch with the full changelog follows:


From db104f132bd6e1c02ecbe65e62c12caa7e4e2e2a Mon Sep 17 00:00:00 2001
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
 mm/swap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1be60e..88a6021fce11 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+#ifdef CONFIG_SMP
 /*
  * Doesn't need any cpu hotplug locking because we do rely on per-cpu
  * kworkers being shut down before our page_alloc_cpu_dead callback is
@@ -702,6 +703,10 @@ void lru_add_drain_all(void)
 
 	mutex_unlock(&lock);
 }
+#else
+#define lru_add_drain_all() lru_add_drain()
+
+#endif
 
 /**
  * release_pages - batched put_page()
-- 
2.20.1
-- 
Michal Hocko
SUSE Labs

