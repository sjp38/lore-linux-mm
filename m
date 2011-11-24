Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A06686B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:13:22 -0500 (EST)
Date: Thu, 24 Nov 2011 10:13:12 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 8/8] mm: memcg: modify PageCgroupCache non-atomically
Message-ID: <20111124091312.GE6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-9-git-send-email-hannes@cmpxchg.org>
 <20111124091328.d28d9f55.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124091328.d28d9f55.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 09:13:28AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Nov 2011 16:42:31 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > This bit is protected by lock_page_cgroup(), there is no need for
> > locked operations when setting and clearing it.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Hm. non-atomic ops for pc->flags seems dangerous.
> How about try to remove PCG_CACHE ? Maybe we can depends on PageAnon(page).
> We see 'page' on memcg->lru now.
> I'm sorry I forgot why we needed PCG_CACHE flag..

The problem is that we charge/uncharged pages that are not fully
rmapped and so PageAnon() is not reliable.  I forgot if there are more
places, but the commit_charge in migration was a prominent one.

I have a patch set that reworks migration so to only commit pages that
are fully rmapped but it clashed with the THP patches and I didn't see
too much value to fix it up.  But I should probably revive it, because
it makes some things simpler.

As I replied to Hugh, it might even work for PCG_CACHE, but it's
definitely dangerous and not worth the complex dependencies it brings
on other parts of the code, so please consider 7/8 and 8/8 dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
