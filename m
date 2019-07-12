Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6212FC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 134852084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 134852084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AC9D8E011B; Fri, 12 Jul 2019 02:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 935F58E00DB; Fri, 12 Jul 2019 02:53:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FD828E011B; Fri, 12 Jul 2019 02:53:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31C7A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:53:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so6925547edc.6
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:53:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/5m5mCskJ85zVRZlrFSwle0/wOQjTz7Q2loM5fZ8JmA=;
        b=ZJZPz6dlHTBKm7hA6UXxUmCRbUXM4gi1RPYalmD2Zk15Y+wet8YMlSmTbptxY+GGjK
         mSQKjx6nl+JoEf9fvToaqVhtsLCnjmXs1bj1GtOP3iG4gZupC3kR1sboHIjHzrsO+Hyn
         Wo9+OaN07DDEcjSJSguBa3QC+anam0AzROFtTODJE2I1cl3oJjm64MlinZRu6SOGZI/7
         bL/THL4ZAkY/99su831SDnBTzER/wnLFMUNoKwAvMwvngkE5mt/z3Ml1eOuyOVR/afSL
         LIfd6R337TwCQqq1TSymbkx5ii5cTO9IfYWF/S2A4ema8arTN5fZLZEbQ6cYbOimI79q
         EBQg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWOac3gk2r84qWZEnu33X1RlVHICn2OnxWgLmingVPQiwInJjXv
	1dMBwX22sX0n52MLyZhJkvhX9pZ47Wu6YPREyrm7b7Eq8yVzcBG+lfPRDlLyHA/mRrk13I3oqeD
	n4PId7uiNjvxCwy4t3uQpt4bwjdmUObQEjM9Y/RO7HY4iixMxcj/bAchaE3HnAaU=
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr6794568eju.105.1562914395550;
        Thu, 11 Jul 2019 23:53:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwo/Y4mQZg7fzogJJDF6MV09RKmn36CYSJC8ErAGsTO+I/18hFVOsuLNEY8bt6/ZAsalOmP
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr6794526eju.105.1562914394691;
        Thu, 11 Jul 2019 23:53:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562914394; cv=none;
        d=google.com; s=arc-20160816;
        b=Y9ok49i2xfEfFvpgKV+sUtWJcT7/teMdeXPTwMSQ4Hfj7edGrI+ICF4TCqARwPPiCl
         2U9GVRJN2dIwIF+aOsQOA9D3TG/LokgGYhosOF1E4IpVjf9bOeTvvaibmkGYelfDjFuB
         e2QU5oB4nKf6P16YcHeVKOGA93AqthpY+90JHYArIFD0UdIvgNLqmmdDqmoyRnjZO9uY
         hiOmGiBx4GDRoVsszPoVCo6Ol4T+WZ4NU4lzQPPZRsL2Mj+cG8eSpdcmZmdfWGrjXcJK
         zR8Y+G0TlFO67mZhX+aLVEkt0sF/R+ZpT0YqR0PpZ+bbPlxAI6726JBrvVAu2naB9IS9
         C2gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/5m5mCskJ85zVRZlrFSwle0/wOQjTz7Q2loM5fZ8JmA=;
        b=JU9syI9CW9pUKrUsBYnnZoAlsdVeYxyRQ191iBgan+oxO95fTOK9nhlzF9txboCybG
         sxoWn+bO/OBIIbVMTAYQfHzN69p0iThudDpL8S4h0EAJ1xsuDxjQn2JFNVQYzyHFFVuz
         cku8PZpt/ii11rcemg7UkhcasiuZl0ihfELQIb5MHlcDjkF63gTHc1AvPFgQ+Jpy7JbC
         Uiz3O4VuJVylkBDc90d4u008NN8S8IekJlCWfvuRadhdNWTlF9MNgg12KClEDRRBDl4V
         ksf3PowKFNz9aCkeHjzZp5O/90aWYEzQc7+QGOZwcDfq11qqUo91RbyP4XyF3mF0GYZa
         W85A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18si4023333eji.250.2019.07.11.23.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 23:53:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D4C89AFE4;
	Fri, 12 Jul 2019 06:53:13 +0000 (UTC)
Date: Fri, 12 Jul 2019 08:53:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with
 the hierarchical ones
Message-ID: <20190712065312.GJ29483@dhcp22.suse.cz>
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
 <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
 <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
 <20190712052938.GI29483@dhcp22.suse.cz>
 <CALOAHbCt7b-AMDtK6FmAfYnYSMiB=UhKbBVKt7CzFFazzrKeVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbCt7b-AMDtK6FmAfYnYSMiB=UhKbBVKt7CzFFazzrKeVQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 14:12:30, Yafang Shao wrote:
> On Fri, Jul 12, 2019 at 1:29 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 12-07-19 09:47:14, Yafang Shao wrote:
> > > On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > >
> > > > On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> > > >
> > > > > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > > > > the local VM counters is not in sync with the hierarchical ones.
> > > > >
> > > > > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> > > > >       inactive_file 3567570944
> > > > >       total_inactive_file 3568029696
> > > > > We can find that the deviation is very great, that is because the 'val' in
> > > > > __mod_memcg_state() is in pages while the effective value in
> > > > > memcg_stat_show() is in bytes.
> > > > > So the maximum of this deviation between local VM stats and total VM
> > > > > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > > > > great value.
> > > > >
> > > > > We should keep the local VM stats in sync with the total stats.
> > > > > In order to keep this behavior the same across counters, this patch updates
> > > > > __mod_lruvec_state() and __count_memcg_events() as well.
> > > >
> > > > hm.
> > > >
> > > > So the local counters are presently more accurate than the hierarchical
> > > > ones because the hierarchical counters use batching.  And the proposal
> > > > is to make the local counters less accurate so that the inaccuracies
> > > > will match.
> > > >
> > > > It is a bit counter intuitive to hear than worsened accuracy is a good
> > > > thing!  We're told that the difference may be "unacceptably great" but
> > > > we aren't told why.  Some additional information to support this
> > > > surprising assertion would be useful, please.  What are the use-cases
> > > > which are harmed by this difference and how are they harmed?
> > > >
> > >
> > > Hi Andrew,
> > >
> > > Both local counter and the hierachical one are exposed to user.
> > > In a leaf memcg, the local counter should be equal with the hierarchical one,
> > > if they are different, the user may wondering what's wrong in this memcg.
> > > IOW, the difference makes these counters not reliable, if they are not
> > > reliable we can't use them to help us anylze issues.
> >
> > But those numbers are in flight anyway. We do not stop updating them
> > while they are read so there is no guarantee they will be consistent
> > anyway, right?
> 
> Right.
> They can't be guaranted to be consistent.
> When we read them, may only the local counters are updated and the
> hierarchical ones are not updated yet.
> But the current deviation is so great that can't be ignored.

Is really 32 pages per cpu all that great?

Please note that I am not objecting to the patch (yet) because I didn't
get to think about it thoroughly but I do agree with Andrew that the
changelog should state the exact problem including why it matters.
I do agree that inconsistencies are confusing but maybe we just need to
document the existing behavior better.
-- 
Michal Hocko
SUSE Labs

