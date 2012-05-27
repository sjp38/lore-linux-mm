Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 77A176B0082
	for <linux-mm@kvack.org>; Sun, 27 May 2012 16:29:06 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 May 2012 01:59:03 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4RKT0W764684170
	for <linux-mm@kvack.org>; Mon, 28 May 2012 01:59:00 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4S1wlWT005847
	for <linux-mm@kvack.org>; Mon, 28 May 2012 11:58:48 +1000
Date: Mon, 28 May 2012 01:58:48 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
Message-ID: <20120527202848.GC7631@skywalker.linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, May 24, 2012 at 02:52:26PM -0700, David Rientjes wrote:
> On Mon, 16 Apr 2012, Aneesh Kumar K.V wrote:
> 
> > This patch implements a memcg extension that allows us to control HugeTLB
> > allocations via memory controller. The extension allows to limit the
> > HugeTLB usage per control group and enforces the controller limit during
> > page fault. Since HugeTLB doesn't support page reclaim, enforcing the limit
> > at page fault time implies that, the application will get SIGBUS signal if it
> > tries to access HugeTLB pages beyond its limit. This requires the application
> > to know beforehand how much HugeTLB pages it would require for its use.
> > 
> > The charge/uncharge calls will be added to HugeTLB code in later patch.
> > Support for memcg removal will be added in later patches.
> > 
> 
> Again, I disagree with this approach because it's adding the functionality 
> to memcg when it's unnecessary; it would be a complete legitimate usecase 
> to want to limit the number of globally available hugepages to a set of 
> tasks without incurring the per-page tracking from memcg.
> 
> This can be implemented as a seperate cgroup and as we move to a single 
> hierarchy, you lose no functionality if you mount both cgroups from what 
> is done here.
> 
> It would be much cleaner in terms of
> 
>  - build: not requiring ifdefs and dependencies on CONFIG_HUGETLB_PAGE, 
>    which is a prerequisite for this functionality and is not for 
>    CONFIG_CGROUP_MEM_RES_CTLR,

I am not sure we have large number of #ifdef as you have outlined above.
Most of the hugetlb limit code is well isolated already. If we were to
split it as a seperate controller, we will be duplicating code related
cgroup deletion,  migration support etc from memcg, because in case
of memcg and hugetlb limit they depend on struct page. So I would expect
we would be end up #ifdef around that code or duplicate them in the
new controller if we were to do hugetlb limit as a seperate controller.

Another reason for it to be part of memcg is, it is normal to look
at hugetlb usage also as a memory usage. One of the feedback I got
for the earlier post is to see if i can enhace the current code to
make sure memory.usage_in_bytes can also account for hugetlb usage.
People would also like to look at memory.limit_in_bytes to limit total
usage. (inclusive of hugetlb).

> 
>  - code: seperating hugetlb bits out from memcg bits to avoid growing 
>    mm/memcontrol.c beyond its current 5650 lines, and
> 

I can definitely look at spliting mm/memcontrol.c 


>  - performance: not incurring any overhead of enabling memcg for per-
>    page tracking that is unnecessary if users only want to limit hugetlb 
>    pages.
> 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
