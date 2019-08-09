Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBC8AC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6865420B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:31:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="NblyOw93"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6865420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7866B02A2; Fri,  9 Aug 2019 13:31:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B98296B02B9; Fri,  9 Aug 2019 13:31:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A894E6B02BB; Fri,  9 Aug 2019 13:31:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7035F6B02A2
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 13:31:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so61838989pfb.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 10:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=o4KyUArqXmkClyMndBwARjbgAguNJaXFLfZH+78C3Fk=;
        b=OvcJ8C27hcZwSJRxndTxpAS3skadeqBT09GkyVNB0cBB0a82HVO66Uzk2qg0B5uMll
         PjM/M3ipzNQ6RV4M0Qq648H90p0FJmijYf0je8d53Tzde04j6jOxlf7UwaWcBQjjAUT5
         /UdLlqKXJYqIvkVJqofdwv9Zfe0SGn+4Al+THGSb8Sl7jOILz7t1DRMJF1aRM54/suh+
         OBEI66W6fo7SlE7jIX51gjwl/RX680dy1c4oSFSv7D0U4k7v/HIaNjrigJjyl+MA/+8Y
         TNgjshkgGt7dPGxW83a4k5G5EKlllYeYzAM56FL6R8alsNsw6UDJ7QtWgo5XnvlA2EYh
         tB/A==
X-Gm-Message-State: APjAAAUCVyLtZIH75D4NRR76Q3gXXyjSH9vojEyr6YDwlP8ympH2fURm
	d0rQDEMpb16n0jz0D2AazGqBVGkbKiNXN7cMDEARLK3XRvNF54auk+6eXoCRstOswpdBRNfvo9o
	9J2L9314gn0BeK6+9rh7tVNUK3x0CRwk8/zPZcf+aqPqO2HXifWEjX3hptAfMxfTx4A==
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr10695216pje.9.1565371874927;
        Fri, 09 Aug 2019 10:31:14 -0700 (PDT)
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr10695148pje.9.1565371873920;
        Fri, 09 Aug 2019 10:31:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565371873; cv=none;
        d=google.com; s=arc-20160816;
        b=SYnIxmgPSCHSarxI3jOuF1DGzhGtbe3Q5vH28QHU8Hoyk2LHyCeYvB6E0GlGD4C1ae
         96MG0RZF2ot1EDCVMRjUAMaYngzgZFGBJbhyS1naeSrgRYjKfmcLljc1LC7pvUX71iri
         8D7oVftFVRJQ2/FaxG2rAqBQ5aaoRStyk28dnOw6ovoccuK7q/orrkSVTgJyLXLCg02+
         XSPX4ym+LANcXGhEbt8uUJjV8BHYbmuRAAhC3hXU1k266K+7yg0f/HNQSLOHVIqzBWKd
         XtTGRklY7V8n/2SrlDH3k2/2LKgUOrEA1WCDxcvKJCuytp2yFnLkbgzNEJbkrToeBEIg
         IVcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=o4KyUArqXmkClyMndBwARjbgAguNJaXFLfZH+78C3Fk=;
        b=reZhgXwQH1hg6b97KTyDP33E8i11lUsZ7eyDPqxAgPb2FNYcJ2Vsmihdtov8l9XupG
         46egcOZSfJJ0ke3xOxoIZHrOIiV8TIh71PPX/2yuUl7qj+n/2J88WaaDXCxrH4TF2uZN
         D1ocNnL7nq4dVmOehVT6AkhQt+VUs7cLMJuU75SzPUEiUP9IJdqfByCpkmTZAblVpWO3
         PreQDLb8MudnYd86I2DpftQynBoCdGtbDOee072LdeSvwRzFpGFTdxfAhLF0OqykgB0v
         ulB/be6Ra0tDBHCrk0f40TiSkBaO+j0FgEpm9VRVrko9YFbu7M2ZmuwkD4rpDLyBUSIq
         K9wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NblyOw93;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13sor69631203pgr.87.2019.08.09.10.31.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 10:31:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NblyOw93;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=o4KyUArqXmkClyMndBwARjbgAguNJaXFLfZH+78C3Fk=;
        b=NblyOw93JRPVTmFr5sfAXmZSjW11mR/3bmjjggtv8t6I2F/6NpZYR70YToAJzZdftd
         cgbG4waoTnjLtthk6byMT+yut72nDrtMyvnwR5IW+w2wdO4PUpTS2dysfV15KfjtWZuY
         oj46fy0OqniYuAet1QfkFHfjXziev78OEQBTgVfg2MKCBwyV81neNmVrZXlAtyLkimcs
         S1k5R3v97gJVKAR6xbyxwCIiI4rhYTKeELLzorRMW+umEB69RnbMcux4CZYvDqsP73Pv
         o706rZCWSzeChY54iZjz8L7SNKpNmAHsAyhtQ75PoEZEX1haIhLCDpk6dITnX4edQ3gg
         Cb+g==
X-Google-Smtp-Source: APXvYqzMr7pLWX9oUN+nN/IL/jhIcg+L8Yr6aSg8RTDdYi5us3s5rTWlZZfhmbsFg3tPpjihJVTQlw==
X-Received: by 2002:a63:3d4f:: with SMTP id k76mr18907892pga.345.1565371870824;
        Fri, 09 Aug 2019 10:31:10 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::ad32])
        by smtp.gmail.com with ESMTPSA id o95sm5483952pjb.4.2019.08.09.10.31.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 10:31:10 -0700 (PDT)
Date: Fri, 9 Aug 2019 13:31:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190809173108.GA21089@cmpxchg.org>
References: <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <e535fb6a-8af4-3844-34ac-3294eef26ca6@suse.cz>
 <20190808172725.GA16900@cmpxchg.org>
 <6e7f0cd2-8b13-7534-1c0e-f3569f8b4c05@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e7f0cd2-8b13-7534-1c0e-f3569f8b4c05@suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 04:56:28PM +0200, Vlastimil Babka wrote:
> On 8/8/19 7:27 PM, Johannes Weiner wrote:
> > On Thu, Aug 08, 2019 at 04:47:18PM +0200, Vlastimil Babka wrote:
> >> On 8/7/19 10:51 PM, Johannes Weiner wrote:
> >>> From 9efda85451062dea4ea287a886e515efefeb1545 Mon Sep 17 00:00:00 2001
> >>> From: Johannes Weiner <hannes@cmpxchg.org>
> >>> Date: Mon, 5 Aug 2019 13:15:16 -0400
> >>> Subject: [PATCH] psi: trigger the OOM killer on severe thrashing
> >>
> >> Thanks a lot, perhaps finally we are going to eat the elephant ;)
> >>
> >> I've tested this by booting with mem=8G and activating browser tabs as
> >> long as I could. Then initially the system started thrashing and didn't
> >> recover for minutes. Then I realized sysrq+f is disabled... Fixed that
> >> up after next reboot, tried lower thresholds, also started monitoring
> >> /proc/pressure/memory, and found out that after minutes of not being
> >> able to move the cursor, both avg10 and avg60 shows only around 15 for
> >> both some and full. Lowered thrashing_oom_level to 10 and (with
> >> thrashing_oom_period of 5) the thrashing OOM finally started kicking,
> >> and the system recovered by itself in reasonable time.
> > 
> > It sounds like there is a missing annotation. The time has to be going
> > somewhere, after all. One *known* missing vector I fixed recently is
> > stalls in submit_bio() itself when refaulting, but it's not merged
> > yet. Attaching the patch below, can you please test it?
> 
> It made a difference, but not enough, it seems. Before the patch I could
> observe "io:full avg10" around 75% and "memory:full avg10" around 20%,
> after the patch, "memory:full avg10" went to around 45%, while io stayed
> the same (BTW should the refaults be discounted from the io counters, so
> that the sum is still <=100%?)
>
> As a result I could change the knobs to recover successfully with
> thrashing detected for 10s of 40% memory pressure.
> 
> Perhaps being low on memory we can't detect refaults so well due to
> limited number of shadow entries, or there was genuine non-refault I/O
> in the mix. The detection would then probably have to look at both I/O
> and memory?

Thanks for testing it. It's possible that there is legitimate
non-refault IO, and there can be interaction of course between that
and the refault IO. But to be sure that all genuine refaults are
captured, can you record the workingset_* values from /proc/vmstat
before/after the thrash storm? In particular, workingset_nodereclaim
would indicate whether we are losing refault information.

[ The different resource pressures are not meant to be summed
  up. Refaults truly are both IO events and memory events: they
  indicate memory contention, but they also contribute to the IO
  load. So both metrics need to include them, or it would skew the
  picture when you only look at one of them. ]

