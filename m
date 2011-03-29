Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E65D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:53:59 -0400 (EDT)
Date: Tue, 29 Mar 2011 09:53:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110329075355.GC30671@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

Hi,

On Mon 28-03-11 11:01:18, Ying Han wrote:
> On Mon, Mar 28, 2011 at 2:39 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > Hi all,
> >
> > Memory cgroups can be currently used to throttle memory usage of a group of
> > processes. It, however, cannot be used for an isolation of processes from
> > the rest of the system because all the pages that belong to the group are
> > also placed on the global LRU lists and so they are eligible for the global
> > memory reclaim.
> >
> > This patchset aims at providing an opt-in memory cgroup isolation. This
> > means that a cgroup can be configured to be isolated from the rest of the
> > system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).
> 
> Thank you Hugh pointing me to the thread. We are working on similar
> problem in memcg currently
> 
> Here is the problem we see:
> 1. In memcg, a page is both on per-memcg-per-zone lru and global-lru.
> 2. Global memory reclaim will throw page away regardless of cgroup.
> 3. The zone->lru_lock is shared between per-memcg-per-zone lru and global-lru.

This is the primary motivation for the patchset. Except that I do not
insist on the strict isolation because I found opt-in approach less
invasive because you have to know what you are doing while you are
setting up a group. If the thing is enabled by default we can see many
side-effects during the reclaim, I am afraid.

> And we know:
> 1. We shouldn't do global reclaim since it breaks memory isolation.
> 2. There is no need for a page to be on both LRU list, especially
> after having per-memcg background reclaim.
> 
> So our approach is to take off page from global lru after it is
> charged to a memcg. Only pages allocated at root cgroup remains in
> global LRU, and each memcg reclaims pages on its isolated LRU.

This sounds like an instance where all cgroups are isolated by default
(this can be set by mem_cgroup->isolated = 1).

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
