Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7EA2C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:11:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EF3426A17
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:11:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QiARnrE8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EF3426A17
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 251216B026F; Fri, 31 May 2019 10:11:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201046B0278; Fri, 31 May 2019 10:11:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EFFF6B027A; Fri, 31 May 2019 10:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB31D6B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:11:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r191so4769737pgr.23
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:11:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0xhb1pyImBa/JbJpYpXNh4R8mvOJIMPwfstX4vjxQNI=;
        b=p5876epTkUGdsrmVVzXO+U2vCAWdERKbNszQOJ5JEJCOSx1c6wxnIRr1cGI1qGOXc6
         vRp0TAgdW6/PJ4lPCTa0NwTH/YWe0qtZsiUTt9aQasTGE0WJZ6yCVY6s2CTNzVPCqL0z
         BuWaSSZ11kkYeBLWMyRO0bPG7gjC1cETnAW3kd29Lh/MGGKAyCYG6zVd6IVZrUYtjrpI
         LXx6I6lYKBgzNUH9nibdIa3+Nlm3TB1VufGa9TegLB2GMGRVesCYQjeBdqNMUZBGQyWi
         ElwBk2IFqI+UkP1odOdKVGWEW7iTGMaH4Kamg6mTe6jEtYl3fBjqya1thP0yWKW5u1Ej
         c66g==
X-Gm-Message-State: APjAAAUzmTDx5piYrppaEGJvaiCrpW43dzan4sF/2brIBRhWwLYOv7dX
	/lDCLNF3u+BK0RYKiDrtSGUEGNDV6eBCVTVvOay3ZMeDSxp42tQosuc7eKXB5rL9xiVsmTV+P84
	k5p+yBwK3+WgzJAbZUffFSrPts/Gw5Dbrnf8ygwm8Mkg7moGKbzv2Tjn4xW/F0OU=
X-Received: by 2002:a17:902:b94a:: with SMTP id h10mr9798458pls.265.1559311914339;
        Fri, 31 May 2019 07:11:54 -0700 (PDT)
X-Received: by 2002:a17:902:b94a:: with SMTP id h10mr9798375pls.265.1559311913618;
        Fri, 31 May 2019 07:11:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559311913; cv=none;
        d=google.com; s=arc-20160816;
        b=u1nznR4sTBbsWIuWwE0aLiSqO7mlJu3qGFYbgpCWGIZwTLwZr743P9mE2Sv3GGAgbO
         EvB1GoiXXMmQ5HOxoibFFHUKdZ7r8Mryya0sf7NEWeYSa8MKZFTHayYHDFE8O3lxKzR/
         fnulXeNNzLJiQBUVxWEXjQGtgmlLi+PEa4fpaqAxPzmoU1Ic4iJOIsTsyqOLha5MRQSG
         vRvBmOROYXSpgZT7H5gylNr3cighKq0dLLX0q6N9mDP7FbD21kXpTlk/x05Z0eB2NOfB
         GYHpAiM+gooHlAG5IdJ4VzJ0p/TqXQS80mENgI1hwg0RV72jd7FB2fPHozvl5Apai/tq
         TMwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=0xhb1pyImBa/JbJpYpXNh4R8mvOJIMPwfstX4vjxQNI=;
        b=ke2zF+p+dxni2u2/nivXRfJuElolnHYGGi6fG0M28ioV770l+PYwtCC0NpYOgzViT0
         JyOIf+Zi38tRh8/3tcaW6cljCDL7Gf1ImSbqHnMndM3JfkZUCBrCSzDtkoI0wY8Dshps
         vkpcwmugis8Q5KawkFukpNCQJd8P1e1vHzMoxefVs3wCLgCpHPVxpJgXlXfX+yZCR0Cy
         0y0ZibnF23SD5c5FYQpcHRyRClSLK6NrIWNwh+hN0D8uTjbxce2pqUBmEuj/g8yumWFm
         8IfC02Fz76qQ81ek7AGPjkv3GxMP9Ze6/fte+bXOAZegEEiMuS25f9oRxrYRPPT4q9A2
         b1pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QiARnrE8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor6943387plz.51.2019.05.31.07.11.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:11:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QiARnrE8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0xhb1pyImBa/JbJpYpXNh4R8mvOJIMPwfstX4vjxQNI=;
        b=QiARnrE80tnvvBre/mbPmuOKYNVVU8yYQMl/Ex2SrVLL+VfRNrYAD61HNOf0R3SPAb
         j44k0B09Ni2Ex/RblGlTkMnGKdwiyC9sqSZtLlKZX/BWZLzkFKSoJlgHv065+qA9jiTD
         9MK2MRBipL+7zBbywzPB1bZaN4VP/WKmThTlnUztCsxMTnHjgQVhjJSkIaNaOYhBKK0c
         Q2A5ZFUiVoEzwLBqY2pO9Mgb4Bn8SAGzxoRx/cvzf9q58xcFW+bks2xKeh8iCk6BZL91
         wDHdZ40z6OJh/aa9BdJXdimdyuf1zFwcCv82PyPaEiJmQYRq4vijRYwNx9iLgsCaQoeh
         JwYg==
X-Google-Smtp-Source: APXvYqxRT6KrKzfpF6xMTycahrhhwULrJhijSmTAOdDfaQnfB69oVdK0PWFLHL8zxsiMQ2ZRQW2XIA==
X-Received: by 2002:a17:902:e311:: with SMTP id cg17mr9750155plb.202.1559311913113;
        Fri, 31 May 2019 07:11:53 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id m1sm5501839pjv.22.2019.05.31.07.11.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 07:11:51 -0700 (PDT)
Date: Fri, 31 May 2019 23:11:43 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 5/6] mm: introduce external memory hinting API
Message-ID: <20190531141142.GA216592@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-6-minchan@kernel.org>
 <20190531083757.GH6896@dhcp22.suse.cz>
 <20190531131859.GB195463@google.com>
 <20190531140050.GS6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531140050.GS6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 04:00:50PM +0200, Michal Hocko wrote:
> On Fri 31-05-19 22:19:00, Minchan Kim wrote:
> > On Fri, May 31, 2019 at 10:37:57AM +0200, Michal Hocko wrote:
> > > On Fri 31-05-19 15:43:12, Minchan Kim wrote:
> > > > There is some usecase that centralized userspace daemon want to give
> > > > a memory hint like MADV_[COLD|PAGEEOUT] to other process. Android's
> > > > ActivityManagerService is one of them.
> > > > 
> > > > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > > > required to make the reclaim decision is not known to the app. Instead,
> > > > it is known to the centralized userspace daemon(ActivityManagerService),
> > > > and that daemon must be able to initiate reclaim on its own without
> > > > any app involvement.
> > > > 
> > > > To solve the issue, this patch introduces new syscall process_madvise(2).
> > > > It could give a hint to the exeternal process of pidfd.
> > > > 
> > > >  int process_madvise(int pidfd, void *addr, size_t length, int advise,
> > > > 			unsigned long cookie, unsigned long flag);
> > > > 
> > > > Since it could affect other process's address range, only privileged
> > > > process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> > > > gives it the right to ptrace the process could use it successfully.
> > > > 
> > > > The syscall has a cookie argument to privode atomicity(i.e., detect
> > > > target process's address space change since monitor process has parsed
> > > > the address range of target process so the operaion could fail in case
> > > > of happening race). Although there is no interface to get a cookie
> > > > at this moment, it could be useful to consider it as argument to avoid
> > > > introducing another new syscall in future. It could support *atomicity*
> > > > for disruptive hint(e.g., MADV_DONTNEED|FREE).
> > > > flag argument is reserved for future use if we need to extend the API.
> > > 
> > > Providing an API that is incomplete will not fly. Really. As this really
> > > begs for much more discussion and it would be good to move on with the
> > > core idea of the pro active memory memory management from userspace
> > > usecase. Could you split out the core change so that we can move on and
> > > leave the external for a later discussion. I believe this would lead to
> > > a smoother integration.
> > 
> > No problem but I need to understand what you want a little bit more because
> > I thought this patchset is already step by step so if we reach the agreement
> > of part of them like [1-5/6], it could be merged first.
> > 
> > Could you say how you want to split the patchset for forward progress?
> 
> I would start with new madvise modes and once they are in a shape to be
> merged then we can start the remote madvise API. I believe that even
> local process reclaim modes are interesting and useful. I haven't heard
> anybody objecting to them without having a remote API so far.

Okay, let's focus on [1-3/6] at this moment.

> -- 
> Michal Hocko
> SUSE Labs

