Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 02FE16B0098
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 03:54:14 -0500 (EST)
Date: Thu, 24 Nov 2011 09:53:57 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] mm: memcg: modify PageCgroupAcctLRU non-atomically
Message-ID: <20111124085357.GA6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-8-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.00.1111231039390.2175@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111231039390.2175@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 23, 2011 at 10:52:39AM -0800, Hugh Dickins wrote:
> On Wed, 23 Nov 2011, Johannes Weiner wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > This bit is protected by zone->lru_lock, there is no need for locked
> > operations when setting and clearing it.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Unless there are special considerations which you have not mentioned at
> all in the description above, this 7/8 and the similar 8/8 are mistaken.
> 
> The atomic operation is not for guaranteeing the setting and clearing
> of the bit in question: it's for guaranteeing that you don't accidentally
> set or clear any of the other bits in the same word when you're doing so,
> if another task is updating them at the same time as you're doing this.
> 
> There are circumstances when non-atomic shortcuts can be taken, when
> you're sure the field cannot yet be visible to other tasks (we do that
> when setting PageLocked on a freshly allocated page, for example - but
> even then have to rely on others using get_page_unless_zero properly).
> But I don't think that's the case here.

I have no idea how I could oversee this.  You are, of course, right.

That said, I *think* that it is safe for PageCgroupCache because
nobody else should be modifying any pc->flags concurrently:

PCG_LOCK: by definition exclusive and held during setting and clearing
PCG_CACHE

PCG_CACHE: serialized by PCG_LOCK

PCG_USED: serialized by PCG_LOCK

PCG_MIGRATION: serialized by PCG_LOCK

PCG_MOVE_LOCK: 1. update_page_stat() is only called against file
pages, and the page lock serializes charging against mapping.  the
page is also charged before establishing a pte mapping, so an unmap
can not race with a charge.  2. split_huge_fixup runs against already
charged pages.  3. move_account is serialized both by LRU-isolation
during charging and PCG_LOCK

PCG_FILE_MAPPED: same as PCG_MOVE_LOCK's 1.

PCG_ACCT_LRU: pages are isolated from the LRU during charging

But all this is obviously anything but robust, and so I retract the
broken 7/8 and the might-actually-work 8/8.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
