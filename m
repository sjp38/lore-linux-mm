Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A6F566B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:30:20 -0400 (EDT)
Received: by iajr24 with SMTP id r24so204780iaj.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:30:20 -0700 (PDT)
Date: Thu, 26 Apr 2012 15:30:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 3.4-rc4 oom killer out of control.
In-Reply-To: <20120426205320.GA30741@redhat.com>
Message-ID: <alpine.DEB.2.00.1204261522450.28376@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com> <20120426205320.GA30741@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 26 Apr 2012, Dave Jones wrote:

> I rebooted, and reran the test, and within minutes, got it into a state
> where it was killing things again fairly quickly.
> This time however, it seems to have killed almost everything on the box,
> but is still alive. The problem is that all the memory is eaten up by
> something, and kswapd/ksmd is eating all the cpu.
> (Attempting to profile with perf causes perf to be oom-killed).
> 

That makes sense since the oom killer will go along killing all user 
processes and will leave kthreads such as kswapd and ksmd alone; them 
using all of the cpu then, especially kswapd aggressively trying to 
reclaim memory, would be typical.

> A lot of VMAs in slab..
> 
>  Active / Total Objects (% used)    : 467327 / 494733 (94.5%)
>  Active / Total Slabs (% used)      : 18195 / 18195 (100.0%)
>  Active / Total Caches (% used)     : 145 / 207 (70.0%)
>  Active / Total Size (% used)       : 241177.72K / 263399.54K (91.6%)
>  Minimum / Average / Maximum Object : 0.33K / 0.53K / 9.16K
> 
>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME    
> 213216 213167  99%    0.49K   6663       32    106608K vm_area_struct
>  74718  74674  99%    0.37K   3558       21     28464K anon_vma_chain
>  37820  37663  99%    0.52K   1220       31     19520K anon_vma
>  33263  33188  99%    0.51K   1073       31     17168K kmalloc-192

This all depends on the workload, but these numbers don't look 
particularly surprising.

> active_anon:1565586 inactive_anon:283198 isolated_anon:0
>  active_file:241 inactive_file:505 isolated_file:0
>  unevictable:1414 dirty:14 writeback:0 unstable:0
>  free:25817 slab_reclaimable:10704 slab_unreclaimable:56662
>  mapped:262 shmem:45 pagetables:45795 bounce:0

You have ~7GB of an 8GB macine consumed by anonymous memory, 100MB isn't 
allocatable probably because of /proc/sys/vm/lowmem_reserve_ratio and the 
per-zone min watermarks.  263MB of slab isn't atypical considering the 
workload and you certainly have a lot of memory allocated by pagetables.

So I think what's going to happen if your merge my patch is that you'll 
see a memory hog be killed and then something will be killed on a 
consistent basis anytime you completely exhaust all memory like this but 
nowhere near the amount you saw before without the patch which turns the 
oom killer into a serial killer.

I would be interested to know where all this anonymous memory is coming 
from, though, considering the largest rss size from your first global oom 
condition posted in the first message of this thread was 639 pages, or 
2.5MB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
