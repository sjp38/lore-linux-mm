Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 019FBC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AECF620B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:42:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AECF620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 453CB6B0005; Mon,  5 Aug 2019 13:42:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DDD46B0006; Mon,  5 Aug 2019 13:42:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27DB06B0007; Mon,  5 Aug 2019 13:42:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2DE66B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:42:30 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x7so76416007qtp.15
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:42:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gaAKAhiSBRG528a5JejX/fN+ANvOR4XI4/d224s5stI=;
        b=c8qvuemfZdHf0JB9r+sySfqjNXavD2mO1UYuLsbRGL+kucBT3QtlazeOMO/2BoqGtx
         mmGOUfMINHdPfi2dq+FJjXRpoS3/zS/zLnmY072KmV6JGLLBrnv18ClmfQPBzXbSWxdK
         V0lzqmVTGSEpVw+E0eszOg2tk5gQobqxu+rKNT/Etsz646q4t1XgLZTmn7lGi1ppeYCC
         aI9gGg+TfPnpWIvpSJukjjGRkxauMKg8uE3XjaW1vwTfYh4FI9Cf/PMAZ2L8Uli+Hm6m
         6FXNrkrB90A63rt0ocFgT18q6IriCUQjFeWOxuH5bSJL5zXKiZf1Es69gmE0nbxDNLit
         gjEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTjX/uBw4si3AIRXy66bmK/4zndsvi1Me6z1r6TDnseKx7HI5G
	U8xn9HK+hEWulLl+wqWJ5r8uKsamd2ixU2b1BQjrpdSg6gbKfk60HgyG07Lc/9T/gx+bmZcpRww
	uzYcaxEwZumA38ngPGIh3zPgGPd78zgN5fgbMtV+3GJ/CpOPdBxh/r3EZgkwMp4ZrbQ==
X-Received: by 2002:a37:7d1:: with SMTP id 200mr100077982qkh.96.1565026950737;
        Mon, 05 Aug 2019 10:42:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLLE9x9hjIKBj14U4w+awIevuweQHyLUQRkgDqKTMH0BWBnmjy87plg417c2C/6kOFeg4/
X-Received: by 2002:a37:7d1:: with SMTP id 200mr100077934qkh.96.1565026949905;
        Mon, 05 Aug 2019 10:42:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565026949; cv=none;
        d=google.com; s=arc-20160816;
        b=MAZHZzgfRtX7DxAqCcfENvyMtaZvGc+gEnWZ44Tgwf3wv4SNGAzo5W+pNaCT9ZSrLs
         Mvln7kzdf+xdEzvV7w2whcPjX3dyx9D5Pju2JTcvMtk7SGX8xFTisNBz6k6Shir7+5mE
         C1pEDpwgaogqo+LP5MifAOvyoVsJzLzOyvwORqeO/C3l4HkWp/w1ChNiQLshI6ixgmoF
         YVrEmZBsxr9y/STzpMWva1CUqZWTWyUAFDNks+7Jix3dyRSJ/hwpWlmSlguJwPylze/2
         VjRWYlioQ0SkHMCyvwaZ/GF4A9P/mxOgs21df/IEZtMV+KjWQVlXGFu8MFqvYJGqsQMR
         OIMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gaAKAhiSBRG528a5JejX/fN+ANvOR4XI4/d224s5stI=;
        b=Bto945UahwEOfFttQnM2+NNKlPyr29TVMbYs1+881Oz7oBwXNZaEn4x8qZ8H+ojXaJ
         cwS3IehlFbw8W1dcEHiA/10cGho8pqPOUangHWu77OTToYMp8kt3v0hik6GOCmV/OsUZ
         ApiwuBiz+/QSFkNf+NJZ6PMpgiHaYgQx/MmTtmd4T510ybppdNwcpB/i+tls1dsv/s+M
         3nEjMdKvyzwTwitxN1XeT+p0RJZL2M2IdXY5fA1SHxWKHuYDz+/oN21m5dtGPXaMjTjL
         /0coxZd0cY1OCmYfkOwXzgZYKfPW6tHZN6KlQtrVij2qX79n9dzlLPUHlxF6nfN3t93w
         IsIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x17si36569275qkf.236.2019.08.05.10.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 10:42:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 24AF2300676E;
	Mon,  5 Aug 2019 17:42:29 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 929BE5C1D4;
	Mon,  5 Aug 2019 17:42:28 +0000 (UTC)
Date: Mon, 5 Aug 2019 13:42:26 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190805174226.GB14760@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
 <20190804014930.GR7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804014930.GR7777@dread.disaster.area>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 05 Aug 2019 17:42:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 11:49:30AM +1000, Dave Chinner wrote:
> On Fri, Aug 02, 2019 at 11:27:09AM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:29PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > Introduce a mechanism for ->count_objects() to indicate to the
> > > shrinker infrastructure that the reclaim context will not allow
> > > scanning work to be done and so the work it decides is necessary
> > > needs to be deferred.
> > > 
> > > This simplifies the code by separating out the accounting of
> > > deferred work from the actual doing of the work, and allows better
> > > decisions to be made by the shrinekr control logic on what action it
> > > can take.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  include/linux/shrinker.h | 7 +++++++
> > >  mm/vmscan.c              | 8 ++++++++
> > >  2 files changed, 15 insertions(+)
> > > 
> > > diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> > > index 9443cafd1969..af78c475fc32 100644
> > > --- a/include/linux/shrinker.h
> > > +++ b/include/linux/shrinker.h
> > > @@ -31,6 +31,13 @@ struct shrink_control {
> > >  
> > >  	/* current memcg being shrunk (for memcg aware shrinkers) */
> > >  	struct mem_cgroup *memcg;
> > > +
> > > +	/*
> > > +	 * set by ->count_objects if reclaim context prevents reclaim from
> > > +	 * occurring. This allows the shrinker to immediately defer all the
> > > +	 * work and not even attempt to scan the cache.
> > > +	 */
> > > +	bool will_defer;
> > 
> > Functionality wise this seems fairly straightforward. FWIW, I find the
> > 'will_defer' name a little confusing because it implies to me that the
> > shrinker is telling the caller about something it would do if called as
> > opposed to explicitly telling the caller to defer. I'd just call it
> > 'defer' I guess, but that's just my .02. ;P
> 
> Ok, I'll change it to something like "defer_work" or "defer_scan"
> here.
> 

Either sounds better to me, thanks.

> > >  };
> > >  
> > >  #define SHRINK_STOP (~0UL)
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 44df66a98f2a..ae3035fe94bc 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > >  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> > >  				   freeable, delta, total_scan, priority);
> > >  
> > > +	/*
> > > +	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> > > +	 * defer the work to a context that can scan the cache.
> > > +	 */
> > > +	if (shrinkctl->will_defer)
> > > +		goto done;
> > > +
> > 
> > Who's responsible for clearing the flag? Perhaps we should do so here
> > once it's acted upon since we don't call into the shrinker again?
> 
> Each shrinker invocation has it's own shrink_control context - they
> are not shared between shrinkers - the higher level is responsible
> for setting up the control state of each individual shrinker
> invocation...
> 

Yes, but more specifically, it appears to me that each level is
responsible for setting up control state managed by that level. E.g.,
shrink_slab_memcg() initializes the unchanging state per iteration and
do_shrink_slab() (re)sets the scan state prior to ->scan_objects().

> > Note that I see this structure is reinitialized on every iteration in
> > the caller, but there already is the SHRINK_EMPTY case where we call
> > back into do_shrink_slab().
> 
> .... because there is external state tracking in memcgs that
> determine what shrinkers get run. See shrink_slab_memcg().
> 
> i.e. The SHRINK_EMPTY return value is a special hack for memcg
> shrinkers so it can track whether there are freeable objects in the
> cache externally to try to avoid calling into shrinkers where no
> work can be done.  Think about having hundreds of shrinkers and
> hundreds of memcgs...
> 
> Anyway, the tracking of the freeable bit is racy, so the
> SHRINK_EMPTY hack where it clears the bit and calls back into the
> shrinker is handling the case where objects were freed between the
> shrinker running and shrink_slab_memcg() clearing the freeable bit
> from the slab. Hence it has to call back into the shrinker again -
> if it gets anything other than SHRINK_EMPTY returned, then it will
> set the bit again.
> 

Yeah, I grokked most of that from the code. The current implementation
looks fine to me, but I could easily see how changes in the higher level
do_shrink_slab() caller(s) or lower level shrinker callbacks could
quietly break this in the future. IOW, once this code hits the tree any
shrinker across the kernel is free to try and defer slab reclaim work
for any reason.

> In reality, SHRINK_EMPTY and deferring work are mutually exclusive.
> Work only gets deferred when there's work that can be done and in
> that case SHRINK_EMPTY will not be returned - a value of "0 freed
> objects" will be returned when we defer work. So if the first call
> returns SHRINK_EMPTY, the "defer" state has not been touched and
> so doesn't require resetting to zero here.
> 

Yep. The high level semantics make sense, but note that that the generic
superblock shrinker can now set ->will_defer true and return
SHRINK_EMPTY so that last bit about defer state not being touched is not
technically true.

> > Granted the deferred state likely hasn't
> > changed, but the fact that we'd call back into the count callback to set
> > it again implies the logic could be a bit more explicit, particularly if
> > this will eventually be used for more dynamic shrinker state that might
> > change call to call (i.e., object dirty state, etc.).
> > 
> > BTW, do we need to care about the ->nr_cached_objects() call from the
> > generic superblock shrinker (super_cache_scan())?
> 
> No, and we never had to because it is inside the superblock shrinker
> and the superblock shrinker does the GFP_NOFS context checks.
> 

Ok. Though tbh this topic has me wondering whether a shrink_control
boolean is the right approach here. Do you envision ->will_defer being
used for anything other than allocation context restrictions? If not,
perhaps we should do something like optionally set alloc flags required
for direct scanning in the struct shrinker itself and let the core
shrinker code decide when to defer to kswapd based on the shrink_control
flags and the current shrinker. That way an arbitrary shrinker can't
muck around with core behavior in unintended ways. Hm?

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

