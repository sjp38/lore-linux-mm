Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA25mLb2028639
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 16:48:21 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA25nhNX269252
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 16:49:43 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA25ng4H015053
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 16:49:43 +1100
Message-ID: <490D3F72.9040408@linux.vnet.ibm.com>
Date: Sun, 02 Nov 2008 11:19:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 2/4] Memory cgroup resource counters for hierarchy
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184837.2575.98059.sendpatchset@balbir-laptop> <20081102144237.59ab5f03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081102144237.59ab5f03.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 02 Nov 2008 00:18:37 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Add support for building hierarchies in resource counters. Cgroups allows us
>> to build a deep hierarchy, but we currently don't link the resource counters
>> belonging to the memory controller control groups, which are linked in
>> cgroup hiearchy. This patch provides the infrastructure for resource counters
>> that have the same hiearchy as their cgroup counter parts.
>>
>> These set of patches are based on the resource counter hiearchy patches posted
>> by Pavel Emelianov.
>>
>> NOTE: Building hiearchies is expensive, deeper hierarchies imply charging
>> the all the way up to the root. It is known that hiearchies are expensive,
>> so the user needs to be careful and aware of the trade-offs before creating
>> very deep ones.
>>
> ...isn't it better to add "root_lock" to res_counter rather than taking
> all levels of lock one by one ?
> 
>  spin_lock(&res_counter->hierarchy_root->lock);
>  do all charge/uncharge to hierarchy
>  spin_unlock(&res_counter->hierarchy_root->lock);
> 
> Hmm ?
> 

Good thought process, but that affects and adds code complexity for the case
when hierarchy is enabled/disabled. It is also inefficient, since all charges
will now contend on root lock, in the current process, it is step by step, the
contention only occurs on common parts of the hierarchy (root being the best case).

Thanks for the comments,

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
