Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id C4AFF6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 02:20:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DF6A33EE0BD
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:20:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C8E8345DD78
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:20:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 965BF45DE4D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:20:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89E8A1DB803E
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:20:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 303D01DB8038
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:20:09 +0900 (JST)
Message-ID: <4F90FF57.9060401@jp.fujitsu.com>
Date: Fri, 20 Apr 2012 15:16:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
References: <1334773315-32215-1-git-send-email-yinghan@google.com> <20120418163330.ca1518c7.akpm@linux-foundation.org> <4F8F6368.2090005@jp.fujitsu.com> <20120419131211.GA1759@cmpxchg.org> <4F90AFDE.2000707@jp.fujitsu.com> <CALWz4iw5+ypsD_vwm6vcDKN-JrV_riF4mFvQME2zr2jR_iNuOg@mail.gmail.com>
In-Reply-To: <CALWz4iw5+ypsD_vwm6vcDKN-JrV_riF4mFvQME2zr2jR_iNuOg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

(2012/04/20 14:57), Ying Han wrote:

> On Thu, Apr 19, 2012 at 5:37 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> (2012/04/19 22:12), Johannes Weiner wrote:
>>> Plus this code runs for ALL uncharges, the unlikely() and preliminary
>>> flag testing don't make it okay.  It's bad that we have this in the
>>> allocator, but at least it would be good to hook into that branch and
>>> not add another one.
>>>
>>> pc->mem_cgroup stays intact after the uncharge.  Could we make the
>>> memcg removal path wait on the mlock counter to drop to zero instead
>>> and otherwise keep Ying's version?
>>>
>>
>>
>> handling problem in ->destroy() path ? Hmm, it will work against use-after-free.
> 
>> But accounting problem which may be caused by mem_cgroup_lru_add_list() cannot
>> be handled, which overwrites pc->mem_cgroup.
> 
> Kame, can you clarify that? What the mem_cgroup_lru_add_list() has
> anything to do w/ this problem?
> 


It overwrites pc->mem_cgroup. Then, Assume a task in cgroup "A".

	1. page is charged.       pc->mem_cgroup = A + Used bit.
	2. page is set Mlocked.   A's mlock-counter += 1
	3. page is uncharged      - Used bit.
	4. page is added to lru   pc->mem_cgroup = root
	5. page is freed          root's mlock-coutner -=1, 

Then, A's mlock-counter +1, root's mlock-counter -1 IF free_pages()
really handle mlocked pages...



>>
>> But hm, is this too slow ?...
>> ==
>> mem_cgroup_uncharge_common()
>> {
>>        ....
>>        if (PageSwapCache(page) || PageMlocked(page))
>>                return NULL;
>> }
>>
>> page_alloc.c::
>>
>> static inline void free_page_mlock(struct page *page)
>> {
>>
>>        __dec_zone_page_state(page, NR_MLOCK);
>>        __count_vm_event(UNEVICTABLE_MLOCKFREED);
>>
>>        mem_cgroup_uncharge_page(page);
>> }
>> ==
>>
>> BTW, at reading code briefly....why we have hooks in free_page() ?
>>
>> It seems do_munmap() and exit_mmap() calls munlock_vma_pages_all().
>> So, it seems all vmas which has VM_MLOCKED are checked before freeing.
>> vmscan never frees mlocked pages, I think.
>>
>> Any other path to free mlocked pages without munlock ?
> 
> I found this commit which introduced the hook in the freeing path,
> however I couldn't get more details why it was introduced from the
> commit description
> 
> commit 985737cf2ea096ea946aed82c7484d40defc71a8
> Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Date:   Sat Oct 18 20:26:53 2008 -0700
> 
>     mlock: count attempts to free mlocked page
> 
>     Allow free of mlock()ed pages.  This shouldn't happen, but during
>     developement, it occasionally did.
> 
>     This patch allows us to survive that condition, while keeping the
>     statistics and events correct for debug.
> 
>> I feel freeing Mlocked page is a cause of problems.
> 


Sigh...."This shouldn't happen"!!!!!

How about adding warning to free_page() path and remove your current hook ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
