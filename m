Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R4XUpR005021
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 10:03:30 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R4XUEh954544
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 10:03:30 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R4XZ1N031772
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 04:33:35 GMT
Message-ID: <47C4E6CD.6090401@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 09:57:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] page reclaim throttle take2
References: <20080226104647.FF26.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1204060718.6242.333.camel@lappy> <20080227131939.4244.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080227131939.4244.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi Peter,
> 
>>> +
>>> +	atomic_t		nr_reclaimers;
>>> +	wait_queue_head_t	reclaim_throttle_waitq;
>>>  	/*
>>>  	 * rarely used fields:
>>>  	 */
>> Small nit, that extra blank line seems at the wrong end of the text
>> block :-)
> 
> Agghhh, sorry ;-)
> I'll fix at next post.
> 
>>> +out:
>>> +	atomic_dec(&zone->nr_reclaimers);
>>> +	wake_up_all(&zone->reclaim_throttle_waitq);
>>> +
>>> +	return ret;
>>> +}
>> Would it be possible - and worthwhile - to make this FIFO fair?
> 
> Hmmm
> may be, we don't need perfectly fair.
> because try_to_free_page() is unfair mechanism.
> 
> but I will test use wake_up() instead wake_up_all().
> it makes so so fair order if no performance regression happend.
> 
> Thanks very useful comment.

One more thing, I would request you to add default heuristics (number of
reclaimers), based on the number of cpus in the system. Letting people tuning it
is fine, but defaults should be related to number of cpus, nodes and zones on
the system. Zones can be reaped in parallel per node and cpus allow threads to
run in parallel. So please use that to come up with good defaults, instead of a
number like "3".

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
