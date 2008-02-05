Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m154GO7Z014091
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 15:16:24 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m154JASb243194
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 15:19:10 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m154FWo3012037
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 15:15:32 +1100
Message-ID: <47A7E282.1080902@linux.vnet.ibm.com>
Date: Tue, 05 Feb 2008 09:43:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] badness() dramatically overcounts memory
References: <1202182480.24634.22.camel@dogma.ljc.laika.com>
In-Reply-To: <1202182480.24634.22.camel@dogma.ljc.laika.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Davis <linux@j-davis.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Davis wrote:
> In oom_kill.c, one of the badness calculations is wildly inaccurate. If
> memory is shared among child processes, that same memory will be counted
> for each child, effectively multiplying the memory penalty by N, where N
> is the number of children.
> 
> This makes it almost certain that the parent will always be chosen as
> the victim of the OOM killer (assuming any substantial amount memory
> shared among the children), even if the parent and children are well
> behaved and have a reasonable and unchanging VM size.
> 
> Usually this does not actually alleviate the memory pressure because the
> truly bad process is completely unrelated; and the OOM killer must later
> kill the truly bad process.
> 
> This trivial patch corrects the calculation so that it does not count a
> child's shared memory against the parent.
> 

Hi, Jeff,

1. grep on the kernel source tells me that shared_vm is incremented only in
   vm_stat_account(), which is a NO-OP if CONFIG_PROC_FS is not defined.
2. How have you tested these patches? One way to do it would be to use the
   memory controller and set a small limit on the control group. A memory
   intensive application will soon see an OOM.

I do need to look at OOM kill sanity, my colleagues using the memory controller
have reported wrong actions taken by the OOM killer, but I am yet to analyze them.

The interesting thing is the use of total_vm and not the RSS which is used as
the basis by the OOM killer. I need to read/understand the code a bit more.

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
