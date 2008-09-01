Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m813feuA002171
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 13:41:40 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m813gkfb268060
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 13:42:47 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m813gkVR013212
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 13:42:46 +1000
Message-ID: <48BB64B5.4060208@linux.vnet.ibm.com>
Date: Mon, 01 Sep 2008 09:12:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <20080901113918.b6f05ca6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080901113918.b6f05ca6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 31 Aug 2008 23:17:56 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
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
>>
>> This is an initial RFC for comments
>>
>> TODOs
>>
>> 1. Test the page migration changes
>> 2. Test the performance impact of the patch/approach
>>
>> Comments/Reviews?
>>
> BTW, how deep this radix-tree on 4GB/32GB/64GB/256GB machine ?

Good Question,

My ball-park estimates are

number of pfns = RADIX_TREE_TAG_LONGS/(RADIX_TREE_TAG_LONGS - 1) *
(RADIX_TREE_LONGS^n - 1)

and "n" is the number we are looking for.

For a 64 bit system with 256 GB and 4KB page size, I've calculated it to be 9
levels deep.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
