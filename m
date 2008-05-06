Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m465mLnn007462
	for <linux-mm@kvack.org>; Tue, 6 May 2008 15:48:21 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m465r0VO233810
	for <linux-mm@kvack.org>; Tue, 6 May 2008 15:53:00 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m465mvPi014480
	for <linux-mm@kvack.org>; Tue, 6 May 2008 15:48:58 +1000
Message-ID: <481FF115.8030503@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 11:18:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
References: <20080506142255.AC5D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080506142255.AC5D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> on CONFIG_MM_OWNER=y (that is automatically turned on by mem-cgroup),
> kernel panic is possible by following scenario in mm_update_next_owner().
> 
> 1. mm_update_next_owner() is called.
> 2. found caller task in do_each_thread() loop.
> 3. thus, BUG_ON(c == p) is true, it become kernel panic.
> 
> end up, We should left out current task.
> 
> 

That is not possible. If you look at where mm_update_next_owner() is called
from, we call it from

exit_mm() and exec_mmap()

In both cases, we ensure that the task's mm has changed (to NULL and the new mm
respectively), before we call mm_update_next_owner(), hence c->mm can never be
equal to p->mm.

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
