Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 22D656B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:21:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3F8C93EE0C3
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:21:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DCCC45DE58
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:21:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAA1545DE50
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:21:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C90201DB8041
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:21:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 724E81DB803B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:21:34 +0900 (JST)
Message-ID: <507D0AE2.1020604@jp.fujitsu.com>
Date: Tue, 16 Oct 2012 16:21:06 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory cgroup: update root memory cgroup when node is
 onlined
References: <505187D4.7070404@cn.fujitsu.com> <20120913205935.GK1560@cmpxchg.org> <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, mhocko@suse.cz, bsingharora@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, paul.gortmaker@windriver.com

(2012/09/14 10:36), Hugh Dickins wrote:
> On Thu, 13 Sep 2012, Johannes Weiner wrote:
>> On Thu, Sep 13, 2012 at 03:14:28PM +0800, Wen Congyang wrote:
>>> root_mem_cgroup->info.nodeinfo is initialized when the system boots.
>>> But NODE_DATA(nid) is null if the node is not onlined, so
>>> root_mem_cgroup->info.nodeinfo[nid]->zoneinfo[zone].lruvec.zone contains
>>> an invalid pointer. If we use numactl to bind a program to the node
>>> after onlining the node and its memory, it will cause the kernel
>>> panicked:
>>
>> Is there any chance we could get rid of the zone backpointer in lruvec
>> again instead?
>
> It could be done, but it would make me sad :(
>
>> Adding new nodes is a rare event and so updating every
>> single memcg in the system might be just borderline crazy.
>
> Not horribly crazy, but rather ugly, yes.
>
>> But can't
>> we just go back to passing the zone along with the lruvec down
>> vmscan.c paths?  I agree it's ugly to pass both, given their
>> relationship.  But I don't think the backpointer is any cleaner but in
>> addition less robust.
>
> It's like how we use vma->mm: we could change everywhere to pass mm with
> vma, but it looks cleaner and cuts down on long arglists to have mm in vma.
>  From past experience, one of the things I worried about was adding extra
> args to the reclaim stack.
>
>>
>> That being said, the crashing code in particular makes me wonder:
>>
>> static __always_inline void add_page_to_lru_list(struct page *page,
>> 				struct lruvec *lruvec, enum lru_list lru)
>> {
>> 	int nr_pages = hpage_nr_pages(page);
>> 	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
>> 	list_add(&page->lru, &lruvec->lists[lru]);
>> 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
>> }
>>
>> Why did we ever pass zone in here and then felt the need to replace it
>> with lruvec->zone in fa9add6 "mm/memcg: apply add/del_page to lruvec"?
>> A page does not roam between zones, its zone is a static property that
>> can be retrieved with page_zone().
>
> Just as in vmscan.c, we have the lruvec to hand, and that's what we
> mainly want to operate upon, but there is also some need for zone.
>
> (Both Konstantin and I were looking towards the day when we move the
> lru_lock into the lruvec, removing more dependence on "zone".  Pretty
> much the only reason that hasn't happened yet, is that we have not found
> time to make a performance case convincingly - but that's another topic.)
>
> Yes, page_zone(page) is a static property of the page, but it's not
> necessarily cheap to evaluate: depends on how complex the memory model
> and the spare page flags space, doesn't it?  We both preferred to
> derive zone from lruvec where convenient.
>
> How do you feel about this patch, and does it work for you guys?
>
> You'd be right if you guessed that I started out without the
> mem_cgroup_zone_lruvec part of it, but oops in get_scan_count
> told me that's needed too.
>
> Description to be filled in later: would it be needed for -stable,
> or is onlining already broken in other ways that you're now fixing up?
>
> Reported-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
