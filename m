Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5U3lFYI026374
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:47:15 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U3kLWp3809302
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:46:21 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5U3kjUO023420
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:46:45 +1000
Message-ID: <4868572B.5070006@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 09:16:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 3/5] Replacement policy on heap overfull
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080627151838.31664.51492.sendpatchset@balbir-laptop> <6599ad830806270837t5f9df61cn665a88d3dd8746d4@mail.gmail.com>
In-Reply-To: <6599ad830806270837t5f9df61cn665a88d3dd8746d4@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Jun 27, 2008 at 8:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> This patch adds a policy parameter to heap_insert. While inserting an element
>> if the heap is full, the policy determines which element to replace.
>> The default earlier is now obtained by passing the policy as HEAP_REP_TOP.
>> The new HEAP_REP_LEAF policy, replaces a leaf node (the last element).
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/prio_heap.h |    9 ++++++++-
>>  kernel/cgroup.c           |    2 +-
>>  lib/prio_heap.c           |   31 +++++++++++++++++++++++--------
>>  3 files changed, 32 insertions(+), 10 deletions(-)
>>
>> diff -puN include/linux/prio_heap.h~prio_heap_replace_leaf include/linux/prio_heap.h
>> --- linux-2.6.26-rc5/include/linux/prio_heap.h~prio_heap_replace_leaf   2008-06-27 20:43:09.000000000 +0530
>> +++ linux-2.6.26-rc5-balbir/include/linux/prio_heap.h   2008-06-27 20:43:09.000000000 +0530
>> @@ -22,6 +22,11 @@ struct ptr_heap {
>>        int (*gt)(void *, void *);
>>  };
>>
>> +enum heap_replacement_policy {
>> +       HEAP_REP_LEAF,
>> +       HEAP_REP_TOP,
>> +};
> 
> Maybe "drop" rather than "replace"? HEAP_REP_TOP doesn't replace the
> top element if you insert a new higher element, it drops the top.
> 
> How about HEAP_DROP_LEAF and HEAP_DROP_MAX? You could also provide a
> HEAP_DROP_MIN with the caveat that it would take linear time.
> 
> Add comments here about what these mean?
> 

Sure, will do

>> +       if (policy == HEAP_REP_TOP)
> 
> switch() here?
> 

Can switch over

>> +               if (heap->gt(p, ptrs[0]))
>> +                       return p;
>> +
>> +       if (policy == HEAP_REP_LEAF) {
>> +               /* Heap insertion */
>> +               int pos = heap->size - 1;
>> +               res = ptrs[pos];
>> +               heap_insert_at(heap, p, pos);
>> +               return res;
>> +       }
>>
>>        /* Replace the current max and heapify */
>>        res = ptrs[0];
> 
> This should probably be in the arm dealing with
> HEAP_REP_TOP/HEAP_DROP_MAX since we only get here in that case.

I can do that, I'll need to rearrange the code and merge the condition above
with the ->gt check into HEAP_DROP_MAX

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
