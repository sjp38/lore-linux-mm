Message-ID: <4934E444.9030603@cn.fujitsu.com>
Date: Tue, 02 Dec 2008 15:31:16 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] cgroup: fix pre_destroy and semantics of css->refcnt
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>	<20081201150208.6b24506b.kamezawa.hiroyu@jp.fujitsu.com>	<4934D27B.4020904@cn.fujitsu.com>	<20081202152129.d795da96.kamezawa.hiroyu@jp.fujitsu.com>	<4934DC34.7090406@cn.fujitsu.com> <20081202161346.f86db973.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202161346.f86db973.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Dec 2008 14:56:52 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 02 Dec 2008 14:15:23 +0800
>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>
>>>> KAMEZAWA Hiroyuki wrote:
>>>>> Now, final check of refcnt is done after pre_destroy(), so rmdir() can fail
>>>>> after pre_destroy().
>>>>> memcg set mem->obsolete to be 1 at pre_destroy and this is buggy..
>>>>>
>>>>> Several ways to fix this can be considered. This is an idea.
>>>>>
>>>> I don't see what's the difference with css_under_removal() in this patch and
>>>> cgroup_is_removed() which is currently available.
>>>>
>>>> CGRP_REMOVED flag is set in cgroup_rmdir() when it's confirmed that rmdir can
>>>> be sucessfully performed.
>>>>
>>>> So mem->obsolete can be replaced with:
>>>>
>>>> bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
>>>> {
>>>> 	return cgroup_is_removed(mem->css.cgroup);
>>>> }
>>>>
>>>> Or am I missing something?
>>>>
>>> Yes.
>>> 	1. "cgroup" and "css" object are different object.
>>> 	2. css object may not be freed at destroy() (as current memcg does.)
>>>
>>> Some of css objects cannot be freed even when there are no tasks because
>>> of reference from some persistent object or temporal refcnt.
>>>
>> I just noticed mem_cgroup has its own refcnt now. The memcg code has changed
>> dramatically that I don't catch up with it. Thx for the explanation.
>>
>> But I have another doubt:
>>
>> void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
>> {
>> 	struct mem_cgroup *memcg;
>>
>> 	memcg = __mem_cgroup_uncharge_common(page,
>> 					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
>> 	/* record memcg information */
>> 	if (do_swap_account && memcg) {
>> 		swap_cgroup_record(ent, memcg);
>> 		mem_cgroup_get(memcg);
>> 	}
>> }
>>
>> In the above code, is it possible that memcg is freed before mem_cgroup_get()
>> increases memcg->refcnt?
>>
> Thank you for looking into. maybe possible.
> 
> In this case, 
> 	1. "the page" was belongs to memcg before uncharge().
> 	2. but it's not guaranteed that memcg is alive after uncharge.
> 
> OK. maybe css_tryget() can change this to be
> ==
> 	rcu_read_lock();
> 	memcg = __mem_cgroup_uncharge_common(page,
> 					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
> 	if (do_swap_account && memcg && css_tryget(&memcg->css)) {
> 		swap_cgroup_record(ent, memcg);
> 		mem_cgroup_get(memcg);
> 		css_put(&memcg->css);
> 	}
> 	rcu_read_unlock();
> ==
> How about this ?
> 

Seems OK for me. Another way to fix this is, don't call css_put() if we want
to use the memcg returned from __mem_cgroup_uncharge_common(), I think this
is more reasonable:

--- a/mm/memcontrol.c.orig	2008-12-02 15:20:55.000000000 +0800
+++ b/mm/memcontrol.c	2008-12-02 15:28:07.000000000 +0800
@@ -1110,8 +1110,9 @@ void mem_cgroup_cancel_charge_swapin(str
 /*
  * uncharge if !page_mapped(page)
  */
-static struct mem_cgroup *
-__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
+static void
+__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
+			     struct mem_cgroup **memcg)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
@@ -1163,13 +1164,16 @@ __mem_cgroup_uncharge_common(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
-	css_put(&mem->css);
+	/* don't dec refcnt, since the caller want to use this memcg */
+	if (memcg)
+		*memcg = mem;
+	else
+		css_put(&mem->css);
 
-	return mem;
+	return;
 
 unlock_out:
 	unlock_page_cgroup(pc);
-	return NULL;
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -1197,12 +1201,13 @@ void mem_cgroup_uncharge_swapcache(struc
 {
 	struct mem_cgroup *memcg;
 
-	memcg = __mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+	__mem_cgroup_uncharge_common(page,
+				     MEM_CGROUP_CHARGE_TYPE_SWAPOUT, &memcg);
 	/* record memcg information */
 	if (do_swap_account && memcg) {
 		swap_cgroup_record(ent, memcg);
 		mem_cgroup_get(memcg);
+		css_put(&memcg->css);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
