Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 00E3F6B003B
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:12:32 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so12839811wgh.11
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:12:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si12456300wja.90.2014.02.04.08.12.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:12:31 -0800 (PST)
Date: Tue, 4 Feb 2014 17:12:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 2/6] memcg: cleanup charge routines
Message-ID: <20140204161230.GN4890@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-3-git-send-email-mhocko@suse.cz>
 <20140204160509.GN6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204160509.GN6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 11:05:09, Johannes Weiner wrote:
> On Tue, Feb 04, 2014 at 02:28:56PM +0100, Michal Hocko wrote:
[...]
> > +static bool current_bypass_charge(void)
> > +{
> > +	/*
> > +	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> > +	 * in system level. So, allow to go ahead dying process in addition to
> > +	 * MEMDIE process.
> > +	 */
> > +	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > +		     || fatal_signal_pending(current)))
> > +		return true;
> > +
> > +	return false;
> > +}
> 
> I'd just leave it inline at this point, it lines up nicely with the
> other pre-charge checks in try_charge, which is at this point short
> enough to take this awkward 3-liner.

I can keep it inline of course. I thought having it out of line would
make it more obvious what are the bypass conditions. But as there is
still mem_cgroup_is_root then it is probably not the best thing to do.

> > +static int mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
> >  				   unsigned int nr_pages,
> > -				   struct mem_cgroup **ptr,
> > +				   struct mem_cgroup *memcg,
> >  				   bool oom)
> >  {
> >  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
> >  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > -	struct mem_cgroup *memcg = NULL;
> >  	int ret;
> >  
> > -	/*
> > -	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> > -	 * in system level. So, allow to go ahead dying process in addition to
> > -	 * MEMDIE process.
> > -	 */
> > -	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > -		     || fatal_signal_pending(current)))
> > +	if (mem_cgroup_is_root(memcg) || current_bypass_charge())
> >  		goto bypass;
> >  
> >  	if (unlikely(task_in_memcg_oom(current)))
> >  		goto nomem;
> >  
> > +	if (consume_stock(memcg, nr_pages))
> > +		return 0;
> > +
> >  	if (gfp_mask & __GFP_NOFAIL)
> >  		oom = false;
> >  
> > -	/*
> > -	 * We always charge the cgroup the mm_struct belongs to.
> > -	 * The mm_struct's mem_cgroup changes on task migration if the
> > -	 * thread group leader migrates. It's possible that mm is not
> > -	 * set, if so charge the root memcg (happens for pagecache usage).
> > -	 */
> > -	if (!*ptr && !mm)
> > -		*ptr = root_mem_cgroup;
> 
> [...]
> 
> >  /*
> > + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> > + * if mm is NULL). Returns NULL if memcg is under OOM.
> > + */
> > +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> > +				   gfp_t gfp_mask,
> > +				   unsigned int nr_pages,
> > +				   bool oom)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	int ret;
> > +
> > +	/*
> > +	 * We always charge the cgroup the mm_struct belongs to.
> > +	 * The mm_struct's mem_cgroup changes on task migration if the
> > +	 * thread group leader migrates. It's possible that mm is not
> > +	 * set, if so charge the root memcg (happens for pagecache usage).
> > +	 */
> > +	if (!mm)
> > +		goto bypass;
> 
> Why shuffle it around right before you remove it anyway?  Just start
> the series off with the patches that delete stuff without having to
> restructure anything, get those out of the way.

As mentioned in the previous email. I wanted to have this condition
removal bisectable. So it is removed in the next patch when it is
replaced by VM_BUG_ON.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
