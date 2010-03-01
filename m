Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 415256B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 18:59:13 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o21NxAdj015062
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Mar 2010 08:59:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5829145DE54
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:59:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C0445DE4E
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:59:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5FE51DB8017
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:59:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 817251DB8014
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:59:09 +0900 (JST)
Date: Tue, 2 Mar 2010 08:55:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301052306.GG19665@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010 02:04:07 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 1 Mar 2010, Balbir Singh wrote:
> 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -580,6 +580,44 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
> > >  }
> > > 
> > >  /*
> > > + * Try to acquire the oom killer lock for all system zones.  Returns zero if a
> > > + * parallel oom killing is taking place, otherwise locks all zones and returns
> > > + * non-zero.
> > > + */
> > > +static int try_set_system_oom(void)
> > > +{
> > > +	struct zone *zone;
> > > +	int ret = 1;
> > > +
> > > +	spin_lock(&zone_scan_lock);
> > > +	for_each_populated_zone(zone)
> > > +		if (zone_is_oom_locked(zone)) {
> > > +			ret = 0;
> > > +			goto out;
> > > +		}
> > > +	for_each_populated_zone(zone)
> > > +		zone_set_flag(zone, ZONE_OOM_LOCKED);
> > > +out:
> > > +	spin_unlock(&zone_scan_lock);
> > > +	return ret;
> > > +}
> > 
> > Isn't this an overkill, if pagefault_out_of_memory() does nothing and
> > oom takes longer than anticipated, we might end up looping, no?
> > Aren't we better off waiting for OOM to finish and retry the
> > pagefault?
> > 
> 
> I agree, I can add schedule_timeout_uninterruptible(1) so we decrease the 
> loop while waiting for the parallel oom kill to happen.  It's not overkill 
> because we want to avoid needlessly killing tasks when killing one will 
> already free memory which is hopefully usable by the pagefault.  This 
> merely covers the race between a parallel oom kill calling out_of_memory() 
> and setting TIF_MEMDIE for a task which would make the following 
> out_of_memory() call in pagefault_out_of_memory() a no-op anyway.
> 
> > And like Kame said the pagefault code in memcg is undergoing a churn,
> > we should revisit those parts later. I am yet to review that
> > patchset though.
> > 
> 
> Kame said earlier it would be no problem to rebase his memcg oom work on 
> mmotm if my patches were merged.
> 

But I also said this patch cause regression.
I said it's ok to rabese to you series of patch. But about this patch,
No.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
