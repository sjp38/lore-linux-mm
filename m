Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 9F8776B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 14:25:18 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6123004ghr.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 11:25:17 -0700 (PDT)
Date: Mon, 30 Jul 2012 11:25:13 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
Message-ID: <20120730182513.GC20067@google.com>
References: <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120719165046.GO24336@google.com>
 <1342799140.2583.6.camel@twins>
 <20120720200542.GD21218@google.com>
 <501231F0.8050505@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <501231F0.8050505@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, cgroups@vger.kernel.org, linux-mm@kvack.org, glommer@parallels.com

Hello,

On Fri, Jul 27, 2012 at 02:15:12PM +0800, Li Zefan wrote:
> The cgroup core was extracted from cpuset, so they are deeply tangled.
> 
> There are several issues to resolve with regard to removing cgroup lock from cpuset.
> 
> - there are places that the cgroup hierarchy is travelled. This should be
> easy, as cpuset can be made to maintain its hierarchy.

Or we can expose limited interface for traversal while protecting
hierarchy itself with smaller lock or make the hierarchy safe to
traverse with RCU read lock.

> - cpuset disallows clearing cpuset.mems/cpuset.cpus if the cgroup is not empty,
> which can be guaranteed only by cgroup lock.
>
> - cpuset disallows a task be attached to a cgroup with empty cpuset.mems/cpuset.cpus,
> which again can be guarantted only by cgroup lock.

Why can't callbacks enforce the above two?  We can keep track of the
number of tasks in the cgroup and reject operations as necessary.
What's missing?

> - cpuset may move tasks from a cgroup to another cgroup (Glauber mentioned this).

No idea about this one.  Why / how does this happen?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
