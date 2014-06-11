Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 078906B0163
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:14:31 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so4787588wes.21
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:14:31 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id dy5si22687821wib.52.2014.06.11.09.14.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 09:14:30 -0700 (PDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so5341486wgg.29
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:14:29 -0700 (PDT)
Date: Wed, 11 Jun 2014 18:14:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, memcg: allow OOM if no memcg is eligible during
 direct reclaim
Message-ID: <20140611161425.GC23343@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <20140611152030.GB22516@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611152030.GB22516@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 11-06-14 11:20:30, Johannes Weiner wrote:
> On Wed, Jun 11, 2014 at 10:00:23AM +0200, Michal Hocko wrote:
> > If there is no memcg eligible for reclaim because all groups under the
> > reclaimed hierarchy are within their guarantee then the global direct
> > reclaim would end up in the endless loop because zones in the zonelists
> > are not considered unreclaimable (as per all_unreclaimable) and so the
> > OOM killer would never fire and direct reclaim would be triggered
> > without no chance to reclaim anything.
> > 
> > This is not possible yet because reclaim falls back to ignore low_limit
> > when nobody is eligible for reclaim. Following patch will allow to set
> > the fallback mode to hard guarantee, though, so this is a preparatory
> > patch.
> > 
> > Memcg reclaim doesn't suffer from this because the OOM killer is
> > triggered after few unsuccessful attempts of the reclaim.
> > 
> > Fix this by checking the number of scanned pages which is obviously 0 if
> > nobody is eligible and also check that the whole tree hierarchy is not
> > eligible and tell OOM it can go ahead.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/vmscan.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8041b0667673..99137aecd95f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2570,6 +2570,13 @@ out:
> >  	if (aborted_reclaim)
> >  		return 1;
> >  
> > +	/*
> > +	 * If the target memcg is not eligible for reclaim then we have no option
> > +	 * but OOM
> > +	 */
> > +	if (!sc->nr_scanned && mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> > +		return 0;
> 
> We can't just sprinkle `for each memcg in hierarchy` loops like this,
> they can get really expensive.

Yeah, I know. This one gets called only when nothing was scanned which
shoudln't happen without the hard guarantee. And as said in other email
we can optimize mem_cgroup_all_within_guarantee to skip all subtrees
that are within their guarantee.

> It's pretty stupid to not have a return value on shrink_zone(), which
> could easily indicate whether a zone was reclaimable, and instead have
> another iteration over the same zonelist and the same memcg hierarchy
> afterwards to figure out if shrink_zone() was successful or not.

I know it is stupid but this is the easiest way right now. We can/should
refactor shrink_zones to forward that information. I was playing with
sticking that infortmation into scan_control but that was even uglier.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
