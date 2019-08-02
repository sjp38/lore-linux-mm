Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16377C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 11:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB674206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 11:44:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB674206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C88E6B0003; Fri,  2 Aug 2019 07:44:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079BC6B0005; Fri,  2 Aug 2019 07:44:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0F86B0006; Fri,  2 Aug 2019 07:44:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A29FB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 07:44:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so46769621edr.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 04:44:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M8TieNPi99QOG18so2PuFYh3e5+sQHpWy3chTWzm/rQ=;
        b=TKa7VJvplxTkP2EYq/zTETUiKnAcQ53q+FpyyK2NJPwuxbcoe6bGud6I1UJzaU+kqv
         YCcTeutd13hFnPYGtsXY9lOXkWO/mD+iPrMkxqEFbqNymU89HmEqqh8Ma16TapwRgpL4
         mwZm/2wTym6e6oZyJ5TmMQfoDRL/irEDA8gGWnn0ZTNRSSdSQDOUYCSy0Bg46n6lwIsr
         tBNpx/tYnq0UUrRDr/fGbAjlqkfWsW3j9KrmthaRAdl4W9SrVyI8BRDXJAOsXA4KjdBM
         dhvCLTsYUzl3TQI3WGmYkXXka7/pDQCUKMIENZPWwk/iW36BwaVqGIXR5+HBWdv81vR3
         jd5g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWV+J0PK3Qd5cVBh105+MiBnZ/fhrrxCH308qHuUbE3byzEQsl0
	7CS3p6PijR+8l3SpgxrkdzgTQ2sho1SnTdeNlMlBqQk+4qmLwrYdyX7gbnV/gyzWlaZbcjMF1My
	nxSQkHrgSGY5C/Ehod2fjNKhQ49J/lPCIukPjHaEqgzQ8E9ZYUkOGUN05p7DqXo8=
X-Received: by 2002:a50:b1e7:: with SMTP id n36mr119526723edd.227.1564746282125;
        Fri, 02 Aug 2019 04:44:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsf5j/vwTl49qgIUg09rsK5SHDUXjTz8cBYXTVGQVEsJuUqfBihC2nMdDCVQTsdTVy9Cfg
X-Received: by 2002:a50:b1e7:: with SMTP id n36mr119526656edd.227.1564746281042;
        Fri, 02 Aug 2019 04:44:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564746281; cv=none;
        d=google.com; s=arc-20160816;
        b=T2x+IBPDp6FKezfTWb2LIP2k73nK3xApB207h0gsk4pA7XE7qLLYQIdA6Kf4x5UB0a
         IdSVCOhP/zTV1ekwNcuLxdtdRyeM7uGdS5Qh6QBEyqfmYLBM0bryqFGbaf0u/aYLyq1h
         81TV+Tu6KmPYNNoCgGpSAYPQMpXqVFtJTOTv/PVc6Zf6Q6FEx1WZxMDtk+bg97m+4URT
         jQRK2n5re6ZS/axa88TcYef1rRjYpSNgCWHLGJAnZ39oGTREQxKxD1sUX5sax1EiY+M1
         utpRQysEsn3BOgLdOXFZafrmmGgfISuyLm7NvxHYfg7VcRXsOCZvys2WlwG8e6Wr4j2w
         7NLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M8TieNPi99QOG18so2PuFYh3e5+sQHpWy3chTWzm/rQ=;
        b=dkeiOrf7p9JGMz6HBoddo2xyxZbwrBAiVJN6hpGxsnlNY7o5na3Dh7Jdy1wqhAkDDK
         faQkRDiVMpAPsG25BG/QkNnhzgZj3pTOdlS9u0qYlv4XLozj7vI3ML6vJULGRSFL65Xe
         hOMNOT+GMzPsbNvyuSCTCboqc3Eo4vJ0zIUY24llvl/B5kkjqW2QvTK0o1BX1On97xYn
         n5B1dbECX4dxRK9HYuRTLa2i+qJJMfTzCj2isKD12lpDBOJ4ZSoOvgoxBDLq4JamVl2B
         FvB2TfnWcK8bV9riBUEBLVgPq6yOkTp+3o4M7/ihRpIYfUACVQIx7occOtbUffVdyevP
         QhMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k41si23980062eda.98.2019.08.02.04.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 04:44:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6FCAAADFC;
	Fri,  2 Aug 2019 11:44:40 +0000 (UTC)
Date: Fri, 2 Aug 2019 13:44:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190802114438.GH6461@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org>
 <20190729185509.GI9330@dhcp22.suse.cz>
 <20190802094028.GG6461@dhcp22.suse.cz>
 <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 13:01:07, Konstantin Khlebnikov wrote:
> 
> 
> On 02.08.2019 12:40, Michal Hocko wrote:
> > On Mon 29-07-19 20:55:09, Michal Hocko wrote:
> > > On Mon 29-07-19 11:49:52, Johannes Weiner wrote:
> > > > On Sun, Jul 28, 2019 at 03:29:38PM +0300, Konstantin Khlebnikov wrote:
> > > > > --- a/mm/gup.c
> > > > > +++ b/mm/gup.c
> > > > > @@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > > > >   			ret = -ERESTARTSYS;
> > > > >   			goto out;
> > > > >   		}
> > > > > -		cond_resched();
> > > > > +		/* Reclaim memory over high limit before stocking too much */
> > > > > +		mem_cgroup_handle_over_high(true);
> > > > 
> > > > I'd rather this remained part of the try_charge() call. The code
> > > > comment in try_charge says this:
> > > > 
> > > > 	 * We can perform reclaim here if __GFP_RECLAIM but let's
> > > > 	 * always punt for simplicity and so that GFP_KERNEL can
> > > > 	 * consistently be used during reclaim.
> > > > 
> > > > The simplicity argument doesn't hold true anymore once we have to add
> > > > manual calls into allocation sites. We should instead fix try_charge()
> > > > to do synchronous reclaim for __GFP_RECLAIM and only punt to userspace
> > > > return when actually needed.
> > > 
> > > Agreed. If we want to do direct reclaim on the high limit breach then it
> > > should go into try_charge same way we do hard limit reclaim there. I am
> > > not yet sure about how/whether to scale the excess. The only reason to
> > > move reclaim to return-to-userspace path was GFP_NOWAIT charges. As you
> > > say, maybe we should start by always performing the reclaim for
> > > sleepable contexts first and only defer for non-sleeping requests.
> > 
> > In other words. Something like patch below (completely untested). Could
> > you give it a try Konstantin?
> 
> This should work but also eliminate all benefits from deferred reclaim:
> bigger batching and running without of any locks.

Yes, but we already have to deal with for hard limit reclaim. Also I
would like to see any actual data to back any more complex solution.
We should definitely start simple.

> After that gap between high and max will work just as reserve for atomic allocations.
> 
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ba9138a4a1de..53a35c526e43 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >   				schedule_work(&memcg->high_work);
> >   				break;
> >   			}
> > -			current->memcg_nr_pages_over_high += batch;
> > -			set_notify_resume(current);
> > +			if (gfpflags_allow_blocking(gfp_mask)) {
> > +				reclaim_high(memcg, nr_pages, GFP_KERNEL);

ups, this should be s@GFP_KERNEL@gfp_mask@

> > +			} else {
> > +				current->memcg_nr_pages_over_high += batch;
> > +				set_notify_resume(current);
> > +			}
> >   			break;
> >   		}
> >   	} while ((memcg = parent_mem_cgroup(memcg)));
> > 

-- 
Michal Hocko
SUSE Labs

