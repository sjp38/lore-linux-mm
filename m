Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE2716B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 05:04:15 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o21A4CBH002961
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 02:04:13 -0800
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by spaceape14.eur.corp.google.com with ESMTP id o21A4AY8018719
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 02:04:11 -0800
Received: by pxi33 with SMTP id 33so798329pxi.14
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 02:04:10 -0800 (PST)
Date: Mon, 1 Mar 2010 02:04:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100301052306.GG19665@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010, Balbir Singh wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -580,6 +580,44 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
> >  }
> > 
> >  /*
> > + * Try to acquire the oom killer lock for all system zones.  Returns zero if a
> > + * parallel oom killing is taking place, otherwise locks all zones and returns
> > + * non-zero.
> > + */
> > +static int try_set_system_oom(void)
> > +{
> > +	struct zone *zone;
> > +	int ret = 1;
> > +
> > +	spin_lock(&zone_scan_lock);
> > +	for_each_populated_zone(zone)
> > +		if (zone_is_oom_locked(zone)) {
> > +			ret = 0;
> > +			goto out;
> > +		}
> > +	for_each_populated_zone(zone)
> > +		zone_set_flag(zone, ZONE_OOM_LOCKED);
> > +out:
> > +	spin_unlock(&zone_scan_lock);
> > +	return ret;
> > +}
> 
> Isn't this an overkill, if pagefault_out_of_memory() does nothing and
> oom takes longer than anticipated, we might end up looping, no?
> Aren't we better off waiting for OOM to finish and retry the
> pagefault?
> 

I agree, I can add schedule_timeout_uninterruptible(1) so we decrease the 
loop while waiting for the parallel oom kill to happen.  It's not overkill 
because we want to avoid needlessly killing tasks when killing one will 
already free memory which is hopefully usable by the pagefault.  This 
merely covers the race between a parallel oom kill calling out_of_memory() 
and setting TIF_MEMDIE for a task which would make the following 
out_of_memory() call in pagefault_out_of_memory() a no-op anyway.

> And like Kame said the pagefault code in memcg is undergoing a churn,
> we should revisit those parts later. I am yet to review that
> patchset though.
> 

Kame said earlier it would be no problem to rebase his memcg oom work on 
mmotm if my patches were merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
