Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m465ZZUS027012
	for <linux-mm@kvack.org>; Tue, 6 May 2008 11:05:35 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m465ZRlM1417288
	for <linux-mm@kvack.org>; Tue, 6 May 2008 11:05:27 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m465ZY8r013228
	for <linux-mm@kvack.org>; Tue, 6 May 2008 11:05:35 +0530
Message-ID: <481FEDEF.9030901@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 11:04:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213814.3140.66080.sendpatchset@localhost.localdomain> <20080505152451.6dceec74.akpm@linux-foundation.org>
In-Reply-To: <20080505152451.6dceec74.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 04 May 2008 03:08:14 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +	if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))
> 
> I worry a bit about all the conversion between page-counts and byte-counts
> in this code.
> 
> For example, what happens if a process sits there increasing its rss with
> sbrk(4095) or sbrk(4097) or all sorts of other scenarios?  Do we get in a
> situation in which the accounting is systematically wrong?
> 

We already do all our accounting in pages for total_vm (field of mm_struct).
task_vsize() for example multiplies PAGE_SIZE with total_vm before returning the
result.

> Worse, do we risk getting into that situation in the future, as unrelated
> changes are made to the surrounding code?
> 

I can't see that happening, but I'll look again and request reviewers to help me
identify any such problems that can occur.

> IOW, have we chosen the best, most maintainable representation for these
> things?
> 

That's a good question. From the sustenance point of view, resource counters
have worked really well so far. Abstracting accounting and tracking from the
controllers has been a good thing. One of the goals of the rlimit controller is
to keep it open for extension, so that others can add their own control for
other resources like mlock'ed pages.

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
