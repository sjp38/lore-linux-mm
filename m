Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A801BC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7260521721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:16:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7260521721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 111AD6B0008; Mon,  1 Jul 2019 10:16:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C1B08E0005; Mon,  1 Jul 2019 10:16:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC0D8E0002; Mon,  1 Jul 2019 10:16:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id A0B176B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 10:16:50 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id b12so16815983ede.23
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 07:16:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SVUHtuyg9L939gT4Tog9a5et+c/XYs6Iw5zQZ4Cdvvs=;
        b=kjSPX3s87aIPjY5gaaTiEECWJ35JjM6w5ljCTBygY2f/l2ATb3PlzHglUlpZw+b7xV
         uQAW6g7WD7d0+0zE0eyCnvTsunev0OfzP7Dn6EId1t/GfQ8Nel9KkPiVT1pcwc3VMaiD
         ljoQB8GxsLzG+A900zMZXq9i3dJwHxpOenNGazHJYEX0zZs1mwkg30fK8zXvcEAmObc+
         9v/AGeXEzpVj0ysn6YcqzReTPdilTvJOiisClRXsQ/rz9EVUD/P3LByj7cGDrzPl12ZO
         49X5M3AT+14oj6MrsEB54XoEXSRbQAuT63wbF/XeylnDxGjmcJ3cwC9hmSYEtBfQoL9v
         8MmA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUp0ePp62Sr5OoVvnyknXdLV7+0PWMMLoUk0xVZx8w74l52/xOu
	yd82GwNs6FedkONWHsRH4MBhoV9ycuqMvg17wbnnOaHWtv8RcGc9EyZL7lY7fIfl77HkAZjEMTX
	uLsjBUYsTLzk13zW9UVI175OMPi94jgWWV6iRkMMMz2swoBVSoqD/XcCBxon337Y=
X-Received: by 2002:a17:906:944f:: with SMTP id z15mr23493917ejx.137.1561990610213;
        Mon, 01 Jul 2019 07:16:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE1YYB0KHuKa9n8VNfAKybBOLkID9Nd8PrEGqObQrclRHx9GcvAyF6kKyLp0xQftNMUYGG
X-Received: by 2002:a17:906:944f:: with SMTP id z15mr23493837ejx.137.1561990609299;
        Mon, 01 Jul 2019 07:16:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561990609; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjCA9nOGKfttgkO65mYs2/eQCczG3pbFDsk7cdERyLqjkZiZ/ZzZGFMvY0n97fwX+w
         rxtFT4fCjFLMSuAox9Nfy/tVK1RrcK27Pqa+jy14xsIhXWdRtBItRqLM5/C5jjuMeJQE
         meoTSM/iFBVQ/S+NdafV2wfeakTZnx/KYi9h9FPSw+L4/lazE9qZG+hhZLa3dBhegFm8
         EiDU8QuiuhgbnLyDhlg/ZOj/xfLRT1ggWYKmxNnfJjOpvkU/m/5FKPJ1afm6rxDwMJW2
         hansAMmQ7wpA0/u7BYoxU4OvNarAjgFMJlvbR81FkKy4D7ojxbKy5KelXAkjhzu65eyL
         RfEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SVUHtuyg9L939gT4Tog9a5et+c/XYs6Iw5zQZ4Cdvvs=;
        b=HFXGmMZDP+dETHicugKf6TN6bYh/I9Qcl+GVr0YxV5zaiiGk3VvkF9xdalDGi2zAmy
         loLZsh6EVpBRx7WULXCsA0osOI7uFkN5NXViy2p9QWKEXckTAbYZWdeYIayVUdSWzTpx
         9yMQph9R3aK0YglH+vORhFE4OItH+RWg3nVVkC+J2FK0C7RDpoWozmNUIiWo2vAlZ+Hu
         rrFjTdMnsE4ED6htfMF48vQs4ATboBO2c4y98l8wYyzp7UN5FVs0JtIAbGT1AaiOKxXw
         qjkhaT6hq3dVCvWNjnRr7uXcOpQnf4ITH1BNpYAn9zGaXJuf7d1THPSxNL4AHfc/e5bj
         7wgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u19si9087990edm.1.2019.07.01.07.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 07:16:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9FBA4B031;
	Mon,  1 Jul 2019 14:16:48 +0000 (UTC)
Date: Mon, 1 Jul 2019 16:16:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190701141647.GB6376@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
 <20190701140434.GA6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701140434.GA6376@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 16:04:34, Michal Hocko wrote:
> On Mon 01-07-19 22:56:12, Tetsuo Handa wrote:
> > On 2019/07/01 22:48, Michal Hocko wrote:
> > > On Mon 01-07-19 22:38:58, Tetsuo Handa wrote:
> > >> On 2019/07/01 22:17, Michal Hocko wrote:
> > >>> On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
> > >>>> But I realized that this patch was too optimistic. We need to wait for mm-less
> > >>>> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.
> > >>>
> > >>> If the process is an oom victim then _all_ threads are so as well
> > >>> because that is the address space property. And we already do check that
> > >>> before reaching oom_badness IIRC. So what is the actual problem you are
> > >>> trying to solve here?
> > >>
> > >> I'm talking about behavioral change after tsk became an OOM victim.
> > >>
> > >> If tsk->signal->oom_mm != NULL, we have to wait for MMF_OOM_SKIP even if
> > >> tsk->mm == NULL. Otherwise, the OOM killer selects next OOM victim as soon as
> > >> oom_unkillable_task() returned true because has_intersects_mems_allowed() returned
> > >> false because mempolicy_nodemask_intersects() returned false because all thread's
> > >> mm became NULL (despite tsk->signal->oom_mm != NULL).
> > > 
> > > OK, I finally got your point. It was not clear that you are referring to
> > > the code _after_ the patch you are proposing. You are indeed right that
> > > this would have a side effect that an additional victim could be
> > > selected even though the current process hasn't terminated yet. Sigh,
> > > another example how the whole thing is subtle so I retract my Ack and
> > > request a real life example of where this matters before we think about
> > > a proper fix and make the code even more complex.
> > > 
> > 
> > Instead of checking for mm != NULL, can we move mpol_put_task_policy() from
> > do_exit() to __put_task_struct() ? That change will (if it is safe to do)
> > prevent exited threads from setting mempolicy = NULL (and confusing
> > mempolicy_nodemask_intersects() due to mempolicy == NULL).
> 
> I am sorry but I would have to study it much more and I am not convinced
> the time spent on it would be well spent.

Thinking about it some more it seems that we can go with your original
fix if we also reorder oom_evaluate_task
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f719b64741d6..e5feb0f72e3b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -318,9 +318,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		goto next;
-
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
@@ -333,6 +330,9 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto abort;
 	}
 
+	if (oom_unkillable_task(task, NULL, oc->nodemask))
+		goto next;
+
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.

I do not see any strong reason to keep the current ordering. OOM victim
check is trivial so it shouldn't add a visible overhead for few
unkillable tasks that we might encounter.
-- 
Michal Hocko
SUSE Labs

