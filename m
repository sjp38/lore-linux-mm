Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80989C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 10:54:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 159D42070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 10:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 159D42070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D7DD6B0003; Fri,  6 Sep 2019 06:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9884A6B0006; Fri,  6 Sep 2019 06:54:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876736B0007; Fri,  6 Sep 2019 06:54:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 679596B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 06:54:34 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CEC724FED
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:54:33 +0000 (UTC)
X-FDA: 75904187226.29.angle56_27bd7241cc153
X-HE-Tag: angle56_27bd7241cc153
X-Filterd-Recvd-Size: 9087
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:54:32 +0000 (UTC)
Received: from [172.16.25.5]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1i6Bsr-0003t1-4a; Fri, 06 Sep 2019 13:54:29 +0300
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
To: Michal Hocko <mhocko@kernel.org>,
 Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
 <20190904112500.GO3838@dhcp22.suse.cz>
 <0056063b-46ff-0ebd-ff0d-c96a1f9ae6b1@i-love.sakura.ne.jp>
 <20190904142902.GZ3838@dhcp22.suse.cz>
 <405ce28b-c0b4-780c-c883-42d741ec60e0@i-love.sakura.ne.jp>
 <16fdbf78-3cf4-81cf-2a73-d38cb66afc17@gmail.com>
 <20190906072711.GD14491@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <940ea5a4-b580-34f8-2e5f-0bd2534b7426@virtuozzo.com>
Date: Fri, 6 Sep 2019 13:54:30 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190906072711.GD14491@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/6/19 10:27 AM, Michal Hocko wrote:
> On Fri 06-09-19 01:11:53, Thomas Lindroth wrote:
>> On 9/4/19 6:39 PM, Tetsuo Handa wrote:
>>> On 2019/09/04 23:29, Michal Hocko wrote:
>>>> Ohh, right. We are trying to uncharge something that hasn't been charged
>>>> because page_counter_try_charge has failed. So the fix needs to be more
>>>> involved. Sorry, I should have realized that.
>>>
>>> OK. Survived the test. Thomas, please try.
>>>
>>>> ---
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index 9ec5e12486a7..e18108b2b786 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -2821,6 +2821,16 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>>>>   	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
>>>>   	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
>>>> +
>>>> +		/*
>>>> +		 * Enforce __GFP_NOFAIL allocation because callers are not
>>>> +		 * prepared to see failures and likely do not have any failure
>>>> +		 * handling code.
>>>> +		 */
>>>> +		if (gfp & __GFP_NOFAIL) {
>>>> +			page_counter_charge(&memcg->kmem, nr_pages);
>>>> +			return 0;
>>>> +		}
>>>>   		cancel_charge(memcg, nr_pages);
>>>>   		return -ENOMEM;
>>>>   	}
>>>>
>>
>> I tried the patch with 5.2.11 and wasn't able to trigger any null pointer
>> deref crashes with it. Testing is tricky because the OOM killer will still
>> run and eventually kill bash and whatever runs in the cgroup.
> 
> Yeah, this is unfortunate but also unfixable I am afraid. 

I think there are two possible ways to fix this. If we decide to keep kmem.limit_in_bytes broken,
than we can just always bypass limit. Also we could add something like pr_warn_once("kmem limit doesn't work");
when user changes kmem.limit_in_bytes 


Or we can fix kmem.limit_in_bytes like this:


---
 mm/memcontrol.c | 76 +++++++++++++++++++++++++++++++------------------
 1 file changed, 48 insertions(+), 28 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2d1d598d9554..71b9065e4b31 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1314,7 +1314,7 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
  * Returns the maximum amount of memory @mem can be charged with, in
  * pages.
  */
-static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
+static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg, bool kmem)
 {
 	unsigned long margin = 0;
 	unsigned long count;
@@ -1334,6 +1334,15 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 			margin = 0;
 	}
 
+	if (kmem && margin) {
+		count = page_counter_read(&memcg->kmem);
+		limit = READ_ONCE(memcg->kmem.max);
+		if (count <= limit)
+			margin = min(margin, limit - count);
+		else
+			margin = 0;
+	}
+
 	return margin;
 }
 
@@ -2505,7 +2514,7 @@ void mem_cgroup_handle_over_high(void)
 }
 
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-		      unsigned int nr_pages)
+		      unsigned int nr_pages, bool kmem_charge)
 {
 	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -2519,21 +2528,42 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_is_root(memcg))
 		return 0;
 retry:
-	if (consume_stock(memcg, nr_pages))
+	if (consume_stock(memcg, nr_pages)) {
+		if (kmem_charge && !page_counter_try_charge(&memcg->kmem,
+							nr_pages, &counter)) {
+			refill_stock(memcg, nr_pages);
+			goto charge;
+		}
 		return 0;
+	}
 
+charge:
+	mem_over_limit = NULL;
 	if (!do_memsw_account() ||
 	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
-		if (page_counter_try_charge(&memcg->memory, batch, &counter))
-			goto done_restock;
-		if (do_memsw_account())
-			page_counter_uncharge(&memcg->memsw, batch);
-		mem_over_limit = mem_cgroup_from_counter(counter, memory);
+		if (!page_counter_try_charge(&memcg->memory, batch, &counter)) {
+			if (do_memsw_account())
+				page_counter_uncharge(&memcg->memsw, batch);
+			mem_over_limit = mem_cgroup_from_counter(counter, memory);
+		}
 	} else {
 		mem_over_limit = mem_cgroup_from_counter(counter, memsw);
 		may_swap = false;
 	}
 
+	if (!mem_over_limit && kmem_charge) {
+		if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
+			may_swap = false;
+			mem_over_limit = mem_cgroup_from_counter(counter, kmem);
+			page_counter_uncharge(&memcg->memory, batch);
+			if (do_memsw_account())
+				page_counter_uncharge(&memcg->memsw, batch);
+		}
+	}
+
+	if (!mem_over_limit)
+		goto done_restock;
+
 	if (batch > nr_pages) {
 		batch = nr_pages;
 		goto retry;
@@ -2568,7 +2598,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
 						    gfp_mask, may_swap);
 
-	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
+	if (mem_cgroup_margin(mem_over_limit, kmem_charge) >= nr_pages)
 		goto retry;
 
 	if (!drained) {
@@ -2637,6 +2667,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	page_counter_charge(&memcg->memory, nr_pages);
 	if (do_memsw_account())
 		page_counter_charge(&memcg->memsw, nr_pages);
+	if (kmem_charge)
+		page_counter_charge(&memcg->kmem, nr_pages);
 	css_get_many(&memcg->css, nr_pages);
 
 	return 0;
@@ -2943,20 +2975,8 @@ void memcg_kmem_put_cache(struct kmem_cache *cachep)
 int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			    struct mem_cgroup *memcg)
 {
-	unsigned int nr_pages = 1 << order;
-	struct page_counter *counter;
-	int ret;
-
-	ret = try_charge(memcg, gfp, nr_pages);
-	if (ret)
-		return ret;
-
-	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
-	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
-		cancel_charge(memcg, nr_pages);
-		return -ENOMEM;
-	}
-	return 0;
+	return try_charge(memcg, gfp, 1 << order,
+			!cgroup_subsys_on_dfl(memory_cgrp_subsys));
 }
 
 /**
@@ -5053,7 +5073,7 @@ static int mem_cgroup_do_precharge(unsigned long count)
 	int ret;
 
 	/* Try a single bulk charge without reclaim first, kswapd may wake */
-	ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_DIRECT_RECLAIM, count);
+	ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_DIRECT_RECLAIM, count, false);
 	if (!ret) {
 		mc.precharge += count;
 		return ret;
@@ -5061,7 +5081,7 @@ static int mem_cgroup_do_precharge(unsigned long count)
 
 	/* Try charges one by one with reclaim, but do not retry */
 	while (count--) {
-		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
+		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1, false);
 		if (ret)
 			return ret;
 		mc.precharge++;
@@ -6255,7 +6275,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
 
-	ret = try_charge(memcg, gfp_mask, nr_pages);
+	ret = try_charge(memcg, gfp_mask, nr_pages, false);
 
 	css_put(&memcg->css);
 out:
@@ -6634,10 +6654,10 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 
 	mod_memcg_state(memcg, MEMCG_SOCK, nr_pages);
 
-	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
+	if (try_charge(memcg, gfp_mask, nr_pages, false) == 0)
 		return true;
 
-	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
+	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages, false);
 	return false;
 }
 
-- 
2.21.0

