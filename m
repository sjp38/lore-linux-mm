Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id BAF606B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 00:50:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3771A3EE0B6
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:50:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07FCC45DE5D
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:50:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D9645DE5A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:50:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C741DB803A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:50:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6878E1DB8052
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:50:03 +0900 (JST)
Date: Fri, 2 Mar 2012 14:48:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -V2 0/9] memcg: add HugeTLB resource tracking
Message-Id: <20120302144828.e985c63a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu,  1 Mar 2012 14:46:11 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Hi,
> 
> This patchset implements a memory controller extension to control
> HugeTLB allocations. It is similar to the existing hugetlb quota
> support in that, the limit is enforced at mmap(2) time and not at
> fault time. HugeTLB's quota mechanism limits the number of huge pages
> that can allocated per superblock.
> 

Thank you, I think memcg-extension is better than hugetlbfs cgroup.


> For shared mappings we track the regions mapped by a task along with the
> memcg. We keep the memory controller charged even after the task
> that did mmap(2) exits. Uncharge happens during truncate. For Private
> mappings we charge and uncharge from the current task cgroup.
> 

What "current" means here ? current task's cgroup ?


> A sample strace output for an application doing malloc with hugectl is given
> below. libhugetlbfs will fall back to normal pagesize if the HugeTLB mmap fails.
> 
> open("/mnt/libhugetlbfs.tmp.uhLMgy", O_RDWR|O_CREAT|O_EXCL, 0600) = 3
> unlink("/mnt/libhugetlbfs.tmp.uhLMgy")  = 0
> 
> .........
> 
> mmap(0x20000000000, 50331648, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = -1 ENOMEM (Cannot allocate memory)
> write(2, "libhugetlbfs", 12libhugetlbfs)            = 12
> write(2, ": WARNING: New heap segment map" ....
> mmap(NULL, 42008576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xfff946c0000
> ....
> 
> 
> Goals:
> 
> 1) We want to keep the semantic closer to hugelb quota support. ie, we want
>    to extend quota semantics to a group of tasks. Currently hugetlb quota
>    mechanism allows one to control number of hugetlb pages allocated per
>    hugetlbfs superblock.
> 
> 2) Applications using hugetlbfs always fallback to normal page size allocation when they
>    fail to allocate huge pages. libhugetlbfs internally handles this for malloc(3). We
>    want to retain this behaviour when we enforce the controller limit. ie, when huge page
>    allocation fails due to controller limit, applications should fallback to
>    allocation using normal page size. The above implies that we need to enforce
>    limit at mmap(2).
> 

Hm, ok. 

> 3) HugeTLBfs doesn't support page reclaim. It also doesn't support write(2). Applications
>    use hugetlbfs via mmap(2) interface. Important point to note here is hugetlbfs
>    extends file size in mmap.
> 
>    With shared mappings, the file size gets extended in mmap and file will remain in hugetlbfs
>    consuming huge pages until it is truncated. We want to make sure we keep the controller
>    charged until the file is truncated. This implies, that the controller will be charged
>    even after the task that did mmap exit.
> 

O.K. hugetlbfs is charged until the file is removed.
Then, next question will be 'can we destory cgroup....'

> Implementation details:
> 
> In order to achieve the above goals we need to track the cgroup information
> along with mmap range in a charge list in inode for shared mapping and in
> vm_area_struct for private mapping. We won't be using page to track cgroup
> information because with the above goals we are not really tracking the pages used.
> 
> Since we track cgroup in charge list, if we want to remove the cgroup, we need to update
> the charge list to point to the parent cgroup. Currently we take the easy route
> and prevent a cgroup removal if it's non reclaim resource usage is non zero.
> 

As Andrew pointed out, there are some ongoing works about page-range tracking.
Please check.

Thanks,
-Kame

> Changes from V1:
> * Changed the implementation as a memcg extension. We still use
>   the same logic to track the cgroup and range.
> 
> Changes from RFC post:
> * Added support for HugeTLB cgroup hierarchy
> * Added support for task migration
> * Added documentation patch
> * Other bug fixes
> 
> -aneesh
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
