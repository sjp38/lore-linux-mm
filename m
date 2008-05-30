Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4UMM7dU016852
	for <linux-mm@kvack.org>; Sat, 31 May 2008 03:52:07 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4UMLj5M897272
	for <linux-mm@kvack.org>; Sat, 31 May 2008 03:51:45 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4UMM7g8013806
	for <linux-mm@kvack.org>; Sat, 31 May 2008 03:52:07 +0530
Message-ID: <48407DC3.8060001@linux.vnet.ibm.com>
Date: Sat, 31 May 2008 03:50:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
References: <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch tries to implements _simple_ 'hierarchy policy' in res_counter.
> 
> While several policy of hierarchy can be considered, this patch implements
> simple one 
>    - the parent includes, over-commits the child
>    - there are no shared resource

I am not sure if this is desirable. The concept of a hierarchy applies really
well when there are shared resources.

>    - dynamic hierarchy resource usage management in the kernel is not necessary
> 

Could you please elaborate as to why? I am not sure I understand your point

> works as following.
> 
>  1. create a child. set default child limits to be 0.
>  2. set limit to child.
>     2-a. before setting limit to child, prepare enough room in parent.
>     2-b. increase 'usage' of parent by child's limit.

The problem with this is that you are forcing the parent will run into a reclaim
loop even if the child is not using the assigned limit to it.

>  3. the child sets its limit to the val moved from the parent.
>     the parent remembers what amount of resource is to the children.
> 

All of this needs to be dynamic

>  Above means that
> 	- a directory's usage implies the sum of all sub directories +
>           own usage.
> 	- there are no shared resource between parent <-> child.
> 
>  Pros.
>   - simple and easy policy.
>   - no hierarchy overhead.
>   - no resource share among child <-> parent. very suitable for multilevel
>     resource isolation.

Sharing is an important aspect of hierachies. I am not convinced of this
approach. Did you look at the patches I sent out? Was there something
fundamentally broken in them?

[snip]

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
