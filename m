Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 30EC76B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:02:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so377911pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:02:48 -0800 (PST)
Date: Tue, 20 Nov 2012 10:02:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <50AA3ABF.4090803@parallels.com>
Message-ID: <alpine.DEB.2.00.1211200950120.4200@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com> <50AA3ABF.4090803@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon, 19 Nov 2012, Glauber Costa wrote:

> >> In the case I outlined below, for backwards compatibility. What I
> >> actually mean is that memcg *currently* allows arbitrary notifications.
> >> One way to merge those, while moving to a saner 3-point notification, is
> >> to still allow the old writes and fit them in the closest bucket.
> >>
> > 
> > Yeah, but I'm wondering why three is the right answer.
> > 
> 
> This is unrelated to what I am talking about.
> I am talking about pre-defined values with a specific event meaning (in
> his patchset, 3) vs arbitrary numbers valued in bytes.
> 

Right, and I don't see how you can map the memcg thresholds onto Anton's 
scheme that heavily relies upon reclaim activity; what bucket does a 
threshold of 48MB in a memcg with a limit of 64MB fit into?  Perhaps you 
have some formula in mind that would do this, but I don't see how it works 
correctly without factoring in configuration options (memory compaction), 
type of allocation (GFP_ATOMIC won't trigger Anton's reclaim scheme like 
GFP_KERNEL), altered min_free_kbytes, etc.

This begs the question of whether the new cgroup should be considered as a 
replacement for memory thresholds within memcg in the first place; 
certainly both can coexist just fine.

> > Same thing with a separate mempressure cgroup.  The point is that there 
> > will be users of this cgroup that do not want the overhead imposed by 
> > memcg (which is why it's disabled in defconfig) and there's no direct 
> > dependency that causes it to be a part of memcg.
> > 
> I think we should shoot the duck where it is going, not where it is. A
> good interface is more important than overhead, since this overhead is
> by no means fundamental - memcg is fixable, and we would all benefit
> from it.
> 
> Now, whether or not memcg is the right interface is a different
> discussion - let's have it!
> 

I don't see memcg as being a prerequisite for any of this, I think Anton's 
cgroup can coexist with memcg thresholds, it allows for notifications in 
cpusets as well when they face memory pressure, and users need not enable 
memcg for this functionality (and memcg is pretty darn large in its memory 
footprint, I'd rather not see it fragmented either for something that can 
standalone with increased functionality).

But let's try the question in reverse: is there any specific reasons why 
this can't be implemented separately?  I sure know the cpusets + no-memcg 
configuration would benefit from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
