Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AA56C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C826820C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C826820C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6389D8E000C; Wed, 20 Feb 2019 00:50:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7BB8E0007; Wed, 20 Feb 2019 00:50:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FD798E000C; Wed, 20 Feb 2019 00:50:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 128638E0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:50:36 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f5so16069231pgh.14
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:50:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dKuTLrhjz+aL4RV8x7NaQkiah1zjm1JPHJTdgmKr4Ro=;
        b=lU7ikqoNbOCYWexrYhVyshRqnwTEMMnswc8opzpMZ0LfvG7J+B07echHAfmQCHz2L0
         R2agRqdsCwn6DzEd48JxRDF9m/+0JYKyTYwZel0WTxGcL+5+P9pAK//uRtah43iIL5gB
         bq1pPwcTnQUyByyU0ez7anAobyzEoOpesvIeu1glgYOHOqFYP37532YAP1vtcTSmQaSf
         FCBJY7Hlr/K9zNl6TPfOmq02ExRHMY8bJ/iLYOmdZPUtF62nZcvnPu/PnD+lNnsF0RkF
         jPvXg0NADd8jlLF4PMx/yGQorno8GPalP1ckJH7PxUofmwC2AAYPqDWzXMs5SbF1YCNb
         l3Mw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZw5bRW+GzIDgr2CYFvCiHXb08jm9NYaKj3J85yF1iBkSu7yRzh
	X8jZvYTdB1dHvptUEbiq8t/Fw6eBOkp9X2R/2YJMx2FA6xwmTTsfJH8aNEl+WsQT8JVKf1JHT9P
	34eAZC2gg8xhBlHMaHLuPstM9jSNPqppdM0IGbx2IilMS47T65j8YIIsjP11I4D8=
X-Received: by 2002:a62:b02:: with SMTP id t2mr3594513pfi.127.1550641835625;
        Tue, 19 Feb 2019 21:50:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iawdaa+DHYthLbzdEcOJmQU3isdnb8AA4t04kjwuHq6Ck+BSy18MTPmAqgGzd44DWTAlCRq
X-Received: by 2002:a62:b02:: with SMTP id t2mr3594471pfi.127.1550641834679;
        Tue, 19 Feb 2019 21:50:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550641834; cv=none;
        d=google.com; s=arc-20160816;
        b=EXjgu4yEZxEjICCpymX6GxsiW7s124sMdgJ/7Z9oLAJ4BrSxK/Itdt0JqpNhMhvGZF
         SjX2CTTvfRp0g/IWV5KJtcvZeAVfNMKX3BI/pcUm1BZPTBx9CLUX8Qw4yHH/iK+67lut
         OdRvnhHOqJ9lQ+yMCYxDmGEOkNEXWaF6wBg5LxrHSi9sqMZyE02yNjskaCGZlC1m/BDt
         dGUbuK1ibYFo0G/NpS5koG5WFb8iuqlSZRQKBimazGF5Uc5DURpsnQTOt8k/22jUqfcX
         0BD1wPZi3jdm+BrS3VVmkWyf2P9EGqDC75o8ZtoniDAbg7iqwoIJQoxJVnxl/RPeCuhf
         y3WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dKuTLrhjz+aL4RV8x7NaQkiah1zjm1JPHJTdgmKr4Ro=;
        b=cBZTcj1G/NAW7fb0S2tf79w7SRCsCL9/ZvixiZ7b+b9bIX+oAsoxnqj3thWJ9zgsgp
         z9MU2gmWCI3edhFLzMYDRUH9SfbrX2hyWw1v9qY4Lwho4ai6g3Af4eOMco3iUWV1eT//
         x5B6VUXFDsBZ9BemQj8su3ZU5L6pnAcaBsH92059lvkjWvOPfwzDJBgJw3Vi05K/7KPW
         +snkXp3k2F2zBa1gtqSMdNW6LQDzhgFolHVfY/Bl2YeVAQsgGhnWaV9FHI8E6Q+YGhpq
         ZJUX0P6RPjTg95QsKw7P7SCgWlgKPJTb31G+TCq6yzMRGbcVvb6h+4IE3AD54janWrPG
         aHUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id l81si18005847pfj.230.2019.02.19.21.50.33
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 21:50:34 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 20 Feb 2019 16:20:32 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gwKm7-00063W-D5; Wed, 20 Feb 2019 16:50:31 +1100
Date: Wed, 20 Feb 2019 16:50:31 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190220055031.GA23020@dastard>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220024723.GA20682@dastard>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 01:47:23PM +1100, Dave Chinner wrote:
> On Tue, Feb 19, 2019 at 07:13:33AM +0000, Roman Gushchin wrote:
> > Sorry, once more, now with fsdevel@ in cc, asked by Dave.
> > --
> > 
> > Recent reverts of memcg leak fixes [1, 2] reintroduced the problem
> > with accumulating of dying memory cgroups. This is a serious problem:
> > on most of our machines we've seen thousands on dying cgroups, and
> > the corresponding memory footprint was measured in hundreds of megabytes.
> > The problem was also independently discovered by other companies.
> > 
> > The fixes were reverted due to xfs regression investigated by Dave Chinner.
> 
> Context: it wasn't one regression that I investigated. We had
> multiple bug reports with different regressions, and I saw evidence
> on my own machines that something wasn't right because of the change
> in the IO patterns in certain benchmarks. Some of the problems were
> caused by the first patch, some were caused by the second patch.
> 
> This also affects ext4 (i.e. it's a general problem, not an XFS
> problem) as has been reported a couple of times, including this one
> overnight:
> 
> https://lore.kernel.org/lkml/4113759.4IQ3NfHFaI@stwm.de/
> 
> > Simultaneously we've seen a very small (0.18%) cpu regression on some hosts,
> > which caused Rik van Riel to propose a patch [3], which aimed to fix the
> > regression. The idea is to accumulate small memory pressure and apply it
> > periodically, so that we don't overscan small shrinker lists. According
> > to Jan Kara's data [4], Rik's patch partially fixed the regression,
> > but not entirely.
> 
> Rik's patch was buggy and made an invalid assumptions about how a
> cache with a small number of freeable objects is a "small cache", so
> any comaprisons made with it are essentially worthless.
> 
> More details about the problems with the patch and approach here:
> 
> https://lore.kernel.org/stable/20190131224905.GN31397@rh/

So, long story short, the dying memcg problem is actually a
regression caused by previous shrinker changes, and the change in
4.18-rc1 was an attempt to fix the regression (which caused evenmore
widespread problems) and Rik's patch is another different attempt to
fix the original regression.


The original regression broke the small scan accumulation algorithm
in the shrinker, but i don't think that anyone actually understood
how this was supposed to work and so the attempts to fix the
regression haven't actually restored the original behaviour. The
problematic commit:

9092c71bb724 ("mm: use sc->priority for slab shrink targets")

which was included in 4.16-rc1.

This changed the delta calculation and so any cache with less than
4096 freeable objects would now end up with a zero delta count.
This means caches with few freeable objects had no scan pressure at
all and nothing would get accumulated for later scanning. Prior to
this change, such scans would result in single digit scan counts,
which would get deferred and acummulated until the overal delta +
deferred count went over the batch size and ti would scan the cache.

IOWs, the above commit prevented accumulation of light pressure on
caches and they'd only get scanned when extreme memory pressure
occurs.

The fix that went into 4.18-rc1 change this to make the minimum scan
pressure the batch size, so instead of 0 pressure, it went to having
extreme pressure on small caches. What wasn't used in a scan got
deferred, and so the shrinker would wind up and keep heavy pressure
on the cache even when there was only light memory pressure. IOWs,
instead of having a scan count in the single digits under light
memory pressure, those caches now had continual scan counts 1-2
orders of magnitude larger. i.e. way more agressive than in 4.15 and
oler kernels. hence it introduced a different, more severe set of
regressions than the one it was trying to fix.

IOWs, the dying memcg issue is irrelevant here. The real problem
that needs fixing is a shrinker regression that occurred in 4.16-rc1,
not 4.18-rc1.

I'm just going to fix the original regression in the shrinker
algorithm by restoring the gradual accumulation behaviour, and this
whole series of problems can be put to bed.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

