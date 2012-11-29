Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 44D426B0062
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:09:24 -0500 (EST)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 28 Nov 2012 19:09:23 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 95B3FC90044
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:04:04 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAT044vd340438
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:04:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAT043jS005324
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:04:04 -0500
Message-ID: <50B6A66E.8030406@linux.vnet.ibm.com>
Date: Wed, 28 Nov 2012 16:03:58 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: 32/64-bit NUMA consolidation behavior regresion
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cody P Schafer <cody@linux.vnet.ibm.com>

Hi Tejun,

I was bisecting a boot problem on a 32-bit NUMA kernel and it bisected
down to commit 8db78cc4.  It turns out that, with this patch,
pcpu_need_numa() changed its return value on my system from 1 to 0.
What that basically meant was that we stopped using the remapped lowmem
areas for percpu data.

My system is just qemu booted with:

-smp 8 -m 8192 -numa node,nodeid=0,cpus=0-3 -numa node,nodeid=1,cpus=4-7

Watch the "PERCPU:" line early in boot, and you can see the "Embedded"
come and go with or without your patch:

[    0.000000] PERCPU: Embedded 11 pages/cpu @f3000000 s30592 r0 d14464
vs
[    0.000000] PERCPU: 11 4K pages/cpu @f83fe000 s30592 r0 d14464

I believe this has to do with the hunks in your patch that do:

-#ifdef CONFIG_X86_64
        init_cpu_to_node();
-#endif
...
-#ifdef CONFIG_X86_32
-DEFINE_EARLY_PER_CPU(int, x86_cpu_to_node_map, 0);
-#else
 DEFINE_EARLY_PER_CPU(int, x86_cpu_to_node_map, NUMA_NO_NODE);
-#endif
 EXPORT_EARLY_PER_CPU_SYMBOL(x86_cpu_to_node_map);

I don't have a fix handy because I'm working on the original problem,
but I just happened to run across this during a bisect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
