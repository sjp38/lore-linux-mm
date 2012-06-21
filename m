Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id C396A6B0092
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:14:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2584A3EE0BD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0207A45DE7E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1D3C45DE9E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C347FE08009
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:08 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75BAFE08004
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:14:08 +0900 (JST)
Message-ID: <4FE2D747.20506@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 17:11:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value check
References: <4FDF17A3.9060202@jp.fujitsu.com> <4FDF1830.1000504@jp.fujitsu.com> <20120619165815.5ce24be7.akpm@linux-foundation.org>
In-Reply-To: <20120619165815.5ce24be7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/20 8:58), Andrew Morton wrote:
> On Mon, 18 Jun 2012 20:59:44 +0900
> Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>
>>
>> By commit "memcg: move charges to root cgroup if use_hierarchy=0"
>> mem_cgroup_move_parent() only returns -EBUSY, -EINVAL.
>> So, we can remove -ENOMEM and -EINTR checks.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>   mm/memcontrol.c |    5 -----
>>   1 files changed, 0 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index cf8a0f6..726b7c6 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3847,8 +3847,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>>   		pc = lookup_page_cgroup(page);
>>
>>   		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
>> -		if (ret == -ENOMEM || ret == -EINTR)
>> -			break;
>>
>>   		if (ret == -EBUSY || ret == -EINVAL) {
>
> This looks a bit fragile - if mem_cgroup_move_parent() is later changed
> (intentionally or otherwise!) to return -Esomethingelse then
> mem_cgroup_force_empty_list() will subtly break.  Why not just do
>
> 		if (ret<  0)
>

You're right. I'm sorry I haven't done enough clean-ups.
I made 2 more patches...I'll repost/remake all paches if it's better.
one more patch will follow this email.
==
 From eee5f31fc6378da19705de7187bb3f219ef6d7f6 Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 17:25:04 +0900
Subject: [PATCH 1/2] mem_cgroup_move_parent() doesn't need gfp_mask.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  mm/memcontrol.c |    5 ++---
  1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 76d83a5..90a2ad4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2662,8 +2662,7 @@ out:
  
  static int mem_cgroup_move_parent(struct page *page,
  				  struct page_cgroup *pc,
-				  struct mem_cgroup *child,
-				  gfp_t gfp_mask)
+				  struct mem_cgroup *child)
  {
  	struct mem_cgroup *parent;
  	unsigned int nr_pages;
@@ -3837,7 +3836,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
  
  		pc = lookup_page_cgroup(page);
  
-		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
+		ret = mem_cgroup_move_parent(page, pc, memcg);
  
  		if (ret == -EBUSY || ret == -EINVAL) {
  			/* found lock contention or "pc" is obsolete. */
-- 
1.7.4.1











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
