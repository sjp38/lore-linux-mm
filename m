Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A91C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3C3C206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:28:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HQ7rJIh3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3C3C206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 633FD8E0003; Mon, 29 Jul 2019 10:28:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E3A88E0002; Mon, 29 Jul 2019 10:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D33E8E0003; Mon, 29 Jul 2019 10:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4668E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:28:00 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y13so67692330iol.6
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:28:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Cgd07V1X1aWq4Nq8OV+7HBCsrLjmlGfJU51VxLF3KME=;
        b=B8P+SCg//qtvbaXvBsjbuWwEBxk4gxY+ss0oWrilPFS96OcxJbdNkehmDKdwQ802EB
         bRwiPbJ0vEapCD94cPRSOu+jd9vhNc5B7MMpChP4pRUKTF/Ammi0eoBeURDIo6Hu98wn
         BDTAMkSzhCa2S40zVf96UErTjyU86NqoE3yX1jqD5C2LwNkuIf38/5X1QRePTizD128D
         BuDgWtwfU7jtXA24PJ3vEMcoIF4i43T0p8D+TTkIZ+tLMi5QQ2uy7GKLa4O8nKHm0xSm
         eXozwz1++uSEaTZ1i36fYJMIV6bmEZUuU2ePWpVAFVjMlm9X7FNolvnd1NduNT5HMkpV
         rAqg==
X-Gm-Message-State: APjAAAUvgVAt3FWs+UbxUwT1fldxS/Ckht5cCbnJSM728P/+dOiHFw7c
	0Kz09k5+PJO1EWUwX9AaHH3asrRFJy+NzRyAlsJX0jwEwJEFhlgsJQadfNei2aDBRmJJf1T+m0b
	1hMWGgtm27lwqnJS1gQqtIiTCuXLiohQp6b2ZkogDEB4zBvl0Wl3OUBSzElXFF0+Y7Q==
X-Received: by 2002:a6b:7602:: with SMTP id g2mr92154097iom.82.1564410479921;
        Mon, 29 Jul 2019 07:27:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxI61iDLMzDlRpixaI7W1nDhr66f4hlvGCp1zK/caL0IvSKAm+qh6V6c0Rqfln78K/GvsGD
X-Received: by 2002:a6b:7602:: with SMTP id g2mr92154042iom.82.1564410479153;
        Mon, 29 Jul 2019 07:27:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410479; cv=none;
        d=google.com; s=arc-20160816;
        b=UrHfbSwqBIrmlkezSrCHdGkr93vKlq8KZ/v2XYXl7VFqKtnlM/OSkXRdTPOVhvDERt
         zmnGH+VLQs+rkUgkyZcgp6CLD+KCzcEBctLEBU4A18PHj+1zdIT7j5RyJqmGAbX3QENk
         l9NRAVzpLKCLI0A1d7egGkEUJS6neGqFl8ErDx8UOwHBu2iC9+7JQlQ6zXm5kngYG19H
         lKS+CRV024/egEQQGSz3IPy2FTTdW9cBImZs1SXIXeXbcVololRojyBY7BMeIpbth/ZW
         zoacOq8Zl65Dk3mQRteGn1tnczUzkZ7STKuwIWdew6LvE+XxwtDLshrSXwQdBdR7fo1R
         hvbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Cgd07V1X1aWq4Nq8OV+7HBCsrLjmlGfJU51VxLF3KME=;
        b=EBCVmFa/Nt9hUmAyMo+gXRZbsFaRpZWQaxp6SoX1USnEA5lKUfhzCYS7M3y1oPQm4m
         P09HZwEM6bYddoLsu7RGkcFXzGBqjhor4I9agtMCKc8j2FcjGz2/jWHPerwEGy/AEAcu
         MZj+dxE5VPADb5gUA37tZuz3+YdDLQim/VlQRmLM5/KUqpEzpXrr+Wo6YfWoFnuiLSiL
         rddsk1MDMgXFbWCfjC07nGRVsd3Uro+xq9wIC//VAxpxwhogeaboStBewmCWIqij5kxb
         iZcDW++NFcOM3xYbZ/F+d42gX92tL/3mW8066ovyhre9t1Z0kIT++ohPICAvc6gQI4Fp
         +b7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=HQ7rJIh3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z127si83146414iof.105.2019.07.29.07.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:27:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=HQ7rJIh3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Cgd07V1X1aWq4Nq8OV+7HBCsrLjmlGfJU51VxLF3KME=; b=HQ7rJIh3bHrwXb5N+hm1m1ta2
	3xN8kgOWRqh7smEYAmFrsJkadsRGpGLLsb9/LHLQ7ywUfoljVN6vzmX+Bzw/03Co2DXcMu0BJRZyE
	qox34odUC6mRHsYT2mmBBcIq58sAF1mXYmXtJm6jQ5YwJ96Fqx8c3dLNZR3ODeLP5LnWEYNF0xod5
	eMq1JAQ/NAdU6bQ20v8FDHnuKmDlCGL1lXRg2R4BEu9qLOWxqHU7b/51x4ducyTPTFmu+731k6hXA
	KwDWNZRXZr96XzMPdBleNmGzRwcOAlMP6kGNFFVV+gpKnCWbcVoyyamjgy+CHXCAQbcBJ8izHsMPN
	R71FeIoDw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6d3-0002u2-Ca; Mon, 29 Jul 2019 14:27:57 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 2974320AFFEAD; Mon, 29 Jul 2019 16:27:56 +0200 (CEST)
Date: Mon, 29 Jul 2019 16:27:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729142756.GF31425@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729085235.GT31381@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:52:35AM +0200, Peter Zijlstra wrote:
> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
> > It was found that a dying mm_struct where the owning task has exited
> > can stay on as active_mm of kernel threads as long as no other user
> > tasks run on those CPUs that use it as active_mm. This prolongs the
> > life time of dying mm holding up memory and other resources like swap
> > space that cannot be freed.
> 
> Sure, but this has been so 'forever', why is it a problem now?
> 
> > Fix that by forcing the kernel threads to use init_mm as the active_mm
> > if the previous active_mm is dying.
> > 
> > The determination of a dying mm is based on the absence of an owning
> > task. The selection of the owning task only happens with the CONFIG_MEMCG
> > option. Without that, there is no simple way to determine the life span
> > of a given mm. So it falls back to the old behavior.
> > 
> > Signed-off-by: Waiman Long <longman@redhat.com>
> > ---
> >  include/linux/mm_types.h | 15 +++++++++++++++
> >  kernel/sched/core.c      | 13 +++++++++++--
> >  mm/init-mm.c             |  4 ++++
> >  3 files changed, 30 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 3a37a89eb7a7..32712e78763c 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -623,6 +623,21 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
> >  	return atomic_read(&mm->tlb_flush_pending) > 1;
> >  }
> >  
> > +#ifdef CONFIG_MEMCG
> > +/*
> > + * A mm is considered dying if there is no owning task.
> > + */
> > +static inline bool mm_dying(struct mm_struct *mm)
> > +{
> > +	return !mm->owner;
> > +}
> > +#else
> > +static inline bool mm_dying(struct mm_struct *mm)
> > +{
> > +	return false;
> > +}
> > +#endif
> > +
> >  struct vm_fault;
> 
> Yuck. So people without memcg will still suffer the terrible 'whatever
> it is this patch fixes'.

Also; why then not key off that owner tracking to free the resources
(and leave the struct mm around) and avoid touching this scheduling
hot-path ?

