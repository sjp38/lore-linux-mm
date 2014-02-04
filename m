Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0B56B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:40:58 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so4531074ead.34
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:40:57 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x43si43376281eey.19.2014.02.04.08.40.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:40:57 -0800 (PST)
Date: Tue, 4 Feb 2014 11:40:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 2/6] memcg: cleanup charge routines
Message-ID: <20140204164050.GR6963@cmpxchg.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-3-git-send-email-mhocko@suse.cz>
 <20140204160509.GN6963@cmpxchg.org>
 <20140204161230.GN4890@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204161230.GN4890@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 04, 2014 at 05:12:30PM +0100, Michal Hocko wrote:
> On Tue 04-02-14 11:05:09, Johannes Weiner wrote:
> > On Tue, Feb 04, 2014 at 02:28:56PM +0100, Michal Hocko wrote:
> > > -	/*
> > > -	 * We always charge the cgroup the mm_struct belongs to.
> > > -	 * The mm_struct's mem_cgroup changes on task migration if the
> > > -	 * thread group leader migrates. It's possible that mm is not
> > > -	 * set, if so charge the root memcg (happens for pagecache usage).
> > > -	 */
> > > -	if (!*ptr && !mm)
> > > -		*ptr = root_mem_cgroup;
> > 
> > [...]
> > 
> > >  /*
> > > + * Charges and returns memcg associated with the given mm (or root_mem_cgroup
> > > + * if mm is NULL). Returns NULL if memcg is under OOM.
> > > + */
> > > +static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
> > > +				   gfp_t gfp_mask,
> > > +				   unsigned int nr_pages,
> > > +				   bool oom)
> > > +{
> > > +	struct mem_cgroup *memcg;
> > > +	int ret;
> > > +
> > > +	/*
> > > +	 * We always charge the cgroup the mm_struct belongs to.
> > > +	 * The mm_struct's mem_cgroup changes on task migration if the
> > > +	 * thread group leader migrates. It's possible that mm is not
> > > +	 * set, if so charge the root memcg (happens for pagecache usage).
> > > +	 */
> > > +	if (!mm)
> > > +		goto bypass;
> > 
> > Why shuffle it around right before you remove it anyway?  Just start
> > the series off with the patches that delete stuff without having to
> > restructure anything, get those out of the way.
> 
> As mentioned in the previous email. I wanted to have this condition
> removal bisectable. So it is removed in the next patch when it is
> replaced by VM_BUG_ON.

I'm not suggesting to sneak the removal into *this* patch, just put
the simple stand-alone patches that remove stuff first in the series.

Seems pretty logical to me to first reduce the code base as much as
possible before reorganizing it.  This does not change bisectability
but it sure makes the patches easier to read.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
