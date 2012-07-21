Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CB9226B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 22:18:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C76D43EE0AE
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 11:18:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B01CA45DEB4
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 11:18:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BE0245DEB2
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 11:18:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88E4B1DB803E
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 11:18:45 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42D271DB8038
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 11:18:45 +0900 (JST)
Message-ID: <500A107D.9060404@jp.fujitsu.com>
Date: Sat, 21 Jul 2012 11:14:21 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz> <87r4s8gcwe.fsf@skywalker.in.ibm.com> <20120719123820.GG2864@tiehlicka.suse.cz> <87ipdjc15j.fsf@skywalker.in.ibm.com> <20120720080639.GC12434@tiehlicka.suse.cz> <87d33qmeb9.fsf@skywalker.in.ibm.com> <20120720195643.GC21218@google.com>
In-Reply-To: <20120720195643.GC21218@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2012/07/21 4:56), Tejun Heo wrote:
> On Sat, Jul 21, 2012 at 12:48:34AM +0530, Aneesh Kumar K.V wrote:
>> Does cgroup_rmdir do a cgroup_task_count check ? I do see that it check
>> cgroup->childern and cgroup->count. But cgroup->count is not same as
>> task_count right ?
>>
>> May be we need to push the task_count check also to rmdir so that
>> pre_destory doesn't need to check this
>
> task_count implies cgroup refcnt which cgroup core does check.  No
> need to worry about that, ->children or whatever from memcg.  As soon
> as the deprecated behavior is gone, everything will be okay;
> otherwise, it's a bug in cgroup core.
>

I'm sorry I misunderstand. The problem is following.

         CPU A                       CPU B
     mutex_unlock()
                                 mutex_lock()
     ->pre_destroy()             attach task
       commit res->usage=0       mutex_unlock()
                                 increase res->usage
                                 detach task
     mutex_lock()
     check css's refcount=0
      ....continue destroy.

Now, I thinks memcg's check is not enough but putting the -EBUSY there
not to forget this race.


I think a patch to stop task-attach and create child cgroup if  CGRP_WAIT_ON_RMDIR
is set is required. And that's enough..
Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
