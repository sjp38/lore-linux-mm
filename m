Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58A64C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B691B2081B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B691B2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15EC78E0003; Thu,  7 Mar 2019 09:44:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E94B8E0002; Thu,  7 Mar 2019 09:44:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF39A8E0003; Thu,  7 Mar 2019 09:44:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA5748E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 09:44:05 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a72so17994653pfj.19
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 06:44:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=liBUfiUTl4iEYlIARPS46wou1PV3VDZbrsj6OjQjd8Q=;
        b=Sfw0bEARhqPRWs8Hl/L4u4409D+xA5pNbMttr/Hox5eEdlyyfCH5m/MtWynnlKv5el
         SJzGnl3ogsLDxzdh345vUoB38YuZGIbATGedc339L7AveX7CpLZFnVuj4gzd7fAk8CZF
         6g5b1xl7qUU7mVxBd70j8Ws7LOjzbj7KLmsw7YTOhK3nvA8fxgl5YZmKJZM6p5v4SYgT
         h1KUuFNH8GixuXVVC+FriCY2yEDCT3EWV1y4ND5/9wXiG0YbI5XptLeOL47a3AjofMPz
         5OFIVp1zAR10virpRdMrTDiFpcxIMeH0AqoA16vYnoGsfpWvEFak291xgUJdgbEQpXD2
         AApA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVBExO2d+Eie+HoLXl3kO2IYPtzoLN1LMm8/3O1h5extiFVF+pv
	J69Wr8pCzmfKkyB+zU5Z9Ug1eG2ROOui3vdKKEflIe13IRRVzVvFD9jJ4HJ19kNpK2iEYLwcDo+
	Vp6nGI9FoSoQBOKKELJUG8muZSXLBkH4EqwU1Av0997gzIk6TqVP36EL6F12OXq1F1Q==
X-Received: by 2002:a62:ae0b:: with SMTP id q11mr13183913pff.199.1551969845343;
        Thu, 07 Mar 2019 06:44:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqx75aHDOxNOdY/AXfe3wkDc7p7HCnhOnsCBzqNp1jWSCIxXfmpt5jmIlHJR/Ah1qfLll/wr
X-Received: by 2002:a62:ae0b:: with SMTP id q11mr13183828pff.199.1551969844055;
        Thu, 07 Mar 2019 06:44:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551969844; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzOhfNcQ5TiaLinfXfDYU/H285GRgAmV08UkKm2UCMFGWrzBRJ2hByJXCkq4iIUMju
         bVvMafUcndhim611PwKWWGSB/m8EZ4XUXZq67N+txqf9i62sjPMOiklqvoNlHEZ8IXZ0
         B8ltoODr2j2O2JtkSJvDZKuwKcoeEJOoe6NURNeB3XEQiqN/C6NRnO+wpGPka8CaMy6F
         MuO6yv6AfHHiyv8y88jzXVXu/BFIhQGDl/v+ib85TMnvjpi0m7PEo7jt/QTJygVFhPC0
         cFmrn65GygK4t3ctN3StoApfczjQpR2Lqr89BdoWGUKtJ06u7LUGwGZ53HhUDxlPazlN
         3FTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=liBUfiUTl4iEYlIARPS46wou1PV3VDZbrsj6OjQjd8Q=;
        b=x8uOAa1Oh6Icyg5pFtwMP05PAhkJpIHrYAOGLSx3WK9pfUYCXBEQWRjWTGiNsolxBP
         jVTQYIgRAxUiEAHbZAxn7yiVouSUcdphSdMi539kC3mPbSPoi+6OEzebpzdZKmaKJ3sh
         MWBQ1JjfNmGbza4vgbp34HRTDvHwGgg+gqa3AMli6Zfeo8ACCFzyaiij+T0yQtz5i2/l
         I9oPVYZ6XAUzNvebqtqP5e04gPF2nAtKxjhhBO0F35uhT5tto+L9vbBh4QrBH5RQXKAV
         nFZDUHiiG5Zn8bAn80IHSMablHLFCyKIIi0bX89KczG80DIlRs9Mp1nMVqlNu0sJ/tJu
         +89g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id j9si3963356pgq.317.2019.03.07.06.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 06:44:03 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R921e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04427;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TMBRUg9_1551969832;
Received: from h07e11201.sqa.eu95(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TMBRUg9_1551969832)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 07 Mar 2019 22:43:59 +0800
Date: Thu, 7 Mar 2019 22:43:52 +0800
From: Aaron Lu <aaron.lu@linux.alibaba.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Yang Shi <shy828301@gmail.com>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-ID: <20190307144329.GA124730@h07e11201.sqa.eu95>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 05:01:50PM -0800, Andrew Morton wrote:
> On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
> > > >
> > > > If we want to allow vfree() to sleep, at least we need to test with
> > > > kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
> > > > vmalloc()/vfree() path). For now, reverting the
> > > > "Context: Either preemptible task context or not-NMI interrupt." change
> > > > will be needed for stable kernels.
> > > 
> > > So, the comment for vfree "May sleep if called *not* from interrupt
> > > context." is wrong?
> > 
> > Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
> > 
> >     We are going to use sleeping lock for freeing vmap.  However some
> >     vfree() users want to free memory from atomic (but not from interrupt)
> >     context.  For this we add vfree_atomic() - deferred variation of vfree()
> >     which can be used in any atomic context (except NMIs).
> > 
> > and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
> > 
> >     - * Context: Any context except NMI.
> >     + * Context: Either preemptible task context or not-NMI interrupt.
> > 
> > change. But I think that we converted kmalloc() to kvmalloc() without checking
> > context of kvfree() callers. Therefore, I think that kvfree() needs to use
> > vfree_atomic() rather than just saying "vfree() might sleep if called not in
> > interrupt context."...
> 
> Whereabouts in the vfree() path can the kernel sleep?

(Sorry for the late reply.)

Adding Andrey Ryabinin, author of commit 52414d3302577bb6
("kvfree(): fix misleading comment"), maybe Andrey remembers
where vfree() can sleep.

In the meantime, does "cond_resched_lock(&vmap_area_lock);" in
__purge_vmap_area_lazy() count as a sleep point?
__purge_vmap_area_lazy() can be called if mutex_trylock on
vmap_purge_lock succeed.

