Message-Id: <20080116170902.006151000@sgi.com>
Date: Wed, 16 Jan 2008 09:09:02 -0800
From: travis@sgi.com
Subject: [PATCH 00/10] x86: Reduce memory and intra-node effects with large count NR_CPUs V3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patchset addresses the kernel bloat that occurs when NR_CPUS is increased.
The memory numbers below are with NR_CPUS = 1024 which I've been testing (4 and
32 real processors, the rest "possible" using the additional_cpus start option.)
These changes are all specific to the x86 architecture, non-arch specific
changes will follow.

Based on 2.6.24-rc6-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - Remove extraneous casts
    - Add comment about node memory < NODE_MIN_SIZE
    - changed pxm_to_node_map to u16
    - changed memnode map entries to u16
    - Fix !NUMA builds with '#ifdef CONFIG_NUMA"
    - Add slight optimization to apic_is_clustered_box()

V2->V3:
    - add early_cpu_to_node function to keep cpu_to_node efficient
    - move and rename smp_set_apicids() to setup_percpu_maps()
    - call setup_percpu_maps() as early as possible
    - changed memnode.embedded_map from [64-16] to [64-8]
      (and size comment to 128 bytes)
---

[Updated memory usage table.]

The following columns are using the SuSE default x86_64 config
[which has NR_CPUS=128] and NR_CPUS=1024.  There are no modules
in either.  Each column's percentage is relative to the first.

128cpus			1kcpus-before		1kcpus-after
       228 .altinstr_re        228 +0%		       228 +0%
      1219 .altinstruct       1219 +0%		      1219 +0%
    866632 .bss		   2260296 +160%	   2112968 +143%
     61374 .comment	     61374 +0%		     61374 +0%
	16 .con_initcal 	16 +0%			16 +0%
    427560 .data	    445480 +4%		    444200 +3%
   1165824 .data.cachel   13076992 +1021%	  13076992 +1021%
      8192 .data.init_t       8192 +0%		      8192 +0%
      4096 .data.page_a       4096 +0%		      4096 +0%
     39296 .data.percpu     155776 +296%	    155904 +296%
    188992 .data.read_m    8751776 +4530%	   8747680 +4528%
	 4 .data_nosave 	 4 +0%			 4 +0%
      5141 .exit.text	      5150 +0%		      5149 +0%
    138576 .init.data	    139472 +0%		    145424 +4%
       134 .init.ramfs	       134 +0%		       134 +0%
      3192 .init.setup	      3192 +0%		      3192 +0%
    160143 .init.text	    160643 +0%		    160914 +0%
      2288 .initcall.in       2288 +0%		      2288 +0%
	 8 .jiffies		 8 +0%			 8 +0%
      4512 .pci_fixup	      4512 +0%		      4512 +0%
   1314318 .rodata	   1315630 +0%		   1315305 +0%
     36856 .smp_locks	     36808 +0%		     36800 +0%
   3975021 .text	   3984829 +0%		   3987389 +0%
      3368 .vdso	      3368 +0%		      3368 +0%
	 4 .vgetcpu_mod 	 4 +0%			 4 +0%
       218 .vsyscall_0	       218 +0%		       218 +0%
	52 .vsyscall_1		52 +0%			52 +0%
	91 .vsyscall_2		91 +0%			91 +0%
	 8 .vsyscall_3		 8 +0%			 8 +0%
	54 .vsyscall_fn 	54 +0%			54 +0%
	80 .vsyscall_gt 	80 +0%			80 +0%
     39480 __bug_table	     39480 +0%		     39480 +0%
     16320 __ex_table	     16320 +0%		     16320 +0%
      9160 __param	      9160 +0%		      9160 +0%
						
   1818299 Text		   1834603 +0%		   1834859 +0%
   3975021 Data		   3984829 +0%		   3987389 +0%
    866632 Bss		   2260296 +160%	   2112968 +143%
    360448 InitData	    483328 +34%		    487424 +35%
   1415640 OtherData	  21885912 +1446%	  21883096 +1445%
     39296 PerCpu	    155776 +0%		    155904 +0%
   8472457 Total	  30486950 +259%	  30342823 +258%


[Note that the sum of the last 6 lines may not equal "Total" as some
sections may contain others (eg., InitData contains PerCpu data.)]

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
