Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98F36C31E40
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 01:50:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3466F21726
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 01:50:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3466F21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75E276B0003; Sat,  3 Aug 2019 21:50:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F576B0005; Sat,  3 Aug 2019 21:50:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64BB96B0006; Sat,  3 Aug 2019 21:50:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9DA6B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 21:50:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y22so44000991plr.20
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 18:50:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=W/9H9uoV7Tmop3U9XL+VQlfLV/+be4qnSCW9EPR5k+8=;
        b=BgrHee2Jr3DHrbf/iIesmjLDfnnIGm/zGCQK6T0Cj/JAwYYJ+I2qlJaL+SZ8n585fd
         OIQXTHLtgQjk3B0IcFMR6LqdKB6XlSfFu0v8ZlQyCWoVim4gyV362BGtBF+7ME/dwzae
         8UffT25fHp2o4dKwF+J0m8E1ngNsJFstMBOjs9B+Y005lvP8loXJdtcbk36gQBUTGknX
         NRarTtAhUxsZN/bpgGvRhjcxp45XRcbn0WJxhOBAr2m+PO43XHyQk51+rnRfaHN63u2b
         ZbFbQuP3xxFwYFBtXC7kIZ8+ldCDrdQaYVDTuegnQ/EpdaXGoUU27DmdLmM8S54Ciw+0
         X5mw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXpD4Q4EaWETeYwNhXRdEZQBVMuX73jDzyVySUrRITW+tx2VXQW
	hbM8LSmNL7M4Ggah1vtEDhQXIntNFva0OicLCidrjlZuh/hxtJHDKJSV56tSzhTXAshcTpVkXqi
	WSjU5HV6ckDR7AABftPalpTAkTO7OK4FTc7avGskNY5zvJkQTF7/P5NASm2h8NDY=
X-Received: by 2002:a65:6497:: with SMTP id e23mr125967193pgv.89.1564883441669;
        Sat, 03 Aug 2019 18:50:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDRz5AuhcxU2D+rOVCTpiORHMaGRGCFSY0K4s4BcHF9g/C5Kc6HWOVbUDYQgXvs8Xj4BdT
X-Received: by 2002:a65:6497:: with SMTP id e23mr125967123pgv.89.1564883440529;
        Sat, 03 Aug 2019 18:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564883440; cv=none;
        d=google.com; s=arc-20160816;
        b=lk2EB0vRPGMMXFTiBKNs1M2De0BfY5/zKBo/ystcp/sZXEREkT/RUpZLcp6Kds1rsb
         YIXiZlApS8/FAoPWRqqPGE1sij1r3dabPQMlLqJNLAGIFsQICSxWBLgTluoQrkX5JslG
         fuQ1vgQXv55qdE6hhzHzjNpiNAnSMh6Q4hUT78jTEMbX1ckHYCMOQGp4F07DPbfwXoVq
         X251iODFJ+g8AudD0bovJ1fvZXmT9tQZHwmPGxtbwRaxvYuGRCvWzQSos/16RC7DiB50
         Ih/8cIomGIMadNVcik50LYXSiwyVPLtS38gWLF8Lb7vEfUW9HDNVUFUHHT1ZRSswL4Rc
         2ykA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=W/9H9uoV7Tmop3U9XL+VQlfLV/+be4qnSCW9EPR5k+8=;
        b=hkNFlAwSyqoM7IdTf36NQJjKXxaNJS1ezgAvBt43uTR3uq0uqbA5kEvWz57Q3IVNaT
         A/Ok4pa8ghao+6ozobDSNet351+Oz6Y+L1KGlZxCMHrbCSgarWfhfWQrr2rJ0DxBokUp
         jopm7k/W87uQTlJu5qhcEE6IxZVZaZauE86d7r0/tInNT+OKuJsqbGlfDjChRrpYiR07
         qfm51UzJbyxuqIIoxqaehvdjjl76OWTweBjbLWa8nzAG2nRaGFKW0tHuv0cKk+s4rf/k
         cHtQ/GMNjK7NU2QRT3Br0YgddGUHk0lXpDxMyQdYAEXScO8Bow8E96WHf1qY9kKefOSP
         63aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id a21si40623694pfo.249.2019.08.03.18.50.39
        for <linux-mm@kvack.org>;
        Sat, 03 Aug 2019 18:50:40 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id E5CE8364280;
	Sun,  4 Aug 2019 11:50:37 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hu5eM-00054o-Fl; Sun, 04 Aug 2019 11:49:30 +1000
Date: Sun, 4 Aug 2019 11:49:30 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190804014930.GR7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802152709.GA60893@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=BosphLL6vozEvtcKRvYA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 11:27:09AM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:29PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Introduce a mechanism for ->count_objects() to indicate to the
> > shrinker infrastructure that the reclaim context will not allow
> > scanning work to be done and so the work it decides is necessary
> > needs to be deferred.
> > 
> > This simplifies the code by separating out the accounting of
> > deferred work from the actual doing of the work, and allows better
> > decisions to be made by the shrinekr control logic on what action it
> > can take.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  include/linux/shrinker.h | 7 +++++++
> >  mm/vmscan.c              | 8 ++++++++
> >  2 files changed, 15 insertions(+)
> > 
> > diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> > index 9443cafd1969..af78c475fc32 100644
> > --- a/include/linux/shrinker.h
> > +++ b/include/linux/shrinker.h
> > @@ -31,6 +31,13 @@ struct shrink_control {
> >  
> >  	/* current memcg being shrunk (for memcg aware shrinkers) */
> >  	struct mem_cgroup *memcg;
> > +
> > +	/*
> > +	 * set by ->count_objects if reclaim context prevents reclaim from
> > +	 * occurring. This allows the shrinker to immediately defer all the
> > +	 * work and not even attempt to scan the cache.
> > +	 */
> > +	bool will_defer;
> 
> Functionality wise this seems fairly straightforward. FWIW, I find the
> 'will_defer' name a little confusing because it implies to me that the
> shrinker is telling the caller about something it would do if called as
> opposed to explicitly telling the caller to defer. I'd just call it
> 'defer' I guess, but that's just my .02. ;P

Ok, I'll change it to something like "defer_work" or "defer_scan"
here.

> >  };
> >  
> >  #define SHRINK_STOP (~0UL)
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 44df66a98f2a..ae3035fe94bc 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> >  				   freeable, delta, total_scan, priority);
> >  
> > +	/*
> > +	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> > +	 * defer the work to a context that can scan the cache.
> > +	 */
> > +	if (shrinkctl->will_defer)
> > +		goto done;
> > +
> 
> Who's responsible for clearing the flag? Perhaps we should do so here
> once it's acted upon since we don't call into the shrinker again?

Each shrinker invocation has it's own shrink_control context - they
are not shared between shrinkers - the higher level is responsible
for setting up the control state of each individual shrinker
invocation...

> Note that I see this structure is reinitialized on every iteration in
> the caller, but there already is the SHRINK_EMPTY case where we call
> back into do_shrink_slab().

.... because there is external state tracking in memcgs that
determine what shrinkers get run. See shrink_slab_memcg().

i.e. The SHRINK_EMPTY return value is a special hack for memcg
shrinkers so it can track whether there are freeable objects in the
cache externally to try to avoid calling into shrinkers where no
work can be done.  Think about having hundreds of shrinkers and
hundreds of memcgs...

Anyway, the tracking of the freeable bit is racy, so the
SHRINK_EMPTY hack where it clears the bit and calls back into the
shrinker is handling the case where objects were freed between the
shrinker running and shrink_slab_memcg() clearing the freeable bit
from the slab. Hence it has to call back into the shrinker again -
if it gets anything other than SHRINK_EMPTY returned, then it will
set the bit again.

In reality, SHRINK_EMPTY and deferring work are mutually exclusive.
Work only gets deferred when there's work that can be done and in
that case SHRINK_EMPTY will not be returned - a value of "0 freed
objects" will be returned when we defer work. So if the first call
returns SHRINK_EMPTY, the "defer" state has not been touched and
so doesn't require resetting to zero here.

> Granted the deferred state likely hasn't
> changed, but the fact that we'd call back into the count callback to set
> it again implies the logic could be a bit more explicit, particularly if
> this will eventually be used for more dynamic shrinker state that might
> change call to call (i.e., object dirty state, etc.).
> 
> BTW, do we need to care about the ->nr_cached_objects() call from the
> generic superblock shrinker (super_cache_scan())?

No, and we never had to because it is inside the superblock shrinker
and the superblock shrinker does the GFP_NOFS context checks.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

