Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3683D6B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 12:26:57 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so3542299wes.37
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 09:26:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ch9si11310701wjb.79.2014.03.03.09.26.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 09:26:55 -0800 (PST)
Date: Mon, 3 Mar 2014 17:26:49 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Panic on ppc64 with numa_balancing and !sparsemem_vmemmap
Message-ID: <20140303172649.GU6732@suse.de>
References: <20140219180200.GA29257@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140219180200.GA29257@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, riel@redhat.com, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Wed, Feb 19, 2014 at 11:32:00PM +0530, Srikar Dronamraju wrote:
> 
> On a powerpc machine with CONFIG_NUMA_BALANCING=y and CONFIG_SPARSEMEM_VMEMMAP
> not enabled,  kernel panics.
> 

This?

---8<---
sched: numa: Do not group tasks if last cpu is not set

On configurations with vmemmap disabled, the following partial is observed

[  299.268623] CPU: 47 PID: 4366 Comm: numa01 Tainted: G      D      3.14.0-rc5-vanilla #4
[  299.278295] Hardware name: Dell Inc. PowerEdge R810/0TT6JF, BIOS 2.7.4 04/26/2012
[  299.287452] task: ffff880c670bc110 ti: ffff880c66db6000 task.ti: ffff880c66db6000
[  299.296642] RIP: 0010:[<ffffffff8109013f>]  [<ffffffff8109013f>] task_numa_fault+0x50f/0x8b0
[  299.306778] RSP: 0000:ffff880c66db7670  EFLAGS: 00010282
[  299.313769] RAX: 00000000000033ee RBX: ffff880c670bc110 RCX: 0000000000000001
[  299.322590] RDX: 0000000000000001 RSI: 0000000000000003 RDI: 00000000ffffffff
[  299.331394] RBP: ffff880c66db76c8 R08: 0000000000000000 R09: 00000000000166b0
[  299.340203] R10: ffff880c7ffecd80 R11: 0000000000000000 R12: 00000000000001ff
[  299.348989] R13: 00000000000000ff R14: 00000000ffffffff R15: 0000000000000003
[  299.357763] FS:  00007f5a60a3f700(0000) GS:ffff88106f2c0000(0000) knlGS:0000000000000000
[  299.367510] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  299.374913] CR2: 00000000000037da CR3: 0000000868ed4000 CR4: 00000000000007e0
[  299.383726] Stack:
[  299.387414]  0000000000000003 0000000000000000 0000000100000003 0000000100000003
[  299.396564]  ffffffff811888f4 ffff880c66db7698 0000000000000003 ffff880c7f9b3ac0
[  299.405730]  ffff880c66ccebd8 00000000ffffffff 0000000000000003 ffff880c66db7718
[  299.414907] Call Trace:
[  299.419095]  [<ffffffff811888f4>] ? migrate_misplaced_page+0xb4/0x140
[  299.427301]  [<ffffffff8115950c>] do_numa_page+0x18c/0x1f0
[  299.434554]  [<ffffffff8115a6f7>] handle_mm_fault+0x617/0xf70
[  ..........]  SNIPPED

The oops occurs in task_numa_group looking up cpu_rq(LAST__CPU_MASK). The
bug exists for all configurations but will manifest differently. On vmemmap
configurations, it looks up garbage and on !vmemmap configuraitons it
will oops. This patch adds the necessary check and also fixes the type
for LAST__PID_MASK and LAST__CPU_MASK which are currently signed instead
of unsigned integers.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org

diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index da52366..6f661d9 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -63,10 +63,10 @@
 
 #ifdef CONFIG_NUMA_BALANCING
 #define LAST__PID_SHIFT 8
-#define LAST__PID_MASK  ((1 << LAST__PID_SHIFT)-1)
+#define LAST__PID_MASK  ((1UL << LAST__PID_SHIFT)-1)
 
 #define LAST__CPU_SHIFT NR_CPUS_BITS
-#define LAST__CPU_MASK  ((1 << LAST__CPU_SHIFT)-1)
+#define LAST__CPU_MASK  ((1UL << LAST__CPU_SHIFT)-1)
 
 #define LAST_CPUPID_SHIFT (LAST__PID_SHIFT+LAST__CPU_SHIFT)
 #else
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7815709..b44a8b1 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1463,6 +1463,9 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 	int cpu = cpupid_to_cpu(cpupid);
 	int i;
 
+	if (unlikely(cpu == LAST__CPU_MASK && !cpu_online(cpu)))
+		return;
+
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
 				    2*nr_node_ids*sizeof(unsigned long);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
