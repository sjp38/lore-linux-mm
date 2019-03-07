Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8BBC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:24:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E293620643
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:24:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E293620643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 738768E0004; Thu,  7 Mar 2019 10:24:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E95C8E0002; Thu,  7 Mar 2019 10:24:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FED68E0004; Thu,  7 Mar 2019 10:24:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23AC68E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:24:58 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 73so16523226pga.18
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:24:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zHVQK5ryASDeC+o/16Ls2IqWDN787GIxwxfv+hgrnnU=;
        b=pDc0Z5kFELKwah1HiNDHCAPfSQUdLXWUJlv/HziQ4Mw5PpZ9kWZkfTzi/+djaZJB35
         bcqFrSGeNaDvDbQZ0EayoN4KmrJYcxVU3pGDPCFkDCCO2Ze08pjfAiTQMbx9cIupENU3
         FHi/PvSxF+btPGPchPDKZ7DlaUb2w6pYVjOvm3+y1+oiHNGNHVwwSJIPBKr4Z+n04qBK
         7OK14sN8ZGS14NHXV+GK6IiHtG2lKST4NFyr0apimEYU1/ilMba0P1OwaR7HX6IXe+HH
         Xx/B9TwrfV7yxZRPzCM8a/g9QZpvnSezOMM4ZeaNa1TDjDTlV12+KczOPaL4ZW67FAEB
         7LXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXvLhiFjr6J2mpujJsh3yeplujqugNFeo6JWwJGQTtDNRAeGX1d
	V72yx0GXa4ctgMUCxU9UnK76QLuUXHscytex0sc+AFSztgLxTVqvpzMyMNPFNIUKK7co/MQ+ejI
	e4OEKZKmR835eeHoPuEJHkUjf8/DSjeN5Ld98745/Uiwh44seX/w6B8GeUFii+4i8gA==
X-Received: by 2002:a17:902:8f82:: with SMTP id z2mr13509565plo.163.1551972297794;
        Thu, 07 Mar 2019 07:24:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqwuyT1Ao1ztisrfIM7QL79y1sMB3PKfN6O1T4c0SoLUfrHghDf42t/3jAc9z8AB8FaEaDlB
X-Received: by 2002:a17:902:8f82:: with SMTP id z2mr13509510plo.163.1551972296937;
        Thu, 07 Mar 2019 07:24:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551972296; cv=none;
        d=google.com; s=arc-20160816;
        b=wAW84X7Jl4IiwviWFoIEAl3aNNuIjqiyIovIiCYjUeVimmaY+JJM23UqNluX8oTz7f
         Ztc84kQG5R1G2Aj33UXW19GBPADAd87C24Y0gsblXGbTikLLR0IAHwwlMRqBZPJqA2xK
         HRpykdBsx45E2r45SqRu2t8NsbMsFd5ZuWEEZvJ09Nzi2DJIgFDk6EvHF0K6wT8iAE4R
         a5Bm5JrsqtojCovJBwi3c6iUu5UL9rTCKk1yG8m5ZXut2z9ZDhcwLqiyFI8F7HlwtZ/D
         o2vb2RzNpQahTYP36QgF4W4nwlyeiLTwcJbffVfravmLhwRDBSiRtsBuX1WufgN/ZvOM
         21rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zHVQK5ryASDeC+o/16Ls2IqWDN787GIxwxfv+hgrnnU=;
        b=CdBTd+TAIzLrKhbl2DJ+kGpuSBp1tkAsnMPb1u9RPI7E+r8jsNM4D63xEx7cYT54Bj
         vbaH3fHcyf0k4eFqZ+ABwQHH3AkuDQE22QL7WlD1r6dokDhBaSDEvV287MePO1IbQx5F
         Uhj0rKW671Uy/BbSNxsXG4kCpCvnIs01NbgQcE/fSC1YWxe9gkHbglk7+E167mKVWtLG
         cXxLEqeErjvR61WFlewREBjgzT5rLyjoaf3w1p2FQ25hPEOLUa1i3POsOhKO7PAq3rSg
         4yb7JjJa6qPyIL+B9MxffVljARLv0FVjNELNsOxL1lVEweGr+2WAR1aIpz7XwwDeBuwx
         ekxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id h8si4285962pls.365.2019.03.07.07.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:24:56 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R321e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04396;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TMC5uwe_1551972287;
Received: from h07e11201.sqa.eu95(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TMC5uwe_1551972287)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 07 Mar 2019 23:24:54 +0800
Date: Thu, 7 Mar 2019 23:24:47 +0800
From: Aaron Lu <aaron.lu@linux.alibaba.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Yang Shi <shy828301@gmail.com>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-ID: <20190307152446.GA37687@h07e11201.sqa.eu95>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <20190307144329.GA124730@h07e11201.sqa.eu95>
 <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 05:47:13PM +0300, Andrey Ryabinin wrote:
> 
> 
> On 3/7/19 5:43 PM, Aaron Lu wrote:
> > On Tue, Jan 29, 2019 at 05:01:50PM -0800, Andrew Morton wrote:
> >> On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >>
> >>>>>
> >>>>> If we want to allow vfree() to sleep, at least we need to test with
> >>>>> kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
> >>>>> vmalloc()/vfree() path). For now, reverting the
> >>>>> "Context: Either preemptible task context or not-NMI interrupt." change
> >>>>> will be needed for stable kernels.
> >>>>
> >>>> So, the comment for vfree "May sleep if called *not* from interrupt
> >>>> context." is wrong?
> >>>
> >>> Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
> >>>
> >>>     We are going to use sleeping lock for freeing vmap.  However some
> >>>     vfree() users want to free memory from atomic (but not from interrupt)
> >>>     context.  For this we add vfree_atomic() - deferred variation of vfree()
> >>>     which can be used in any atomic context (except NMIs).
> >>>
> >>> and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
> >>>
> >>>     - * Context: Any context except NMI.
> >>>     + * Context: Either preemptible task context or not-NMI interrupt.
> >>>
> >>> change. But I think that we converted kmalloc() to kvmalloc() without checking
> >>> context of kvfree() callers. Therefore, I think that kvfree() needs to use
> >>> vfree_atomic() rather than just saying "vfree() might sleep if called not in
> >>> interrupt context."...
> >>
> >> Whereabouts in the vfree() path can the kernel sleep?
> > 
> > (Sorry for the late reply.)
> > 
> > Adding Andrey Ryabinin, author of commit 52414d3302577bb6
> > ("kvfree(): fix misleading comment"), maybe Andrey remembers
> > where vfree() can sleep.
> > 
> > In the meantime, does "cond_resched_lock(&vmap_area_lock);" in
> > __purge_vmap_area_lazy() count as a sleep point?
> 
> Yes, this is the place (the only one) where vfree() can sleep.

OK, thanks for the quick confirm.

So what about this: use __vfree_deferred() when:
 - in_interrupt(), because we can't use mutex_trylock() as pointed out
   by Tetsuo;
 - in_atomic(), because cond_resched_lock();
 - irqs_disabled(), as smp_call_function_many() will deadlock.

An untested diff to show the idea(not sure if warn is needed):

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e86ba6e74b50..28d200f054b0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1578,7 +1578,7 @@ void vfree_atomic(const void *addr)
 
 static void __vfree(const void *addr)
 {
-	if (unlikely(in_interrupt()))
+	if (unlikely(in_interrupt() || in_atomic() || irqs_disabled()))
 		__vfree_deferred(addr);
 	else
 		__vunmap(addr, 1);
@@ -1606,8 +1606,6 @@ void vfree(const void *addr)
 
 	kmemleak_free(addr);
 
-	might_sleep_if(!in_interrupt());
-
 	if (!addr)
 		return;
 

