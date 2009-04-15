Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D0F245F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 22:04:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F251Ix020590
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 11:05:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4120745DD78
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 11:05:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1807545DD7E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 11:05:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE3711DB803E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 11:05:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D8411DB8038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 11:05:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: meminfo Committed_AS underflows
In-Reply-To: <1239737619.32604.118.camel@nimitz>
References: <1239737619.32604.118.camel@nimitz>
Message-Id: <20090415105033.AC29.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 11:04:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I have a set of ppc64 machines that seem to spontaneously get underflows
> in /proc/meminfo's Committed_AS field:
>         
>         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
>               1 Committed_AS: 18446744073709323392 kB
>              11 Committed_AS: 18446744073709455488 kB
>               6 Committed_AS:    35136 kB
>               5 Committed_AS: 18446744073709454400 kB
>               7 Committed_AS:    35904 kB
>               3 Committed_AS: 18446744073709453248 kB
>               2 Committed_AS:    34752 kB
>               9 Committed_AS: 18446744073709453248 kB
>               8 Committed_AS:    34752 kB
>               3 Committed_AS: 18446744073709320960 kB
>               7 Committed_AS: 18446744073709454080 kB
>               3 Committed_AS: 18446744073709320960 kB
>               5 Committed_AS: 18446744073709454080 kB
>               6 Committed_AS: 18446744073709320960 kB
> 
> As you can see, it bounces in and out of it.  I think the problem is
> here:
>         
>         #define ACCT_THRESHOLD  max(16, NR_CPUS * 2)
>         ...
>         void vm_acct_memory(long pages)
>         {
>                 long *local;
>         
>                 preempt_disable();
>                 local = &__get_cpu_var(committed_space);
>                 *local += pages;
>                 if (*local > ACCT_THRESHOLD || *local < -ACCT_THRESHOLD) {
>                         atomic_long_add(*local, &vm_committed_space);
>                         *local = 0;
>                 }
>                 preempt_enable();
>         }
> 
> Plus, some joker set CONFIG_NR_CPUS=1024.
> 
> nr_cpus (1024) * 2 * page_size (64k) = 128MB.  That means each cpu can
> skew the counter by 128MB.  With 1024 CPUs that means that we can have
> ~128GB of outstanding percpu accounting that meminfo doesn't see.  Let's
> say we do vm_acct_memory(128MB-1) on 1023 of the CPUs, then on the other
> CPU, we do  vm_acct_memory(-128GB).
> 
> The 1023 cpus won't ever hit the ACCT_THRESHOLD.  The 1 CPU that did
> will decrement the global 'vm_committed_space'  by ~128 GB.  Underflow.
> Yay.  This happens on a much smaller scale now.
> 
> Should we be protecting meminfo so that it spits slightly more sane
> numbers out to the user?

Can you try to this patch? (Oh well, I can't reproduce this underflow
on my small machine)

===============

Dave Hansen reported committed_AS field can underfolow.

>         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
>               1 Committed_AS: 18446744073709323392 kB
>              11 Committed_AS: 18446744073709455488 kB
>               6 Committed_AS:    35136 kB
>               5 Committed_AS: 18446744073709454400 kB
>               7 Committed_AS:    35904 kB
>               3 Committed_AS: 18446744073709453248 kB
>               2 Committed_AS:    34752 kB
>               9 Committed_AS: 18446744073709453248 kB
>               8 Committed_AS:    34752 kB
>               3 Committed_AS: 18446744073709320960 kB
>               7 Committed_AS: 18446744073709454080 kB
>               3 Committed_AS: 18446744073709320960 kB
>               5 Committed_AS: 18446744073709454080 kB
>               6 Committed_AS: 18446744073709320960 kB

Because NR_CPU can be greater than 1000. and meminfo_proc_show()
doesn't have underflow check.

this patch have two change.

1. Change NR_CPU to nr_online_cpus()
   vm_acct_memory() isn't fast-path. then cpumask_weight() calculation
   isn't so expensive and the parameter for scalability issue should
   consider number of _physical_ cpus. not theoretical maximum number.
2. Add under-flow check to meminfo_proc_show().
   Almost field in /proc/meminfo have underflow check. but Committed_AS
   is significant exeption.
   it should do.

Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/meminfo.c |    2 ++
 mm/swap.c         |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_long_read(&vm_committed_space);
+	if (committed < 0)
+		committed = 0;
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -519,7 +519,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
  * We tolerate a little inaccuracy to avoid ping-ponging the counter between
  * CPUs
  */
-#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
+#define ACCT_THRESHOLD	max_t(long, 16, num_online_cpus() * 2)
 
 static DEFINE_PER_CPU(long, committed_space);
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
