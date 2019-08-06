Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80132C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 113892070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:27:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 113892070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A5C6B0003; Tue,  6 Aug 2019 08:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E3B16B0005; Tue,  6 Aug 2019 08:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 684FE6B0006; Tue,  6 Aug 2019 08:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4178C6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:27:59 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 41so72899669qtm.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:27:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pX46rPlyDOkLMOPTQspppEkXuhmoJ8IczFHKTJbxoCc=;
        b=Ody5GDiVaKVepj7jv7arpqsgNMk+2X0D/uA5rzdnhH3nZsEGs9t2D5LJ7qbljokb7P
         yu0tuyvRinUfN+pdL3phd3sa+Vo0diaR13KsnBxELV4wkPusNKR/5uOhmvcYAMfBwahd
         tvDUp/PwIHHoIYue6wwXe9V0kgyjsUOlQr7EC7QyCKWlR4omnmtLq+8zULhVjYQ8rOPK
         uynw1opzr/eL6Lvu9NlQvFQpy4HvLgaBfocp7mKpTMcDwy1cooz0LDYm8CQPt6I81MFI
         7oFbNO8f9y/+kvWLl7LkaH6xUWvM+XQ57n5lrHl3CNAYD4DoXNvN6gZepjQQp0FIWE0j
         lVSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVql6Jwq0MUjLkpdtVaVtf2ROTiUvBLEQFPD968Z5sldfwVB7Ji
	fTOjOsPlZSB9Zm1rXu28uHVAoY2ix+W3Pgbizbqu6AZUXTg4gIzdwNRTYRRUSYTlOnL+oPljmPB
	xDOpRFRqRFF99Fv1Hj6fNOzZ/wAoEDWWZVv0FubPBUJQHFZ3BgSvEHYCyNuxms3hd4g==
X-Received: by 2002:a0c:8690:: with SMTP id 16mr2786877qvf.228.1565094478994;
        Tue, 06 Aug 2019 05:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwedsgUcV6ETSdoM7209TmMXkVksXvl6v1bMR7jNG1ylVmSeXWvUtWCq0GAMX5mhozLdsn6
X-Received: by 2002:a0c:8690:: with SMTP id 16mr2786817qvf.228.1565094478150;
        Tue, 06 Aug 2019 05:27:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565094478; cv=none;
        d=google.com; s=arc-20160816;
        b=H9gbqTsG7FUVrdMmvKn+Q70m/keC/ctNOUYtwDlLW43+q0gY31FJLQICsRU2rGw3LO
         n/SKJEccptyOVeqF40ICsb9h1vTmwN62zYcDwoI6Mp/6Ege8iXkNzdWQDhttk7JWeMvQ
         CqIAhxeyeFGwDT+ffyQTtr9YO6no8ad4LcRMUb98vQfsyFN3FoVJ1cjD7eq1s4y3yu84
         Fo18yCaVjj9k13l4ZHXU4em0E1kiA5lvD2mXiqLpBYlH1N6l6vbIqLgpWZJnCwtevKxa
         MLKhQsyU10WM5x+kO1mlelEjalnckbOR4kA/dMM5ciVUPze4YLt+anKJ6o5PJqCnKkrK
         kzWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pX46rPlyDOkLMOPTQspppEkXuhmoJ8IczFHKTJbxoCc=;
        b=CPkd3FyuzoEYTw+Hdm06Piqhvr3n/JS4lIFDV5j/iso8x1WFfoamrWij2UJpHlVd+q
         HEITbpJyyh2+fwW5A8splBkSsZVblaO122kgNvTcMBEQOiwFus1y9OYUw3qEXPCrz6dC
         +ajAFi9C7L4kVaH5Van/+TGlE5JF08VsZBjOFNcYShSVwYPYyBL5HzadRpMQMp+Ahgoo
         a9UXfpdDIaCa9aGrfvDm9H5ROBN2RZmXeQR95xfmQ7kopDY5fPVThcfIizl3u/BUjE2c
         KhnRShz2Qs8+7i6HjqKaMirW75nd7wrQVuhWe+bL3kdikMn2jz0kqYZK0jpEoNsf0vog
         HTvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t62si47954935qkh.89.2019.08.06.05.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 05:27:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1E0F730B9BE0;
	Tue,  6 Aug 2019 12:27:57 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7CA8861140;
	Tue,  6 Aug 2019 12:27:56 +0000 (UTC)
Date: Tue, 6 Aug 2019 08:27:54 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190806122754.GA2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
 <20190804014930.GR7777@dread.disaster.area>
 <20190805174226.GB14760@bfoster>
 <20190805234318.GB7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805234318.GB7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 06 Aug 2019 12:27:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:43:18AM +1000, Dave Chinner wrote:
> On Mon, Aug 05, 2019 at 01:42:26PM -0400, Brian Foster wrote:
> > On Sun, Aug 04, 2019 at 11:49:30AM +1000, Dave Chinner wrote:
> > > On Fri, Aug 02, 2019 at 11:27:09AM -0400, Brian Foster wrote:
> > > > On Thu, Aug 01, 2019 at 12:17:29PM +1000, Dave Chinner wrote:
> > > > >  };
> > > > >  
> > > > >  #define SHRINK_STOP (~0UL)
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index 44df66a98f2a..ae3035fe94bc 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > > > >  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> > > > >  				   freeable, delta, total_scan, priority);
> > > > >  
> > > > > +	/*
> > > > > +	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> > > > > +	 * defer the work to a context that can scan the cache.
> > > > > +	 */
> > > > > +	if (shrinkctl->will_defer)
> > > > > +		goto done;
> > > > > +
> > > > 
> > > > Who's responsible for clearing the flag? Perhaps we should do so here
> > > > once it's acted upon since we don't call into the shrinker again?
> > > 
> > > Each shrinker invocation has it's own shrink_control context - they
> > > are not shared between shrinkers - the higher level is responsible
> > > for setting up the control state of each individual shrinker
> > > invocation...
> > > 
> > 
> > Yes, but more specifically, it appears to me that each level is
> > responsible for setting up control state managed by that level. E.g.,
> > shrink_slab_memcg() initializes the unchanging state per iteration and
> > do_shrink_slab() (re)sets the scan state prior to ->scan_objects().
> 
> do_shrink_slab() is responsible for iterating the scan in
> shrinker->batch sizes, that's all it's doing there. We have to do
> some accounting work from scan to scan. However, if ->will_defer is
> set, we skip that entire loop, so it's largely irrelevant IMO.
> 

The point is very simply that there are scenarios where ->will_defer
might be true or might be false on do_shrink_slab() entry and I'm just
noting it as a potential landmine. It's not a bug in the current code
from what I can tell. I can't imagine why we wouldn't just reset the
flag prior to the ->count_objects() call, but alas I'm not a maintainer
of this code so I'll leave it to other reviewers/maintainers at this
point..

> > > > Granted the deferred state likely hasn't
> > > > changed, but the fact that we'd call back into the count callback to set
> > > > it again implies the logic could be a bit more explicit, particularly if
> > > > this will eventually be used for more dynamic shrinker state that might
> > > > change call to call (i.e., object dirty state, etc.).
> > > > 
> > > > BTW, do we need to care about the ->nr_cached_objects() call from the
> > > > generic superblock shrinker (super_cache_scan())?
> > > 
> > > No, and we never had to because it is inside the superblock shrinker
> > > and the superblock shrinker does the GFP_NOFS context checks.
> > > 
> > 
> > Ok. Though tbh this topic has me wondering whether a shrink_control
> > boolean is the right approach here. Do you envision ->will_defer being
> > used for anything other than allocation context restrictions? If not,
> 
> Not at this point. If there are other control flags needed, we can
> ad them in future - I don't like the idea of having a single control
> flag mean different things in different contexts.
> 

I don't think we're talking about the same thing here..

> > perhaps we should do something like optionally set alloc flags required
> > for direct scanning in the struct shrinker itself and let the core
> > shrinker code decide when to defer to kswapd based on the shrink_control
> > flags and the current shrinker. That way an arbitrary shrinker can't
> > muck around with core behavior in unintended ways. Hm?
> 
> Arbitrary shrinkers can't "muck about" with the core behaviour any
> more than they already could with this code. If you want to screw up
> the core reclaim by always returning SHRINK_STOP to ->scan_objects
> instead of doing work, then there is nothing stopping you from doing
> that right now. Formalising there work deferral into a flag in the
> shrink_control doesn't really change that at all, adn as such I
> don't see any need for over-complicating the mechanism here....
> 

If you add a generic "defer work" knob to the shrinker mechanism, but
only process it as an "allocation context" check, I expect it could be
easily misused. For example, some shrinkers may decide to set the the
flag dynamically based on in-core state. This will work when called from
some contexts but not from others (unrelated to allocation context),
which is confusing. Therefore, what I'm saying is that if the only
current use case is to defer work from shrinkers that currently skip
work due to allocation context restraints, this might be better codified
with something like the appended (untested) example patch. This may or
may not be a preferable interface to the flag, but it's certainly not an
overcomplication...

Brian

--- 8< ---

diff --git a/fs/super.c b/fs/super.c
index 113c58f19425..4e05ed9d6154 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -69,13 +69,6 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
-	/*
-	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
-	 * to recurse into the FS that called us in clear_inode() and friends..
-	 */
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
-
 	if (!trylock_super(sb))
 		return SHRINK_STOP;
 
@@ -264,6 +257,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
 	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
+	s->s_shrink.direct_mask = __GFP_FS;
 	if (prealloc_shrinker(&s->s_shrink))
 		goto fail;
 	if (list_lru_init_memcg(&s->s_dentry_lru, &s->s_shrink))
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..e94e4edf7f1e 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -75,6 +75,8 @@ struct shrinker {
 #endif
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
+
+	gfp_t	direct_mask;
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44df66a98f2a..fb339399e26a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -541,6 +541,15 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
 				   freeable, delta, total_scan, priority);
 
+	/*
+	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
+	 * defer the work to a context that can scan the cache.
+	 */
+	if (shrinker->direct_mask &&
+	    ((shrinkctl->gfp_mask & shrinker->direct_mask) !=
+	     shrinker->direct_mask))
+		goto done;
+
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
 	 * pass to avoid too frequent shrinker calls, but if the slab has less
@@ -575,6 +584,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		cond_resched();
 	}
 
+done:
 	if (next_deferred >= scanned)
 		next_deferred -= scanned;
 	else

