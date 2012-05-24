Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A1ADD6B00F6
	for <linux-mm@kvack.org>; Thu, 24 May 2012 18:57:29 -0400 (EDT)
Date: Thu, 24 May 2012 15:57:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
Message-Id: <20120524155727.dc6c839e.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, 24 May 2012 14:52:26 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

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
> 
>  - code: seperating hugetlb bits out from memcg bits to avoid growing 
>    mm/memcontrol.c beyond its current 5650 lines, and
> 
>  - performance: not incurring any overhead of enabling memcg for per-
>    page tracking that is unnecessary if users only want to limit hugetlb 
>    pages.
> 
> Kmem accounting and swap accounting is really a seperate topic and makes 
> sense to be incorporated directly into memcg because their usage is a 
> single number, the same is not true for hugetlb pages where charging one 
> 1GB page is not the same as charging 512 2M pages.  And we have no 
> usecases for wanting to track kmem or swap only without user page 
> tracking, what would be the point?
> 
> There's a reason we don't enable CONFIG_CGROUP_MEM_RES_CTLR in the 
> defconfig, we don't want the extra 1% metadata overhead of enabling it and 
> the potential performance regression from doing per-page tracking if we 
> only want to limit a global resource (hugetlb pages) to a set of tasks.
> 
> So please consider seperating this functionality out into its own cgroup, 
> there's no reason not to do it and it would benefit hugetlb users who 
> don't want to incur the disadvantages of enabling memcg entirely.

These arguments look pretty strong to me.  But poorly timed :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
