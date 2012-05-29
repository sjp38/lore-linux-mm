Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BCDD86B006C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:07:43 -0400 (EDT)
Date: Tue, 29 May 2012 10:07:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 00/28] kmem limitation for memcg
In-Reply-To: <4FC3381C.9020608@parallels.com>
Message-ID: <alpine.DEB.2.00.1205290955270.4666@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <20120525133441.GB30527@tiehlicka.suse.cz> <alpine.DEB.2.00.1205250933170.22597@router.home> <4FC3381C.9020608@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>

On Mon, 28 May 2012, Glauber Costa wrote:

> > It would be best to merge these with my patchset to extract common code
> > from the allocators. The modifications of individual slab allocators would
> > then be not necessary anymore and it would save us a lot of work.
> >
> Some of them would not, some of them would still be. But also please note that
> the patches here that deal with differences between allocators are usually the
> low hanging fruits compared to the rest.
>
> I agree that long term it not only better, but inevitable, if we are going to
> merge both.
>
> But right now, I think we should agree with the implementation itself - so if
> you have any comments on how I am handling these, I'd be happy to hear. Then
> we can probably set up a tree that does both, or get your patches merged and
> I'll rebase, etc.

Just looked over the patchset and its quite intrusive. I have never been
fond of cgroups (IMHO hardware needs to be partitioned at physical
boundaries) so I have not too much insight into what is going on in that
area.

The idea to just duplicate the caches leads to some weird stuff like the
refcounting and the recovery of the arguments used during slab creation.

I think it may be simplest to only account for the pages used by a slab in
a memcg. That code could be added to the functions in the slab allocators
that interface with the page allocators. Those are not that performance
critical and would do not much harm.

If you need per object accounting then the cleanest solution would be to
duplicate the per node arrays per memcg (or only the statistics) and have
the kmem_cache structure only once in memory.

Its best if information is only in one place for design and for performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
