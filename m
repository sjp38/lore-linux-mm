Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62341C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 23:26:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C1062147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 23:26:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C1062147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F318E0003; Tue, 19 Feb 2019 18:26:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE5A8E0002; Tue, 19 Feb 2019 18:26:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DD0D8E0003; Tue, 19 Feb 2019 18:26:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 656DB8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:26:40 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f70so1046653qke.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:26:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=meFASeVm8AgDUCXNN7Y8QzAbvDPsmwGcXRRsijRK3Ro=;
        b=cyCdWyo7c0su9qv474sJcK4HzKgY0SWXHOx+Uq1tYaRUeHO8+eLkamXxwhcCd+O3wT
         sLv0AM4+ZARcpukwcztiSCIeny1ZRFy74aFwoxwp0NktxtwtxqWLX9qpDkBhThCqLDBG
         a+D87YVJOj9SNADvY3H3N+m//iDw7FUQYK7u8SQkFZH0ZESyI8Tgp+7wzj2LRReuPilm
         4soHkFyUApN9rrJjc0JIFobZtJwKlEkztnzvE/QpWWEMOsh5hmbrhtQHbnmH1salV7v7
         VqGUoZQJzgAwkXgeCRalXBD0JHUw9fddTw4tdW4QqSQ0Lhf+t8hBaWtzRWTfUmLha9G5
         chSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZhr8rXTqW0q1Ek2u8WwWPZjHCurHPLEpVOHnc89v6S8DhmFYXs
	u5I3M8hUSD59wJfCVbR1rWq2qLSEBaFEFveLT9U22R08tV+Xa5YobSFEgJxQLRbwZjWlPg2rpEW
	R91zgGxStX6z/7XUnZv625ToEkDtrh+Wcd7Nl/ADaAOZjPywY5/aYWkq0PKhO3Ga8sg==
X-Received: by 2002:a0c:a326:: with SMTP id u35mr23918580qvu.190.1550618800124;
        Tue, 19 Feb 2019 15:26:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5jRo6hau3VluRxCb4BZax3HgE2zhvku9+SGnJ/g9cG3K99l30VUhW0SmAoq6zZT7TwxIF
X-Received: by 2002:a0c:a326:: with SMTP id u35mr23918541qvu.190.1550618799066;
        Tue, 19 Feb 2019 15:26:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550618799; cv=none;
        d=google.com; s=arc-20160816;
        b=UndKmQ2hzJJ3KPrtvXq8g+zNCVRvyTQ/OyVOAUcEbROnp5ySDLyZKpVp18sPR084UL
         a4bDRB0SzK+p1YHTCq3EC+x80nLTjlHTP4/F6WHrl6Sr4aQwI86qXyuc3yO2F701rQ/6
         vN3W6YvHZwL3KGlas8fjoOckljDi/cKnbMs2P77CrxB+FhZ1FmhcBFpUbnFa7GOFmrC+
         F8CXkf2tgB8NSKSl/R6fbFZgqtpnqunlOPihNKf0+L5gmH2AJ8bQkfl2Hdd4I8wC0bn+
         TPd54epEF/y91y+GydlnIi+zN6AVrKLhfS5iqchjEH/5JkaQX7/dMWRcxdDsVrIjWhAT
         yFBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=meFASeVm8AgDUCXNN7Y8QzAbvDPsmwGcXRRsijRK3Ro=;
        b=qoFPeVzwMWTvcIhKR+0oibtTFTsFjfg5FJimAc5r4+bRE/TLKRo4KdocT1mOU+sNUZ
         veAAN19wCgZ0PW0uGbGCQk6X/00Hy/X3IVyYM7KX9bCDCniFyndah+u6w559e32/Z/t5
         Jrv9nRxjOFi+/Ko+UFkPnLc3vZCpW/ttIHTfXnIh7e/rZrDvfwALxy45ellRBPLmfI4P
         Ah81WVL+jrIPE7K+Ye0y5u25OvIWtFDWBs+KM3e/tTBVKyMQ3OAijUPC1E2OOtYc1wBl
         AuG01tCOEmSOT5ElNSO9RYhKWTewBUUTL8+BIG/M8oezY9ndhGTOboDXGnuvp7mKnbPc
         dAwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o34si148209qva.1.2019.02.19.15.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 15:26:39 -0800 (PST)
Received-SPF: pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AEA9413A4C;
	Tue, 19 Feb 2019 23:26:37 +0000 (UTC)
Received: from rh (ovpn-116-82.phx2.redhat.com [10.3.116.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2656D66082;
	Tue, 19 Feb 2019 23:26:36 +0000 (UTC)
Received: from [::1] (helo=rh)
	by rh with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <dchinner@redhat.com>)
	id 1gwEmU-0005Zu-A5; Wed, 20 Feb 2019 10:26:30 +1100
Date: Wed, 20 Feb 2019 10:26:27 +1100
From: Dave Chinner <dchinner@redhat.com>
To: Rik van Riel <riel@surriel.com>
Cc: Roman Gushchin <guro@fb.com>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190219232627.GZ31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
 <20190219020448.GY31397@rh>
 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 19 Feb 2019 23:26:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:31:10PM -0500, Rik van Riel wrote:
> On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> > On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > > Sorry, resending with the fixed to/cc list. Please, ignore the
> > > first letter.
> > 
> > Please resend again with linux-fsdevel on the cc list, because this
> > isn't a MM topic given the regressions from the shrinker patches
> > have all been on the filesystem side of the shrinkers....
> 
> It looks like there are two separate things going on here.
> 
> The first are an MM issues, one of potentially leaking memory
> by not scanning slabs with few items on them,

We don't leak memory. Slabs with very few freeable items on them
just don't get scanned when there is only light memory pressure.
That's /by design/ and it is behaviour we've tried hard over many
years to preserve. Once memory pressure ramps up, they'll be
scanned just like all the other slabs.

e.g. commit 0b1fb40a3b12 ("mm: vmscan: shrink all slab objects if
tight on memory") makes this commentary:

    [....] That said, this
    patch shouldn't change the vmscan behaviour if the memory pressure is
    low, but if we are tight on memory, we will do our best by trying to
    reclaim all available objects, which sounds reasonable.

Which is essentially how we've tried to implement shrinker reclaim
for a long, long time (bugs notwithstanding).

> and having
> such slabs stay around forever after the cgroup they were
> created for has disappeared,

That's a cgroup referencing and teardown problem, not a memory
reclaim algorithm problem. To treat it as a memory reclaim problem
smears memcg internal implementation bogosities all over the
independent reclaim infrastructure. It violates the concepts of
isolation, modularity, independence, abstraction layering, etc.

> and the other of various other
> bugs with shrinker invocation behavior (like the nr_deferred
> fixes you posted a patch for). I believe these are MM topics.

Except they interact directly with external shrinker behaviour. the
conditions of deferral and the problems it is solving are a direct
response to shrinker implementation constraints (e.g. GFP_NOFS
deadlock avoidance for filesystems). i.e. we can't talk about the
deferal algorithm without considering why work is deferred, how much
work should be deferred, when it may be safe/best to execute the
deferred work, etc.

This all comes back to the fact that modifying the shrinker
algorithms requires understanding what the shrinker implementations
do and the constraints they operate under. It is not a "purely mm"
discussion, and treating it as such results regressions like the
ones we've recently seen.

> The second is the filesystem (and maybe other) shrinker
> functions' behavior being somewhat fragile and depending
> on closely on current MM behavior, potentially up to
> and including MM bugs.
> 
> The lack of a contract between the MM and the shrinker
> callbacks is a recurring issue, and something we may
> want to discuss in a joint session.
> 
> Some reflections on the shrinker/MM interaction:
> - Since all memory (in a zone) could potentially be in
>   shrinker pools, shrinkers MUST eventually free some
>   memory.

Which they cannot guarantee because all the objects they track may
be in use. As such, shrinkers have never been asked to guarantee
that they can free memory - they've only ever been asked to scan a
number of objects and attempt to free those it can during the scan.

> - Shrinkers should not block kswapd from making progress.
>   If kswapd got stuck in NFS inode writeback, and ended up
>   not being able to free clean pages to receive network
>   packets, that might cause a deadlock.

Same can happen if kswapd got stuck on dirty page writeback from
pageout(). i.e. pageout() can only run from kswapd and it issues IO,
which can then block in the IO submission path waiting for IO to
make progress, which may require substantial amounts of memory
allocation.

Yes, we can try to not block kswapd as much as possible just like
page reclaim does, but the fact is kswapd is the only context where
it is safe to do certain blocking operations to ensure memory
reclaim can actually make progress.

i.e. the rules for blocking kswapd need to be consistent across both
page reclaim and shrinker reclaim, and right now page reclaim can
and does block kswapd when it is necessary for forwards progress....

> - The MM should be able to deal with shrinkers doing
>   nothing at this call, but having some work pending 
>   (eg. waiting on IO completion), without getting a false
>   OOM kill. How can we do this best?

By integrating shrinkers into the same feedback loops as page
reclaim. i.e. to allow individual shrinker instance state to be
visible to the backoff/congestion decisions that the main page
reclaim loops make.

i.e. the problem here is that shrinkers only feedback to the main
loop is "how many pages were freed" as a whole. They aren't seen as
individual reclaim instances like zones for apge reclaim, they are
just a huge amorphous blob that "frees some pages". i.e. They sit off to
the side and run their own game between main loop scans and have no
capability to run individual backoffs, schedule kswapd to do future
work, don't have watermarks to provide reclaim goals, can't
communicate progress to the main control algorithm, etc.

IOWs, the first step we need to take here is to get rid of
the shrink_slab() abstraction and make shrinkers a first class
reclaim citizen....

> - Related to the above: stalling in the shrinker code is
>   unpredictable, and can take an arbitrarily long amount
>   of time. Is there a better way we can make reclaimers
>   wait for in-flight work to be completed?

Look at it this way: what do you need to do to implement the main
zone reclaim loops as individual shrinker instances? Complex
shrinker implementations have to deal with all the same issues as
the page reclaim loops (including managing cross-cache dependencies
and balancing). If we can't answer this question, then we can't
answer the questions that are being asked.

So, at this point, I have to ask: if we need the same functionality
for both page reclaim and shrinkers, then why shouldn't the goal be
to make page reclaim just another set of opaque shrinker
implementations?

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

