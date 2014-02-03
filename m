Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C6D836B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 08:20:04 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so11903717wgg.20
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 05:20:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oq8si9852305wjc.167.2014.02.03.05.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 05:20:03 -0800 (PST)
Date: Mon, 3 Feb 2014 14:20:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/5] memcg: cleanup charge routines
Message-ID: <20140203132001.GE2495@dhcp22.suse.cz>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
 <1387295130-19771-2-git-send-email-mhocko@suse.cz>
 <20140130171837.GD6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140130171837.GD6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 30-01-14 12:18:37, Johannes Weiner wrote:
> On Tue, Dec 17, 2013 at 04:45:26PM +0100, Michal Hocko wrote:
[...]
> > -static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > -				   gfp_t gfp_mask,
> > +static int __mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
> >  				   unsigned int nr_pages,
> > -				   struct mem_cgroup **ptr,
> > +				   struct mem_cgroup *memcg,
> >  				   bool oom)
> 
> Why not keep the __mem_cgroup_try_charge() name?  It's shorter and
> just as descriptive.

I wanted to have 2 different names with clear reference to _what_ is
going to be charged. But I am always open to naming suggestions.

[...]
> > +static bool mem_cgroup_bypass_charge(void)
> 
> The name and parameter list suggests this consults some global memory
> cgroup state.  current_bypass_charge()?

OK, that sounds better.

> I think ultimately we want to move away from all these mem_cgroup
> prefixes of static functions in there, they add nothing of value.

Yes, I agree that mem_cgroup prefix is clumsy and we should drop it.

[...]
> > +/*
> > + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> > + * if mm is NULL). Returns NULL if memcg is under OOM.
> > + */
> > +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> > +				   gfp_t gfp_mask,
> > +				   unsigned int nr_pages,
> > +				   bool oom)
> 
> We already have a try_get_mem_cgroup_from_mm().
>
> After this series, this function basically duplicates that and it
> would be much cleaner if we only had one try_charge() function and let
> all the callers use the appropriate try_get_mem_cgroup_from_wherever()
> themselves.

try_get_mem_cgroup_from_mm doesn't charge memory itself. It just tries
to get memcg from the given mm. It is called also from a context which
doesn't charge any memory (task_in_mem_cgroup). Or have I misunderstood
you?

> If you pull the patch that moves consume_stock() back into
> try_charge() up front, I think this cleanup would be more obvious and
> the result even better.

OK, I can move it.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
