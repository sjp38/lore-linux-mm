Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 575736B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 23:43:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 86FDD3EE0B5
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 12:43:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6628D45DEB5
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 12:43:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4101D45DE7E
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 12:43:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 307451DB803F
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 12:43:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2B011DB8038
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 12:43:05 +0900 (JST)
Message-ID: <4FCD7FBB.1000304@jp.fujitsu.com>
Date: Tue, 05 Jun 2012 12:40:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V7 07/14] mm/page_cgroup: Make page_cgroup point to the
 cgroup rather than the mem_cgroup
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FCD648E.90709@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu) <87ehpu8o5z.fsf@skywalker.in.ibm.com>
In-Reply-To: <87ehpu8o5z.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/05 11:53), Aneesh Kumar K.V wrote:
> Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  writes:
>
>> (2012/05/30 23:38), Aneesh Kumar K.V wrote:
>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> We will use it later to make page_cgroup track the hugetlb cgroup information.
>>>
>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>> ---
>>>    include/linux/mmzone.h      |    2 +-
>>>    include/linux/page_cgroup.h |    8 ++++----
>>>    init/Kconfig                |    4 ++++
>>>    mm/Makefile                 |    3 ++-
>>>    mm/memcontrol.c             |   42 +++++++++++++++++++++++++-----------------
>>>    5 files changed, 36 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>> index 2427706..2483cc5 100644
>>> --- a/include/linux/mmzone.h
>>> +++ b/include/linux/mmzone.h
>>> @@ -1052,7 +1052,7 @@ struct mem_section {
>>>
>>>    	/* See declaration of similar field in struct zone */
>>>    	unsigned long *pageblock_flags;
>>> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>> +#ifdef CONFIG_PAGE_CGROUP
>>>    	/*
>>>    	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
>>>    	 * section. (see memcontrol.h/page_cgroup.h about this.)
>>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>>> index a88cdba..7bbfe37 100644
>>> --- a/include/linux/page_cgroup.h
>>> +++ b/include/linux/page_cgroup.h
>>> @@ -12,7 +12,7 @@ enum {
>>>    #ifndef __GENERATING_BOUNDS_H
>>>    #include<generated/bounds.h>
>>>
>>> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>> +#ifdef CONFIG_PAGE_CGROUP
>>>    #include<linux/bit_spinlock.h>
>>>
>>>    /*
>>> @@ -24,7 +24,7 @@ enum {
>>>     */
>>>    struct page_cgroup {
>>>    	unsigned long flags;
>>> -	struct mem_cgroup *mem_cgroup;
>>> +	struct cgroup *cgroup;
>>>    };
>>>
>>
>> This patch seems very bad.
>
> I had to change that to
>
> struct page_cgroup {
> 	unsigned long flags;
> 	struct cgroup_subsys_state *css;
> };
>
> to get memcg to work. We end up changing css.cgroup on cgroupfs mount/umount.
>
Hmm, then pointer to memcg can be calculated by this *css.
Ok to this.

>>
>>    - What is the performance impact to memcg ? Doesn't this add extra overheads
>>      to memcg lookup ?
>
> Considering that we are stashing cgroup_subsys_state, it should be a
> simple addition. I haven't measured the exact numbers. Do you have any
> suggestion on the tests I can run ?
>

copy-on-write, parallel page fault, file creation/deletion etc..


>>    - Hugetlb reuquires much more smaller number of tracking information rather
>>      than memcg requires. I guess you can record the information into page->private
>>      if you want.
>
> So If we end up tracking page cgroup in struct page all these extra over
> head will go away. And in most case we would have both memcg and hugetlb
> enabled by default.
>
>>    - This may prevent us from the work 'reducing size of page_cgroup'
>>
>
> by reducing you mean moving struct page_cgroup info to struct page
> itself ? If so this should not have any impact right ?

I'm not sure but....doesn't this change bring impact to rules around
(un)lock_page_cgroup() and pc->memcg overwriting algorithm ?
Let me think....but maybe discussing without patch was wrong. sorry.

>Most of the requirement of hugetlb should be similar to memcg.
>
Yes and No. hugetlb just requires 1/HUGEPAGE_SIZE of tracking information.
So, as Michal pointed out, if the user _really_ want to avoid
overheads of memcg, the effect cgroup_disable=memory should be kept.
If you use page_cgroup, you cannot save memory by the boot option.

This makes the points 'creating hugetlb only subsys for avoiding memcg overheads'
unclear. You don't need tracking information per page and it can be dynamically
allocated. Or please range-tracking as Michal proposed.

>> So, strong Nack to this. I guess you can use page->private or some entries in
>> struct page, you have many pages per accounting units. Please make an effort
>> to avoid using page_cgroup.
>>
>
> HugeTLB already use page->private of compound page head to track subpool
> pointer. So we won't be able to use page->private.
>

You can use other pages than head/tails.
For example,I think you have 512 pages per 2M pages.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
