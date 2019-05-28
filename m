Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BDE3C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFFFC20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:56:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFFFC20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 881176B026F; Tue, 28 May 2019 07:56:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8316F6B0272; Tue, 28 May 2019 07:56:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FA726B0273; Tue, 28 May 2019 07:56:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23DA76B026F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:56:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y22so32742079eds.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:56:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oXeVIQ9QS+dITA61XAEL8EPsLqLMJzYMLQi0Uyib3MM=;
        b=ObbuJSdXahIfRakaXohykuA+oa3343viVKONsHnUbs8mjkdp2MwQqPxUS61PIfU8kZ
         yZxY8QNH3Ql6hUXtg5G7RGl0czQc8iFT9T8r5q5an1IrSYe8mW7+S5SO9nIgMhLbVfnU
         vLAtxfC131cWWyOhTjG0LfqzqOj2H0fxM5N6wCHggTEMvinR/KmW1rbpGGHVfPJuAqtm
         EvazV/YcfFzAtvjw5AYuotl7hhZjyPViAKPV9nueoo+rOwbown05GO512GGBlzg+74wY
         0W14sO5X2liag0IvsccKUGj3ea+VwPyoK3WaAtncudP4zN2Ou2H/rZB8+LnP9hpkPw3G
         wReg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXPML3AkraHlLNKFeyxjyUdWiJdCiqB77qVuKvoJf8ctGNtFNY1
	8hJymSsrbJrOZYbUAbXUBS1fMohYdNFoBq85xmV1lNO1oMepVKBqKRiONalPN77qJXLXJktnFQN
	Ipg5LDsS+5DocR0w3H1Y1Wqf6pC3Wail43hecPmx75QEl8RjoLb97t8WaSYCN/8U=
X-Received: by 2002:a50:86a2:: with SMTP id r31mr127483323eda.259.1559044572698;
        Tue, 28 May 2019 04:56:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6NJYtMeRcO1vl9VBGQ7MHhXZgnrEYTXMll3QbObSWz1PTNOJs5h7aX5NopOGI0AOoW1H/
X-Received: by 2002:a50:86a2:: with SMTP id r31mr127483264eda.259.1559044571883;
        Tue, 28 May 2019 04:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559044571; cv=none;
        d=google.com; s=arc-20160816;
        b=oGwaXjfGW46rPDNDt0e0vOIjzRD10vCZJh2recatdcDlXwoK1cHmtuPNidIu2lpTux
         /AB8PAvTjICJeeMbpv27VAOdFGI0lSyIjaDl1Wx9LTiUO2z82jJVqq5D1ZE+6pTlLOk2
         8tkbN+z0B43Wh0S63HHzdBMFRXAXnuZ2zzT8g22WNtutJeHqfJeqaATCh5rGDv4xsF/k
         XebjLuLJAfXMVPFtnwjA7t7xy9KSaqI0TjjYzbU6PhBYbREHAVUBrjw1NQlcaXM1IxNc
         JlHQbe0xbPbZptuu4z0faU7mgCvKWiZJ12jHtEuQ8uFGh0DRxuMIONIgRBlsdVT/wbZC
         k6+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oXeVIQ9QS+dITA61XAEL8EPsLqLMJzYMLQi0Uyib3MM=;
        b=tlmfb1JqBudFDmneJEk45Sn3LkewTSx3i6AF4PaF7zypxJnbGFuDMVlnP+Xi0DMa1s
         rUXqaJzn1bVDnpX879gRuRE49G6rJHiT1xudA5X7IcFWJWPIjSeaaTfrCnAsGTv/VLnN
         Z0woPOrw1P9XI1ZolLG3OD4qs3He4vcbDyN1y7EiMlP7gnAdai0vHhM7JWF12G/J7uOe
         VoW0pCg6odKDquhRIagaj+Yz0fW51KhzHnXV2+0oxCiN3CGPIzFyZ942Kc410pL5zoZK
         mV831ZvMzBlpQA2O/8apDmykIvB1j9X32JpLhBtvRzjWH+EARINdqcEh9zQl8I9bM1U2
         LO3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si6354980edh.215.2019.05.28.04.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:56:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2AFCEAD4A;
	Tue, 28 May 2019 11:56:11 +0000 (UTC)
Date: Tue, 28 May 2019 13:56:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528115609.GA1658@dhcp22.suse.cz>
References: <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
 <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 04:42:47, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > >
> > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > >
> > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > e.g., Android memory map debugging commands.
> > > > > > >
> > > > > > > I agree it's the best we can get *generally*.
> > > > > > > Michal, any opinion?
> > > > > >
> > > > > > I am not really sure this is directly related. I think the primary
> > > > > > question that we have to sort out first is whether we want to have
> > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > so far unfortunately.
> > > > >
> > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > but thought it could be easily extended later for each address range
> > > > > operation as userspace getting smarter with more information.
> > > >
> > > > Never design user API based on a single usecase, please. The "easily
> > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > several times, the synchronization model has to be thought through
> > > > carefuly before a remote process address range operation can be
> > > > implemented.
> > >
> > > I agree with you that we shouldn't design API on single usecase but what
> > > you are concerning is actually not our usecase because we are resilient
> > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > Actually, many hints are already racy in that the upcoming pattern would
> > > be different with the behavior you thought at the moment.
> >
> > How come they are racy wrt address ranges? You would have to be in
> > multithreaded environment and then the onus of synchronization is on
> > threads. That model is quite clear. But we are talking about separate
> > processes and some of them might be even not aware of an external entity
> > tweaking their address space.
> 
> I don't think the difference between a thread and a process matters in
> this context. Threads race on address space operations all the time
> --- in the sense that multiple threads modify a process's address
> space without synchronization.

I would disagree. They do have in-kernel synchronization as long as they
do not use MAP_FIXED. If they do want to use MAP_FIXED then they better
synchronize or the result is undefined.

> The main reasons that these races
> hasn't been a problem are: 1) threads mostly "mind their own business"
> and modify different parts of the address space or use locks to ensure
> that they don't stop on each other (e.g., the malloc heap lock), and
> 2) POSIX mmap atomic-replacement semantics make certain classes of
> operation (like "magic ring buffer" setup) safe even in the presence
> of other threads stomping over an address space.

Agreed here.

[...]

> From a synchronization point
> of view, it doesn't really matter whether it's a thread within the
> target process or a thread outside the target process that does the
> address space manipulation. What's new is the inspection of the
> address space before performing an operation.

The fundamental difference is that if you want to achieve the same
inside the process then your application is inherenly aware of the
operation and use whatever synchronization is needed to achieve a
consistency. As soon as you allow the same from outside you either
have to have an aware target application as well or you need a mechanism
to find out that your decision has been invalidated by a later
unsynchronized action.

> Minchan started this thread by proposing some flags that would
> implement a few of the filtering policies I used as examples above.
> Personally, instead of providing a few pre-built policies as flags,
> I'd rather push the page manipulation policy to userspace as much as
> possible and just have the kernel provide a mechanism that *in
> general* makes these read-decide-modify operations efficient and
> robust. I still think there's way to achieve this goal very
> inexpensively without compromising on flexibility.

Agreed here.

-- 
Michal Hocko
SUSE Labs

