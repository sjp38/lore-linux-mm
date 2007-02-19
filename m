Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JAGalP283182
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:16:39 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JA4HRT069788
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:04:18 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JA0liT011860
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:00:47 +1100
Message-ID: <45D97547.3000502@in.ibm.com>
Date: Mon, 19 Feb 2007 15:30:39 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH][0/4] Memory controller (RSS Control)
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219005441.7fa0eccc.akpm@linux-foundation.org>
In-Reply-To: <20070219005441.7fa0eccc.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 19 Feb 2007 12:20:19 +0530 Balbir Singh <balbir@in.ibm.com> wrote:
> 
>> This patch applies on top of Paul Menage's container patches (V7) posted at
>>
>> 	http://lkml.org/lkml/2007/2/12/88
>>
>> It implements a controller within the containers framework for limiting
>> memory usage (RSS usage).
> 
> It's good to see someone building on someone else's work for once, rather
> than everyone going off in different directions.  It makes one hope that we
> might actually achieve something at last.
> 

Thanks! It's good to know we are headed in the right direction.

> 
> The key part of this patchset is the reclaim algorithm:
> 
>> @@ -636,6 +642,15 @@ static unsigned long isolate_lru_pages(u
>>  
>>  		list_del(&page->lru);
>>  		target = src;
>> +		/*
>> + 		 * For containers, do not scan the page unless it
>> + 		 * belongs to the container we are reclaiming for
>> + 		 */
>> +		if (container && !page_in_container(page, zone, container)) {
>> +			scan--;
>> +			goto done;
>> +		}
> 
> Alas, I fear this might have quite bad worst-case behaviour.  One small
> container which is under constant memory pressure will churn the
> system-wide LRUs like mad, and will consume rather a lot of system time. 
> So it's a point at which container A can deleteriously affect things which
> are running in other containers, which is exactly what we're supposed to
> not do.
> 

Hmm.. I guess it's space vs time then :-) A CPU controller could
control how much time is spent reclaiming ;)

Coming back, I see the problem you mentioned and we have been thinking
of several possible solutions. In my introduction I pointed out

    "Come up with cool page replacement algorithms for containers
    (if possible without any changes to struct page)"


The solutions we have looked at are

1. Overload the LRU list_head in struct page to have a global
    LRU + a per container LRU

+------+           prev       +------+
| page +--------------------->| page +---------
|  0   |<---------------------+  1   |<--------
+------+           next       +------+

                  Global LRU

             +------+
    +------- + prev |
    |        | next +-------------------------------------------+
    |        +------+                                           |
    V            ^                                              V
+------+        |  prev       +------+                     +------+
| page +        +------------ + page +---------.....       | page +
|  0   |--------------------->+  1   |<--------            |  n   |
+------+           next       +------+                     +------+

                  Global LRU + Container LRU


Page 1 and n belong to the same container, to get to page 0, you need
two de-references


2. Modify struct page to point to a container and allow each container to
    have a per-container LRU along with the global LRU


For efficiency we need the container LRU and we don't want to split
the global LRU either.

We need to optimize the reclaim path, but I thought of that as a secondary
problem. Once we all agree that the controller looks simple, accounts well
and works. We can/should definitely optimize the reclaim path.


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
