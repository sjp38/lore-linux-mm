Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 34DB66B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 14:47:54 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p75IYklT004587
	for <linux-mm@kvack.org>; Fri, 5 Aug 2011 14:34:46 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p75Ilp03225592
	for <linux-mm@kvack.org>; Fri, 5 Aug 2011 14:47:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p75Eld86021010
	for <linux-mm@kvack.org>; Fri, 5 Aug 2011 11:47:39 -0300
Message-ID: <4E3C3AD4.6000306@linux.vnet.ibm.com>
Date: Fri, 05 Aug 2011 13:47:48 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 0/4] mm: frontswap: overview
References: <20110527194804.GA27109@ca-server1.us.oracle.com 4E3C1292.9080506@linux.vnet.ibm.com> <94c9f8f7-4ea0-44ce-9938-85e31867b8fe@default>
In-Reply-To: <94c9f8f7-4ea0-44ce-9938-85e31867b8fe@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, ngupta@vflare.org, Brian King <brking@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>

On 08/05/2011 01:26 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Sent: Friday, August 05, 2011 9:56 AM
>> To: Dan Magenheimer
>> Cc: linux-mm@kvack.org; ngupta@vflare.org; Brian King
>> Subject: Re: [PATCH V4 0/4] mm: frontswap: overview
>>
>> Dan,
>>
>> What is the plan for getting this upstream?  Are there some issues or objections that haven't been
>> addressed?
>> --
>> Seth
> 
> Hi Seth --
> 
> The only significant objection I'm aware of is that there hasn't been
> a strong demand for frontswap yet, partly due to the fact that most
> of the interested parties have been communicating offlist.
> 
> Can I take this email as an "Acked-by"?  I will be posting V5
> next week (V4->V5: an allocation-time bug fix by Bob Liu, a
> handful of syntactic clarifications reported by Konrad Wilk,
> and rebase to linux-3.1-rc1.)  Soon after, V5 will be in linux-next
> and I plan to lobby the relevant maintainers to merge frontswap
> for the linux-3.2 window... and would welcome your public support.

Yes, this is something we want to get upstream.  So consider this 
an "Acked-by".

There was also a build break in the frontswap v4 patches:
  CC      mm/swapfile.o
mm/swapfile.c: In function ?enable_swap_info?:
mm/swapfile.c:1549:21: error: ?frontswap_map? undeclared (first use in this function)
mm/swapfile.c:1549:21: note: each undeclared identifier is reported only once for each function it appears in

I patched it with:

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 160261c..f358763 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1546,7 +1546,6 @@ static void enable_swap_info(struct swap_info_struct *p, i
        else
                p->prio = --least_priority;
        p->swap_map = swap_map;
-       p->frontswap_map = frontswap_map;
        p->flags |= SWP_WRITEOK;
        nr_swap_pages += p->pages;
        total_swap_pages += p->pages;
@@ -2153,6 +2152,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, 
                prio =
                  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
        enable_swap_info(p, prio, swap_map);
+       p->frontswap_map = frontswap_map;
 
        printk(KERN_INFO "Adding %uk swap on %s.  "
                        "Priority:%d extents:%d across:%lluk %s%s%s\n",

Also had a merge conflict in mm/swapfile.c when rebasing to 3.0+
with this commit:

commit 72788c385604523422592249c19cba0187021e9b
Author: David Rientjes <rientjes@google.com>
Date:   Tue May 24 17:11:40 2011 -0700

    oom: replace PF_OOM_ORIGIN with toggling oom_score_adj

git describe 72788c385604523422592249c19cba0187021e9b
v2.6.39-5681-g72788c3

A rebasing the patches to 3.0+ should fix that though.

Thanks Dan!

--
Seth

> 
> Thanks,
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
