Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C54AC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:56:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B9A20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:56:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B9A20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84E88E0005; Thu,  7 Mar 2019 13:56:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0A5B8E0002; Thu,  7 Mar 2019 13:56:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAC0B8E0005; Thu,  7 Mar 2019 13:56:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0418E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:56:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id j1so13832928qkl.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:56:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7g6R7arc9MO4XHg9VJeEmN4q7bHX3l4uTM+2nxIkx3o=;
        b=uJ1yjq0on7zf/75pPUV5Mru7hg37Kcp+W+qQ1juXET85DLAFVuUCuJjxqmz4sO1UPR
         KstB4EpGvf1R1tMRnPUok72/0qWTWyIjnZPVT0rCHD8TTL40A3x3k7VQIhvbPPGdWt8c
         BIdVcAfTFOgSWzBz6UIbwPiUTMeJvXR1qAuFEirpcb7i4iv37NGhU2Z0CViRJp1RnlTN
         1ly5uFWOL6QvUCuoZrWGsHetd6K/WeuI1Ltp0PfVksrPFER/rtrF7t1tpiEvIfE/Lh6S
         2huLn8d+47MRITYxRYIkGxMaeePt8eyiO6Kjy0cdqvxzQPEL+1/5m9TMs+upsentclj/
         h9Sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWmQLZCM4vQR8LVkKvG7fHx7C71qXWZT+ErU5XXIYNfxMEjjr1d
	oYeiT5mpnsEByIBrt6HmvGAgaXQWVSSA4gqRNTOFWdHPbhH2oapFK8fzQIMaDiudSfTbVyndXbF
	XktcOpSy6dZPnrZcBA1suBisDOr2OHaL1mHoZCWJA6LtcJLbpSDusZzhADzODM2XX5Q==
X-Received: by 2002:ac8:1a51:: with SMTP id q17mr11285480qtk.310.1551984988390;
        Thu, 07 Mar 2019 10:56:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqw1fFZZVAukgwJLwvcsBFV3OVkspL/dmvfU7mwx8ZWsGxBVVs91FJb/aSct0tSvjvuqlejQ
X-Received: by 2002:ac8:1a51:: with SMTP id q17mr11285428qtk.310.1551984987530;
        Thu, 07 Mar 2019 10:56:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551984987; cv=none;
        d=google.com; s=arc-20160816;
        b=anH+ortHjv0Bot26hn9lE/4XmkM++tje9ntf+QyJOdNkX8L6pqiLpJHtBaRpEEvO4Y
         jyxImHunhqaXeoEegV7Fqgxy5iQJFt2U4TTr4OZfKogqezadgZPRUcY+yT6XAMCLDTus
         VFGy376rmgfBPQ+fPLt28M+m9DjObXC2ZxVRDi9eRC0Jci5XTHvHHr7jHp0+8YznKXrd
         xgh5/R0h9Kq/VilPvdM1lStTnR50u99G6q6szDRXxg2ookRh0I7WIyOGpH0GvTzLL36Q
         Zw/DcM6ppeZe3d3bYUFd5+eUFBowlj9NDf7FF5D5bIW6vxoKO2y4VzvmLv+s47g5B1Jd
         tGUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7g6R7arc9MO4XHg9VJeEmN4q7bHX3l4uTM+2nxIkx3o=;
        b=vT3HG2fkClVnv+VQj99XgsE1Ihn+FQ2ce5Mt42Dr5etXNhMyQZ4w8WhVeC+6L1rz0/
         sMG2ZABy8XsK0LThnbdgnDyWM779F3gl+lpcBOG08uRyyR98VbOwnTMRFoyVtgJyTDwL
         bo2TJ8/1cA7Z8fSIjkDH4q1nNKsT507mL9LgRTjPQdvTOFws0N7rkK0H1W4kLcAnUyV7
         oJjMr6swcLmnjvuBHNFgHHDSwRjTGNHaqY16up4TvHiZOqpBg1P/JwcAA2cdiqvI4Dtx
         sLa5eS0QO+OfRXdjJ1swsx7P2Pg8XoydIi0iG5gEIbHiVuALulDBjjZZvYKFO5MZNniU
         w5vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l44si3319001qtk.19.2019.03.07.10.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:56:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A060F30917A8;
	Thu,  7 Mar 2019 18:56:26 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A2D7F19C65;
	Thu,  7 Mar 2019 18:56:25 +0000 (UTC)
Date: Thu, 7 Mar 2019 13:56:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190307185623.GD3835@redhat.com>
References: <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
 <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307094654.35391e0066396b204d133927@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 07 Mar 2019 18:56:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 09:46:54AM -0800, Andrew Morton wrote:
> On Tue, 5 Mar 2019 20:20:10 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> 
> > My hesitation would be drastically reduced if there was a plan to
> > avoid dangling unconsumed symbols and functionality. Specifically one
> > or more of the following suggestions:
> > 
> > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > surface for out-of-tree consumers to come grumble at us when we
> > continue to refactor the kernel as we are wont to do.
> 
> The existing patches use EXPORT_SYMBOL() so that's a sticking point. 
> Jerome, what would happen is we made these EXPORT_SYMBOL_GPL()?

So Dan argue that GPL export solve the problem of out of tree user and
my personnal experience is that it does not. The GPU sub-system has tons
of GPL drivers that are not upstream and we never felt that we were bound
to support them in anyway. We always were very clear that if you are not
upstream that you do not have any voice on changes we do.

So my exeperience is that GPL does not help here. It is just about being
clear and ignoring anyone who does not have an upstream driver ie we have
free hands to update HMM in anyway as long as we keep supporting the
upstream user.

That being said if the GPL aspect is that much important to some then
fine let switch all HMM symbol to GPL.

> 
> > * A commitment to consume newly exported symbols in the same merge
> > window, or the following merge window. When that goal is missed revert
> > the functionality until such time that it can be consumed, or
> > otherwise abandoned.
> 
> It sounds like we can tick this box.

I wouldn't be too strick either, when adding something in release N
the driver change in N+1 can miss N+1 because of bug or regression
and be push to N+2.

I think a better stance here is that if we do not get any sign-off
on the feature from driver maintainer for which the feature is intended
then we just do not merge. If after few release we still can not get
the driver to use it then we revert.

It just feels dumb to revert at N+1 just to get it back in N+2 as
the driver bit get fix.

> 
> > * No new symbol exports and functionality while existing symbols go unconsumed.
> 
> Unsure about this one?

With nouveau upstream now everything is use. ODP will use some of the
symbol too. PPC has patchset posted to use lot of HMM too. I have been
working with other vendor that have patchset being work on to use HMM
too.

I have not done all those function just for the fun of it :) They do
have real use and user. It took a longtime to get nouveau because of
userspace we had a lot of catchup to do in mesa and llvm and we are
still very rough there.

Cheers,
Jérôme

