Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 223486B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:51:38 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id f15so3845084eak.30
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:51:37 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k3si36442002eep.15.2014.02.03.07.51.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 07:51:36 -0800 (PST)
Date: Mon, 3 Feb 2014 10:51:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/5] memcg: cleanup charge routines
Message-ID: <20140203155127.GI6963@cmpxchg.org>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
 <1387295130-19771-2-git-send-email-mhocko@suse.cz>
 <20140130171837.GD6963@cmpxchg.org>
 <20140203132001.GE2495@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140203132001.GE2495@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Feb 03, 2014 at 02:20:01PM +0100, Michal Hocko wrote:
> On Thu 30-01-14 12:18:37, Johannes Weiner wrote:
> > On Tue, Dec 17, 2013 at 04:45:26PM +0100, Michal Hocko wrote:
> [...]
> > > -static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > > -				   gfp_t gfp_mask,
> > > +static int __mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
> > >  				   unsigned int nr_pages,
> > > -				   struct mem_cgroup **ptr,
> > > +				   struct mem_cgroup *memcg,
> > >  				   bool oom)
> > 
> > Why not keep the __mem_cgroup_try_charge() name?  It's shorter and
> > just as descriptive.
> 
> I wanted to have 2 different names with clear reference to _what_ is
> going to be charged. But I am always open to naming suggestions.
>
> > > +/*
> > > + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> > > + * if mm is NULL). Returns NULL if memcg is under OOM.
> > > + */
> > > +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> > > +				   gfp_t gfp_mask,
> > > +				   unsigned int nr_pages,
> > > +				   bool oom)
> > 
> > We already have a try_get_mem_cgroup_from_mm().
> >
> > After this series, this function basically duplicates that and it
> > would be much cleaner if we only had one try_charge() function and let
> > all the callers use the appropriate try_get_mem_cgroup_from_wherever()
> > themselves.
> 
> try_get_mem_cgroup_from_mm doesn't charge memory itself. It just tries
> to get memcg from the given mm. It is called also from a context which
> doesn't charge any memory (task_in_mem_cgroup). Or have I misunderstood
> you?

Your mem_cgroup_try_charge_mm() looks up a memcg from mm and calls
try_charge().  But we have try_get_mem_cgroup_from_mm() to do the
first half, so why not have the current callers of
mem_cgroup_try_charge_mm() just use try_get_mem_cgroup_from_mm() and
try_charge()?  Why is charging through an mm - as opposed to through a
page or through the task - special?

Most callsites already do the lookups themselves:

try_charge_swapin:	uses try_get_mem_cgroup_from_page()
kmem_newpage_charge:	uses try_get_mem_cgroup_from_mm()
precharge:		uses mem_cgroup_from_task()

So just let these two do the same:

newpage_charge:		could use try_get_mem_cgroup_from_mm()
cache_charge:		could use try_get_mem_cgroup_from_mm()

And then provide one try_charge() that always takes a non-null memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
