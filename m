Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7677D6B0036
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 18:23:17 -0400 (EDT)
Date: Thu, 6 Jun 2013 15:23:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 29/35] memcg: per-memcg kmem shrinking
Message-Id: <20130606152315.69603127cca33e54b1ed428e@linux-foundation.org>
In-Reply-To: <51B07BEC.9010205@parallels.com>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-30-git-send-email-glommer@openvz.org>
	<20130605160841.909420c06bfde62039489d2e@linux-foundation.org>
	<51B049D5.2020809@parallels.com>
	<20130606024906.e5b85b28.akpm@linux-foundation.org>
	<51B07BEC.9010205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, 6 Jun 2013 16:09:16 +0400 Glauber Costa <glommer@parallels.com> wrote:

> >>> then waiting for it to complete is equivalent to calling it directly.
> >>>
> >> Not in this case. We are in wait-capable context (we check for this
> >> right before we reach this), but we are not in fs capable context.
> >>
> >> So the reason we do this - which I tried to cover in the changelog, is
> >> to escape from the GFP_FS limitation that our call chain has, not the
> >> wait limitation.
> > 
> > But that's equivalent to calling the code directly.  Look:
> > 
> > some_fs_function()
> > {
> > 	lock(some-fs-lock);
> > 	...
> > }
> > 
> > some_other_fs_function()
> > {
> > 	lock(some-fs-lock);
> > 	alloc_pages(GFP_NOFS);
> > 	->...
> > 	  ->schedule_work(some_fs_function);
> > 	    flush_scheduled_work();
> > 
> > that flush_scheduled_work() won't complete until some_fs_function() has
> > completed.  But some_fs_function() won't complete, because we're
> > holding some-fs-lock.
> > 
> 
> In my experience during this series, most of the kmem allocation here

"most"?

> will be filesystem related. This means that we will allocate that with
> GFP_FS on.

eh?  filesystems do a tremendous amount of GFP_NOFS allocation.  

akpm3:/usr/src/25> grep GFP_NOFS fs/*/*.c|wc -l
898

> If we don't do anything like that, reclaim is almost
> pointless since it will never free anything (only once here and there
> when the allocation is not from fs).

It depends what you mean by "reclaim".  There are a lot of things which
vmscan can do for a GFP_NOFS allocation.  Scraping clean pagecache,
clean swapcache, well-behaved (ahem) shrinkable caches.

> It tend to work just fine like this. It may very well be because fs
> people just mark everything as NOFS out of safety and we aren't *really*
> holding any locks in common situations, but it will blow in our faces in
> a subtle way (which none of us want).
> 
> That said, suggestions are more than welcome.

At a minimum we should remove all the schedule_work() stuff, call the
callback function synchronously and add

	/* This code is full of deadlocks */


Sorry, this part of the patchset is busted and needs a fundamental
rethink.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
