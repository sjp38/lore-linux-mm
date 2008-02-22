Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1MCZ5gK009285
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 23:35:05 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1MCX1lB2990254
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 23:33:01 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1MCX5Ac006600
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 23:33:05 +1100
Message-ID: <47BEBFE5.9000905@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2008 17:58:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp> <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802220916290.18145@blonde.site> <47BEAEA9.10801@linux.vnet.ibm.com> <Pine.LNX.4.64.0802221144210.379@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802221144210.379@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 22 Feb 2008, Balbir Singh wrote:
>> I've been looking through the code time and again, looking for races. I will try
> 
> Well worth doing.
> 

Yes. I agree 100%. Unfortunately I am not a spin expert and modeling it that way
takes longer than reviewing it a few times.

>> and build a sketch of all the functions and dependencies tonight. One thing that
>> struck me was that making page_get_page_cgroup() call lock_page_cgroup()
>> internally might potentially fix a lot of racy call sites. I was thinking of
>> splitting page_get_page_cgroup into __page_get_page_cgroup() <--> just get the
>> pc without lock and page_get_page_cgroup(), that holds the lock and then returns pc.
> 
> I don't think that would help.  One of the problems with what's there
> (before my patches) is how, for example, clear_page_cgroup takes the
> lock itself - forcing you into dropping the lock before calling it
> (you contemplate keeping an __ which doesn't take the lock, but then
> I cannot see the point).
> 

I just proposed the __ version in case there was a reason. If we can get away
from it, I'll not add __page_get_page_cgroup at all.

> What's there after the patches looks fairly tidy and straightforward
> to me, but emphasize "fairly".  (Often I think there's a race against
> page->page_cgroup going NULL, but then realize that pc->page remains
> stable and there's no such race.)
> 

I agree, I find some of the refactoring very welcome! I did a quick code check
and found that almost instances of cases, where we were worried about pc, called
page_get_page_cgroup() at some point. I thought this might be a good common
place to attack and fix.

>> Of course, this is just a thought process. I am yet to write the code and look
>> at the results.
> 
> I'd hoped to send out my series last night, but was unable to get
> quite that far, sorry, and haven't tested the page migration paths yet.
> The total is not unlike what I already showed, but plus Hirokazu-san's
> patch and minus shmem's NULL page and minus my rearrangement of
> mem_cgroup_charge_common.
> 

Do let me know when you'll have a version to test, I can run LTP, LTP stress and
other tests overnight.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
