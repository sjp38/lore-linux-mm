Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m819IoWj013035
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 19:18:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m819HQQl4026450
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 19:17:26 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m819HQqP005415
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 19:17:26 +1000
Message-ID: <48BBB326.3080505@linux.vnet.ibm.com>
Date: Mon, 01 Sep 2008 14:47:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <48BBAFDD.1000902@openvz.org>
In-Reply-To: <48BBAFDD.1000902@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> This is a rewrite of a patch I had written long back to remove struct page
>> (I shared the patches with Kamezawa, but never posted them anywhere else).
>> I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
>>
>> I've tested the patches on an x86_64 box, I've run a simple test running
>> under the memory control group and the same test running concurrently under
>> two different groups (and creating pressure within their groups). I've also
>> compiled the patch with CGROUP_MEM_RES_CTLR turned off.
>>
>> Advantages of the patch
>>
>> 1. It removes the extra pointer in struct page
>>
>> Disadvantages
>>
>> 1. It adds an additional lock structure to struct page_cgroup
>> 2. Radix tree lookup is not an O(1) operation, once the page is known
>>    getting to the page_cgroup (pc) is a little more expensive now.
> 
> And besides, we also have a global lock, that protects even lookup
> from this structure. Won't this affect us too much on bug-smp nodes?

Sorry, not sure I understand. The lookup is done under RCU. Updates are done
using the global lock. It should not be hard to make the radix tree per node
later (as an iterative refinement).

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
