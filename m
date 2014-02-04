Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 094A86B0039
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 14:11:33 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so4491603eek.22
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 11:11:33 -0800 (PST)
Received: from mail-ea0-x22d.google.com (mail-ea0-x22d.google.com [2a00:1450:4013:c01::22d])
        by mx.google.com with ESMTPS id b7si1263682eez.134.2014.02.04.11.11.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 11:11:32 -0800 (PST)
Received: by mail-ea0-f173.google.com with SMTP id d10so4521580eaj.18
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 11:11:32 -0800 (PST)
Date: Tue, 4 Feb 2014 20:11:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 2/6] memcg: cleanup charge routines
Message-ID: <20140204191125.GA26000@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-3-git-send-email-mhocko@suse.cz>
 <20140204160509.GN6963@cmpxchg.org>
 <20140204161230.GN4890@dhcp22.suse.cz>
 <20140204164050.GR6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204164050.GR6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 11:40:50, Johannes Weiner wrote:
> On Tue, Feb 04, 2014 at 05:12:30PM +0100, Michal Hocko wrote:
> > On Tue 04-02-14 11:05:09, Johannes Weiner wrote:
> > > On Tue, Feb 04, 2014 at 02:28:56PM +0100, Michal Hocko wrote:
> > > > -	/*
> > > > -	 * We always charge the cgroup the mm_struct belongs to.
> > > > -	 * The mm_struct's mem_cgroup changes on task migration if the
> > > > -	 * thread group leader migrates. It's possible that mm is not
> > > > -	 * set, if so charge the root memcg (happens for pagecache usage).
> > > > -	 */
> > > > -	if (!*ptr && !mm)
> > > > -		*ptr = root_mem_cgroup;
> > > 
> > > [...]
> > > 
> > > >  /*
> > > > + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> > > > + * if mm is NULL). Returns NULL if memcg is under OOM.
> > > > + */
> > > > +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> > > > +				   gfp_t gfp_mask,
> > > > +				   unsigned int nr_pages,
> > > > +				   bool oom)
> > > > +{
> > > > +	struct mem_cgroup *memcg;
> > > > +	int ret;
> > > > +
> > > > +	/*
> > > > +	 * We always charge the cgroup the mm_struct belongs to.
> > > > +	 * The mm_struct's mem_cgroup changes on task migration if the
> > > > +	 * thread group leader migrates. It's possible that mm is not
> > > > +	 * set, if so charge the root memcg (happens for pagecache usage).
> > > > +	 */
> > > > +	if (!mm)
> > > > +		goto bypass;
> > > 
> > > Why shuffle it around right before you remove it anyway?  Just start
> > > the series off with the patches that delete stuff without having to
> > > restructure anything, get those out of the way.
> > 
> > As mentioned in the previous email. I wanted to have this condition
> > removal bisectable. So it is removed in the next patch when it is
> > replaced by VM_BUG_ON.
> 
> I'm not suggesting to sneak the removal into *this* patch,

OK

> just put the simple stand-alone patches that remove stuff first in the
> series.

In this particular case, though, the reduced condition is much easier
to review IMO. Just look at the jungle of different *ptr vs. mm
combinations described in this patch description which would have to be
reviewed separately if I moved the removal before this patch.
The ptr part of the original condition went away naturally here while
the reasoning why there is no code path implicitly relying on (!ptr &&
!mm) resulting in bypass would be harder.

> Seems pretty logical to me to first reduce the code base as much as
> possible before reorganizing it.  This does not change bisectability
> but it sure makes the patches easier to read.

Agreed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
