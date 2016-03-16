Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 108356B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 04:44:00 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so61234981wmp.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 01:44:00 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id e124si29461297wma.114.2016.03.16.01.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 01:43:58 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so178812308wmp.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 01:43:58 -0700 (PDT)
Date: Wed, 16 Mar 2016 09:43:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim and OOM kill when shrinking
 memory.max below usage
Message-ID: <20160316084357.GA21228@dhcp22.suse.cz>
References: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
 <20160311081825.GC27701@dhcp22.suse.cz>
 <20160311091931.GK1946@esperanza>
 <20160316051848.GA11006@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160316051848.GA11006@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 15-03-16 22:18:48, Johannes Weiner wrote:
> On Fri, Mar 11, 2016 at 12:19:31PM +0300, Vladimir Davydov wrote:
> > On Fri, Mar 11, 2016 at 09:18:25AM +0100, Michal Hocko wrote:
> > > On Thu 10-03-16 15:50:14, Johannes Weiner wrote:
> > ...
> > > > @@ -5037,9 +5040,36 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
> > > >  	if (err)
> > > >  		return err;
> > > >  
> > > > -	err = mem_cgroup_resize_limit(memcg, max);
> > > > -	if (err)
> > > > -		return err;
> > > > +	xchg(&memcg->memory.limit, max);
> > > > +
> > > > +	for (;;) {
> > > > +		unsigned long nr_pages = page_counter_read(&memcg->memory);
> > > > +
> > > > +		if (nr_pages <= max)
> > > > +			break;
> > > > +
> > > > +		if (signal_pending(current)) {
> > > 
> > > Didn't you want fatal_signal_pending here? At least the changelog
> > > suggests that.
> > 
> > I suppose the user might want to interrupt the write by hitting CTRL-C.
> 
> Yeah. This is the same thing we do for the current limit setting loop.

Yes we do but then the operation is canceled without any change. Now
re-reading the changelog I've realized I have misread the "we run out of
OOM victims and there's only unreclaimable memory left, or the task
writing to memory.max is killed." part and considered task writing... is
OOM killed.
 
> > Come to think of it, shouldn't we restore the old limit and return EBUSY
> > if we failed to reclaim enough memory?
> 
> I suspect it's very rare that it would fail. But even in that case
> it's probably better to at least not allow new charges past what the
> user requested, even if we can't push the level back far enough.

I guess you are right. This guarantee is indeed useful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
