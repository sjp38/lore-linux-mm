Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71045C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:44:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B34F214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:44:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B34F214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 912746B0005; Mon,  5 Aug 2019 19:44:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C2036B0006; Mon,  5 Aug 2019 19:44:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 789756B0007; Mon,  5 Aug 2019 19:44:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42AD36B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 19:44:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l11so32285440pgc.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 16:44:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lWW1dmxxFQh7gGH6yVC1gV0WBVuze8wWX2eBub4kRoU=;
        b=Sb2aFX1Mk1mEOssIFBZZ6Jyh6eXGNFtDlY26cMxTkBGXEXD19lIWw34FJikjfMojIx
         h4HNsZd+BI2z9f8gUFL4ilDswwAOxPqoUxMdcxo+B9Tbd+kk5mmVMPxZvjim0aG6V9ER
         9ruy1vuxF4cvh9F9u8kVv4T0ahkAINnsOR1GCzqBDzCNEnI3bvTfNDNRO67x3Plh0jKF
         9j+3xtoLJRLoivFRc53ucKEvnc6T1s3P6TU/gqRcOLva3QprMOSXYVBuS4gZmGUB1WXK
         iJpOmHV8iN8bgISTqh96gIdtj9DsV8Z1gr1PklfWLlYRk8RKwZBnhT9cvRmYsa+/iAED
         PrlQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXiNe2i9PWLDDR5pIZLoOgsLk6GZRI3jjoq0cC/G6NjgqYpTIoY
	tYu3kTTAktT3ydPgNtHEPzPrLflVob6dUkmkRz14QzET7LtwkoPsri+oY/uNBxy8VKAfOlo4N2R
	MphyrzWgDibSOvtHqudOMPt1ykmwyheZPITEC57Bb99fbRyaVxBIm3k7MR6PVWW8=
X-Received: by 2002:a62:fb18:: with SMTP id x24mr511058pfm.231.1565048667894;
        Mon, 05 Aug 2019 16:44:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxCF812B/aIrn2brbR/+25uVkqfDNOXL77AmSHh//xsWjuEtOhx7T9375JnXYnsw3x5ofx
X-Received: by 2002:a62:fb18:: with SMTP id x24mr511013pfm.231.1565048667052;
        Mon, 05 Aug 2019 16:44:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565048667; cv=none;
        d=google.com; s=arc-20160816;
        b=VD0jb2LK7n+zYcM0hvFUoCG8NzkE7dC6ylrsrYQvvymL+ogYzUH+hSotA+jFjNGg2s
         iQIGcdq0tefkkwYDj+6oX0IhSoAlweM2rLzmnDsSZH8N0Ulcvz/ZV6jlIm82t78mO1rX
         ZMeCmakZIA1mY2G8J/++9WPWcLPcLLUDc+nGEz92Say5gCp/kPpYgF0rrTRdbRO6Jw+Q
         Ap9n3Una+FzEyrnkdoo69/eyPYFeVVsQ5B8TbU49DN74fwsuQSTsTPETusfQx3OJw5BJ
         ywp/ooSagDizc9TLU2lfhKOuPMMcZhyDeZGFjyFWvt2l/sWP7GEHLsF6xoOfBFA6Jt1r
         TiEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lWW1dmxxFQh7gGH6yVC1gV0WBVuze8wWX2eBub4kRoU=;
        b=KcLJxXDCjg4kOymVT0q9h5YlJFp73+M1nqXovR+kwdlEMr4Q42E5P9NFjAfWDRIfUa
         3xtxIUoLcdXSwFRD6QGx3Y1yFuZWylPncPx4Nf09S7r5dmkOg5ehINlhnPMqvZdK37Il
         MPlrm2l21H2xjuwDlkc5iuqemCeXU0wrCh3Fo5VSOfDlKrm+/DHjAjSTeJ31XqLbPLa8
         SNQg8SUN1eCR0WPwJZzgS5PyftCg17AZ2NWw8LYeT+HglHfwdvtF+0cmYJNbYDTwaJp1
         EpkDpsh31F4ZPX1id1xHHFQ/9WbmOMVejiBznKJrVztdQUxLjhITTuGEKuTwkv2fod7t
         +VPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id h15si42877823plk.74.2019.08.05.16.44.26
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 16:44:27 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id A3BB62AD77D;
	Tue,  6 Aug 2019 09:44:25 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1humdK-0005Pq-DQ; Tue, 06 Aug 2019 09:43:18 +1000
Date: Tue, 6 Aug 2019 09:43:18 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190805234318.GB7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
 <20190804014930.GR7777@dread.disaster.area>
 <20190805174226.GB14760@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805174226.GB14760@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=5k_VAZaAQOqSGc2ktcMA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 01:42:26PM -0400, Brian Foster wrote:
> On Sun, Aug 04, 2019 at 11:49:30AM +1000, Dave Chinner wrote:
> > On Fri, Aug 02, 2019 at 11:27:09AM -0400, Brian Foster wrote:
> > > On Thu, Aug 01, 2019 at 12:17:29PM +1000, Dave Chinner wrote:
> > > >  };
> > > >  
> > > >  #define SHRINK_STOP (~0UL)
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 44df66a98f2a..ae3035fe94bc 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > > >  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> > > >  				   freeable, delta, total_scan, priority);
> > > >  
> > > > +	/*
> > > > +	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> > > > +	 * defer the work to a context that can scan the cache.
> > > > +	 */
> > > > +	if (shrinkctl->will_defer)
> > > > +		goto done;
> > > > +
> > > 
> > > Who's responsible for clearing the flag? Perhaps we should do so here
> > > once it's acted upon since we don't call into the shrinker again?
> > 
> > Each shrinker invocation has it's own shrink_control context - they
> > are not shared between shrinkers - the higher level is responsible
> > for setting up the control state of each individual shrinker
> > invocation...
> > 
> 
> Yes, but more specifically, it appears to me that each level is
> responsible for setting up control state managed by that level. E.g.,
> shrink_slab_memcg() initializes the unchanging state per iteration and
> do_shrink_slab() (re)sets the scan state prior to ->scan_objects().

do_shrink_slab() is responsible for iterating the scan in
shrinker->batch sizes, that's all it's doing there. We have to do
some accounting work from scan to scan. However, if ->will_defer is
set, we skip that entire loop, so it's largely irrelevant IMO.

> > > Granted the deferred state likely hasn't
> > > changed, but the fact that we'd call back into the count callback to set
> > > it again implies the logic could be a bit more explicit, particularly if
> > > this will eventually be used for more dynamic shrinker state that might
> > > change call to call (i.e., object dirty state, etc.).
> > > 
> > > BTW, do we need to care about the ->nr_cached_objects() call from the
> > > generic superblock shrinker (super_cache_scan())?
> > 
> > No, and we never had to because it is inside the superblock shrinker
> > and the superblock shrinker does the GFP_NOFS context checks.
> > 
> 
> Ok. Though tbh this topic has me wondering whether a shrink_control
> boolean is the right approach here. Do you envision ->will_defer being
> used for anything other than allocation context restrictions? If not,

Not at this point. If there are other control flags needed, we can
ad them in future - I don't like the idea of having a single control
flag mean different things in different contexts.

> perhaps we should do something like optionally set alloc flags required
> for direct scanning in the struct shrinker itself and let the core
> shrinker code decide when to defer to kswapd based on the shrink_control
> flags and the current shrinker. That way an arbitrary shrinker can't
> muck around with core behavior in unintended ways. Hm?

Arbitrary shrinkers can't "muck about" with the core behaviour any
more than they already could with this code. If you want to screw up
the core reclaim by always returning SHRINK_STOP to ->scan_objects
instead of doing work, then there is nothing stopping you from doing
that right now. Formalising there work deferral into a flag in the
shrink_control doesn't really change that at all, adn as such I
don't see any need for over-complicating the mechanism here....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

