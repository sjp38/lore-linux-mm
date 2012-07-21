Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 216816B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 22:47:04 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8850623pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 19:47:03 -0700 (PDT)
Date: Fri, 20 Jul 2012 19:46:57 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
Message-ID: <20120721024657.GA7962@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com>
 <20120719113915.GC2864@tiehlicka.suse.cz>
 <87r4s8gcwe.fsf@skywalker.in.ibm.com>
 <20120719123820.GG2864@tiehlicka.suse.cz>
 <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <20120720080639.GC12434@tiehlicka.suse.cz>
 <87d33qmeb9.fsf@skywalker.in.ibm.com>
 <20120720195643.GC21218@google.com>
 <500A107D.9060404@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <500A107D.9060404@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello, Kamezawa-san.

On Sat, Jul 21, 2012 at 11:14:21AM +0900, Kamezawa Hiroyuki wrote:
> I'm sorry I misunderstand. The problem is following.
> 
>         CPU A                       CPU B
>     mutex_unlock()
>                                 mutex_lock()
>     ->pre_destroy()             attach task
>       commit res->usage=0       mutex_unlock()
>                                 increase res->usage
>                                 detach task
>     mutex_lock()
>     check css's refcount=0
>      ....continue destroy.
> 
> Now, I thinks memcg's check is not enough but putting the -EBUSY there
> not to forget this race.
> 
> 
> I think a patch to stop task-attach and create child cgroup if  CGRP_WAIT_ON_RMDIR
> is set is required. And that's enough..

The *ONLY* reason we're not marking the cgroup dead after the checking
whether the cgroup has children or task at the top of cgroup_rmdir()
is because memcg might fail ->pre_destroy() and cancel the cgroup
removal.  We can't commit to removal because memcg might fail.

Now, if memcg drops the deprecated behavior, we can simply commit to
removal *before* starting calling pre_destroy() and it doesn't matter
at all whether we hold cgroup_mutex across pre_destroy or not and
cgroup core will simply deny any addition to the cgroup committed to
death.  (and remove a handsome amount of ugly code in the process)

So, the *ONLY* reason this can't be fixed properly from cgroup core is
because memcg's pre_destory() might fail and it doesn't make much
sense to me to implement add a workaround at this point when the whole
problem will go away once memcg's pre_destroy() is updated.

So, please update memcg and drop the __DEPRECATED flag, so that the
cgroup core can drop at least this particular part of misdesign. :(

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
