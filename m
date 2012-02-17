Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 50E476B007E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 03:04:10 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 17 Feb 2012 13:34:04 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1H83ubP4091934
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 13:33:57 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1H83sIU027697
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:03:55 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/6] hugetlbfs: Add cgroup resource controller for hugetlbfs
In-Reply-To: <20120214155843.42a090c2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120214155843.42a090c2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 17 Feb 2012 13:33:38 +0530
Message-ID: <87d39devj9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>


Hi Kamezawa,

Sorry for the late response as I was out of office for last few days.

On Tue, 14 Feb 2012 15:58:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sat, 11 Feb 2012 03:06:40 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > Hi,
> > 
> > This patchset implements a cgroup resource controller for HugeTLB pages.
> > It is similar to the existing hugetlb quota support in that the limit is
> > enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
> > number of huge pages that can be allocated per superblock.
> > 
> > For shared mapping we track the region mapped by a task along with the
> > hugetlb cgroup in inode region list. We keep the hugetlb cgroup charged
> > even after the task that did mmap(2) exit. The uncharge happens during
> > file truncate. For Private mapping we charge and uncharge from the current
> > task cgroup.
> > 
> 
> Hm, Could you provide an Documenation/cgroup/hugetlb.txt at RFC ?
> It makes clear what your patch does.

Will do in the next iteration.

> 
> I wonder whether this should be under memory cgroup or not. In the 1st design
> of cgroup, I think it was considered one-feature-one-subsystem was good.
> 
> But in recent discussion, I tend to hear that's hard to use.
> Now, memory cgroup has 
> 
>    memory.xxxxx for controlling anon/file
>    memory.memsw.xxxx for controlling memory+swap
>    memory.kmem.tcp_xxxx for tcp controlling.
> 
> How about memory.hugetlb.xxxxx ?
> 

That is how i did one of the earlier version of the patch. But there are
few difference with the way we want to control hugetlb allocation. With
hugetlb cgroup, we actually want to enable application to fall back to
using normal pagesize if we are crossing cgroup limit. ie, we need to
enforce the limit during mmap. memcg tracks cgroup details along
with pages, hence implementing above gets challenging. Another
difference is we keep the cgroup charged even if the task exit as long as
the file is present in hugetlbfs. ie, if an application did mmap with
MAP_SHARED in hugetlbfs, the file size will be extended to the requested
length arg in mmap. This file will consume pages from hugetlb resource
until it is truncated. We want to track that resource usage as a part
of hugetlb cgroup. 

>From the interface point of view what we have in hugetlb cgroup is
similar to what is in memcg. We end up with files like the below

hugetlb.16GB.limit_in_bytes
hugetlb.16GB.max_usage_in_bytes 
hugetlb.16GB.usage_in_bytes
hugetlb.16MB.limit_in_bytes
hugetlb.16MB.max_usage_in_bytes  
hugetlb.16MB.usage_in_bytes

> 
> > The current patchset doesn't support cgroup hierarchy. We also don't
> > allow task migration across cgroup.
> 
> What happens when a user destroys a cgroup which contains alive hugetlb pages ?
> 
> Thanks,
> -Kame
> 

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
