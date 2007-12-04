Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4DRbms018030
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 08:27:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4DRaxa129916
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 06:27:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4DRal4014699
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 06:27:36 -0700
Message-ID: <475555BA.7070805@linux.vnet.ibm.com>
Date: Tue, 04 Dec 2007 18:57:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [5/8] throttling simultaneous callers of try_to_free_mem_cgroup_pages
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com> <20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com> <20071203092418.58631593@bree.surriel.com> <20071204103332.ad4cf9b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071204103332.ad4cf9b5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 3 Dec 2007 09:24:18 -0500
> Rik van Riel <riel@redhat.com> wrote:
> 
>> On Mon, 3 Dec 2007 18:39:21 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>> Add throttling direct reclaim.
>>>
>>> Trying heavy workload under memory controller, you'll see too much
>>> iowait and system seems heavy. (This is not good.... memory controller
>>> is usually used for isolating system workload)
>>> And too much memory are reclaimed.
>>>
>>> This patch adds throttling function for direct reclaim.
>>> Currently, num_online_cpus/(4) + 1 threads can do direct memory reclaim
>>> under memory controller.
>> The same problems are true of global reclaim.
>>
>> Now that we're discussing this RFC anyway, I wonder if we
>> should think about moving this restriction to the global
>> reclaim level...
>>
> Hmm, I agree to some extent.
> I'd like to add the same level of parameters to memory controller AMAP.
> 

The CKRM memory controller had the following parameters for throttling

Watermarks

shrink_at
shrink_to

and

num_shrinks
shrink_interval

Number of times shrink can be called in a shrink_interval.


> But, IMHO, there are differences basically.
> 
> Memory controller's reclaim is much heavier than global LRU because of
> increasing footprint , the number of atomic ops....
> And memory controller's reclaim policy is simpler than global because
> it is not  kicked by memory shortage and almost all gfk_mask is GFP_HIGHUSER_MOVABLE
> and order is always 0.
> 
> I think starting from throttling memory controller is not so bad because 
> it's heavy and it's simple. The benefit of this throttoling is clearer than
> globals.
> 

I think global throttling is good as well, sometimes under heavy load I
find several tasks stuck in reclaim. I suspect throttling them and avoid
 this scenario. May be worth experimenting an thinking about it deserves
more discussion.

> Adding this kind of controls to global memory allocator/LRU may cause
> unexpected slow down in application's response time. High-response application
> users may dislike this. We may need another gfp_flag or sysctl to allow
> throttling in global.
> For memory controller, the user sets its memory limitation by himself. He can
> adjust parameters and the workload. So, I think this throttoling is not so
> problematic in memory controller as global.
> 
> Of course, we can export "do throttoling or not" control in cgroup interface.
> 

I think we should export the interface.

> 
> Thanks,
> -Kame 
> 

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
