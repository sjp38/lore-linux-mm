Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C63DC6B0083
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 06:38:08 -0500 (EST)
Received: by bkty12 with SMTP id y12so6932130bkt.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:38:07 -0800 (PST)
Message-ID: <4F43821C.7080001@openvz.org>
Date: Tue, 21 Feb 2012 15:38:04 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: fix page_referencies cgroup filter on global
 reclaim
References: <20120215162830.13902.60256.stgit@zurg> <20120221104622.GB1676@cmpxchg.org>
In-Reply-To: <20120221104622.GB1676@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Johannes Weiner wrote:
> On Wed, Feb 15, 2012 at 08:28:30PM +0400, Konstantin Khlebnikov wrote:
>> Global memory reclaimer should't skip referencies for any pages,
>> even if they are shared between different cgroups.
>
> Agreed: if we reclaim from one memcg because of its limit, we want to
> reclaim those pages that this group is not using.  If it's used by
> someone else, it should be evicted and refaulted by the group that
> needs it.
>
> If we reclaim globally, all references are "true" because we want to
> evict those pages that are not used by any cgroup.
>
> But if we reclaim a hierarchical subgroup, we don't want to evict
> pages that are shared among this hierarchy, either, even if the memcg
> that has the page charged to it is not using it.  Bouncing the page
> around the hierarchy is not sensible, because it does not solve the
> problem of the parent hitting its limit when the sibling group will
> refault it in a blink of an eye.  It should only be evicted if the
> memcg that's not using it nears its own limit, because only in that
> case would reclaiming the page remedy the situation.
>
>> This patch adds scan_control->current_mem_cgroup, which points to currently
>> shrinking sub-cgroup in hierarchy, at global reclaim it always NULL.
>
> So to be consistent, I'm wondering if we should pass
> sc->target_mem_cgroup - the limit-hitting hierarchy root - to
> page_referenced() and then have mm_match_cgroup() do a
> mem_cgroup_same_or_subtree() check to see if the vma is in the
> hierarchy rooted at sc->target_mem_cgroup.
>
> Global reclaim is handled automatically, because mm_match_cgroup() is
> not checked when the passed memcg is NULL, which sc->target_mem_cgroup
> is for global reclaim.

Also we can try to recharge page to other cgroup, if we found in rmap another its user
outsize of currently shrinking hierarchy, page there is isolated, so at the end we will
insert page directly to its lru.

But the main purpose of this patch for me is killing mz->mem_cgroup dereference,
because I plan to replace mz with direct reference to lruvec, which will be memcg-free object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
