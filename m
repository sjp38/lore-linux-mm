Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEC06001DA
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 01:29:17 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1D6TAXL026837
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 11:59:10 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1D6T9Lj2568308
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 11:59:10 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1D6T9GB018208
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 17:29:09 +1100
Date: Sat, 13 Feb 2010 11:59:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
Message-ID: <20100213062905.GF11364@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4B71927D.6030607@nortel.com>
 <20100210093140.12D9.A69D9226@jp.fujitsu.com>
 <4B72E74C.9040001@nortel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B72E74C.9040001@nortel.com>
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Chris Friesen <cfriesen@nortel.com> [2010-02-10 11:05:16]:

> On 02/09/2010 06:32 PM, KOSAKI Motohiro wrote:
> 
> > can you please post your /proc/meminfo?
> 
> 
> On 02/09/2010 09:50 PM, Balbir Singh wrote:
> > Do you have swap enabled? Can you help with the OOM killed dmesg log?
> > Does the situation get better after OOM killing.
> 
> 
> On 02/09/2010 10:09 PM, KOSAKI Motohiro wrote:
> 
> > Chris, 2.6.27 is a bit old. plese test it on latest kernel. and please
> don't use
> > any proprietary drivers.
> 
> 
> Thanks for the replies.
> 
> Swap is enabled in the kernel, but there is no swap configured.  ipcs
> shows little consumption there.

OK, I did not find the OOM kill output, dmesg. Is the OOM killer doing
the right thing? If it kills the process we suspect is leaking memory,
then it is working correctly :) If the leak is in kernel space, we
need to examine the changes more closely.

> 
> The test load relies on a number of kernel modifications, making it
> difficult to use newer kernels. (This is an embedded system.)  There are
> no closed-source drivers loaded, though there are some that are not in
> vanilla kernels.  I haven't yet tried to reproduce the problem with a
> minimal load--I've been more focused on trying to understand what's
> going on in the code first.  It's on my list to try though.
> 

kernel modifications that we are unaware of make the problem harder to
debug, since we have no way of knowing if they are the source of the
problem.

> Here are some /proc/meminfo outputs from a test run where we
> artificially chewed most of the free memory to try and force the oom
> killer to fire sooner (otherwise it takes days for the problem to trigger).
> 
> It's spaced with tabs so I'm not sure if it'll stay aligned.  The first
> row is the sample number.  All the HugePages entries were 0.  The
> DirectMap entries were constant. SwapTotal/SwapFree/SwapCached were 0,
> as were Writeback/NFS_Unstable/Bounce/WritebackTmp.
> 
> Samples were taken 10 minutes apart.  Between samples 49 and 50 the
> oom-killer fired.
> 
> 		13		49		50
> MemTotal	4042848		4042848		4042848
> MemFree		113512		52668		69536
> Buffers		20		24		76
> Cached		1285588		1287456		1295128
> Active		2883224		3369440		2850172
> Inactive	913756		487944		990152
> Dirty		36		216		252
> AnonPages	2274756		2305448		2279216
> Mapped		10804		12772		15760
> Slab		62324		62568		63608
> SReclaimable	24092		23912		24848
> SUnreclaim	38232		38656		38760
> PageTables	11960		12144		11848
> CommitLimit	2021424		2021424		2021424
> Committed_AS	12666508	12745200	7700484

Comitted_AS shows a large change, does the process that gets killed
use a lot of virtual memory (total_vm)? Please see my first question
as well. Can you try to set

vm.overcommit_memory=2

and run the tests to see if you still get OOM killed.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
