Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m262ssLF023391
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 02:54:54 GMT
Received: from el-out-1112.google.com (eleo28.prod.google.com [10.126.166.28])
	by zps19.corp.google.com with ESMTP id m262snLS006021
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 18:54:53 -0800
Received: by el-out-1112.google.com with SMTP id o28so2563044ele.3
        for <linux-mm@kvack.org>; Wed, 05 Mar 2008 18:54:53 -0800 (PST)
Message-ID: <6599ad830803051854x5ee204bej7212d9c1e444e4d0@mail.gmail.com>
Date: Wed, 5 Mar 2008 18:54:52 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: Supporting overcommit with the memory controller
In-Reply-To: <20080306100158.a521af1b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6599ad830803051617w7835d9b2l69bbc1a0423eac41@mail.gmail.com>
	 <20080306100158.a521af1b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Linux Containers <containers@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 5, 2008 at 5:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  > But to make this more interesting, there are plenty of jobs that will
>  > happily fill as much pagecache as they have available. Even a job
>  > that's just writing out logs will continually expand its pagecache
>  > usage without anything to stop it, and so just keeping the reserved
>  > pool at a fixed amount of free memory will result in the job expanding
>  > even if it doesn't need to.
>  It's current memory management style. "reclaim only when necessary".
>

Exactly - if the high-priority latency-sensitive job really needs that
extra memory, we want it to be able to automatically squash/kill the
low-priority job when memory runs low, and not suffer any latency
spikes. But if it doesn't actually need the memory, we'd rather use it
for low-priority batch stuff. The "no latency spikes" bit is important
- we don't want the high-priority job to get bogged down in
try_to_free_pages() and out_of_memory() loops when it needs to
allocate memory.

>  >
>  Can Balbir's soft-limit patches help ?
>
>  It reclamims each cgroup's pages to soft-limit if the system needs.
>
>  Make limitation  like this
>
>  Assume 4G server.
>                            Limit      soft-limit
>  Not important Apss:         2G          100M
>  Important Apps    :         3G          2.7G
>
>  When the system memory reachs to the limit, each cgroup's memory usages will
>  goes down to soft-limit. (And there will 1.3G of free pages in above example)
>

Yes, that could be a useful part of the solution - I suspect we'd need
to have kswapd do the soft-limit push back as well as in
try_to_free_pages(), to avoid the high-priority jobs getting stuck in
the reclaim code. It would also be nice if we had:

- a way to have the soft-limit pushing kick in substantially *before*
the machine ran out of memory, to provide a buffer for the
high-priority jobs.

- a way to measure the actual working set of a cgroup (which may be
smaller than its allocated memory if it has plenty of stale pagecache
pages allocated). Maybe refaults, or maybe usage-based information.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
