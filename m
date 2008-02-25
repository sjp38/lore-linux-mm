Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1P3T348032060
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:29:03 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1P3XEhB134706
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:33:14 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1P3Te4u023703
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:29:40 +1100
Message-ID: <47C234E9.3060303@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 08:54:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [0/7] introduction
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch series is for implementing radix-tree based page_cgroup.
> 
> This patch does
>   - remove page_cgroup member from struct page.
>   - add a lookup function get_page_cgroup(page).
> 
> And, by removing page_cgroup member, we'll have to change the whole lock rule.
> In this patch, page_cgroup is allocated on demand but not freed. (see TODO).
> 
> This is first trial and I hope I get advices, comments.
> 
> 
> Following is unix bench result under ia64/NUMA box, 8 cpu system. 
> (Shell Script 8 concurrent result was not available from unknown reason.)
> ./Run fstime execl shell C hanoi
> 
> == rc2 + CONFIG_CGROUP_MEM_CONT ==
> File Read 1024 bufsize 2000 maxblocks    937399.0 KBps  (30.0 secs, 3 samples)
> File Write 1024 bufsize 2000 maxblocks   323117.0 KBps  (30.0 secs, 3 samples)
> File Copy 1024 bufsize 2000 maxblocks    233737.0 KBps  (30.0 secs, 3 samples)
> Execl Throughput                           2418.7 lps   (29.7 secs, 3 samples)
> Shell Scripts (1 concurrent)               5506.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               988.3 lpm   (60.0 secs, 3 samples)
> C Compiler Throughput                       741.7 lpm   (60.0 secs, 3 samples)
> Recursion Test--Tower of Hanoi            74555.8 lps   (20.0 secs, 3 samples)
> 
> == rc2 + CONFIG_CGROUP_MEM_CONT + radix-tree based page_cgroup ==
> File Read 1024 bufsize 2000 maxblocks    966342.0 KBps  (30.0 secs, 2 samples)
> File Write 1024 bufsize 2000 maxblocks   316999.0 KBps  (30.0 secs, 2 samples)
> File Copy 1024 bufsize 2000 maxblocks    234167.0 KBps  (30.0 secs, 2 samples)
> Execl Throughput                           2410.5 lps   (29.8 secs, 2 samples)
> Shell Scripts (1 concurrent)               5505.0 lpm   (60.0 secs, 2 samples)
> Shell Scripts (8 concurrent)               1824.5 lpm   (60.0 secs, 2 samples)
> Shell Scripts (16 concurrent)               987.0 lpm   (60.0 secs, 2 samples)
> C Compiler Throughput                       742.5 lpm   (60.0 secs, 2 samples)
> Recursion Test--Tower of Hanoi            74335.6 lps   (20.0 secs, 2 samples)
> 

Hi, KAMEZAWA-San,

The results look quite good.

> looks good as first result.
> 
> Becaue today's my machine time is over, I post this now. I'll rebase this to
> rc3 and reflect comments in the next trial.
> 
> series of patches
> [1/8] --- defintions of header file. 
> [2/8] --- changes in charge/uncharge path and remove locks.
> [3/8] --- changes in page_cgroup_move_lists()
> [4/8] --- changes in page migration with page_cgroup
> [5/8] --- changes in force_empty
> [6/8] --- radix-tree based page_cgroup
> [7/8] --- (Optional) per-cpu fast lookup helper
> [8/8] --- (Optional) Use vmalloc for 64bit machines.
> 
> 
> TODO
>  - Move to -rc3 or -mm ?

I think -mm is better, since we have been pushing all the patches through -mm
and that way we'll get some testing before the patches go in as well.

>  - This patch series doesn't implement page_cgroup removal.
>    I consider it's worth tring to remove page_cgroup when the page is used for
>    HugePage or the page is offlined. But this will incease complexity. So, do later.

Why don't we remove the page_cgroup, what is the increased complexity? I'll take
a look into the patches.

>  - More perfomance measurement and brush codes up.
>  - Check lock dependency...Do more test.

I think we should work this out as well. Hugh is working on cleanup for locking
right now. I suspect that with the radix tree changes, there might a conflict
between your and hugh's work. I think for the moment, while we stabilize and get
the radix tree patches ready, we should get Hugh's cleanup in.

>  - Should I add smaller chunk size for page_cgroup ?
> 
> Thanks,
> -Kame
> 


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
