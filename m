Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 739A06B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 18:41:35 -0400 (EDT)
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <mauricfo@linux.vnet.ibm.com>;
	Fri, 1 Jun 2012 19:41:33 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 26BC61DC004B
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 18:41:20 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q51Md3Le2793724
	for <linux-mm@kvack.org>; Fri, 1 Jun 2012 19:39:03 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q51MfHNe015415
	for <linux-mm@kvack.org>; Fri, 1 Jun 2012 19:41:19 -0300
Message-ID: <4FC94505.3090506@linux.vnet.ibm.com>
Date: Fri, 01 Jun 2012 19:41:09 -0300
From: Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, srikar@linux.vnet.ibm.com, mjw@linux.vnet.ibm.com

Hi Andrea, everyone..

AA> Changelog from alpha13 to alpha14:
AA> [...]
AA> o autonuma_balance only runs along with run_rebalance_domains, to
AA>    avoid altering the scheduler runtime. [...]
AA>    [...] This change has not
AA>    yet been tested on specjbb or more schedule intensive benchmarks,
AA>    but I don't expect measurable NUMA affinity regressions. [...]

Perhaps I can contribute a bit to the SPECjbb tests.

I got SPECjbb2005 results for 3.4-rc2 mainline, numasched, 
autonuma-alpha10, and autonuma-alpha13. If you judge the data is OK it 
may suit a comparison between autonuma-alpha13/14 to verify NUMA 
affinity regressions.

The system is an Intel 2-socket Blade. Each NUMA node has 6 cores (+6 
hyperthreads) and 12 GB RAM. Different permutations of THP, KSM, and VM 
memory size were tested for each kernel.

I'll have to leave the analysis of each variable for you, as I'm not 
familiar w/ the code and expected impacts; but I'm perfectly fine with 
providing more details about the tests, environment and procedures, and 
even some reruns, if needed.

Please CC me on questions and comments.


Environment:
------------

Host:
- Enterprise Linux Distro
- Kernel: 3.4-rc2 (either mainline, or patched w/ numasched, 
autonuma-alpha10, or autonuma-alpha13)
- 2 NUMA nodes. 6 cores + 6 hyperthreads/node, 12 GB RAM/node.
   (total of 24 logical CPUs and 24 GB RAM)
- Hypervisor: qemu-kvm 1.0.50 (+ memsched patches only for numasched)

VMs:
- Enterprise Linux Distro
- Distro Kernel

   1 Main VM (VM1) -- relevant benchmark score.
   - 12 vCPUs
   - 12 GB (for '< 1 Node' configuration) or 14 GB (for '> 1 Node' 
configuration)

   2 Noise VMs (VM2 and VM3)
   - each noise VM has half of the remaining resources.
   - 6 vCPUs
   - 4 GB (for '< 1 Node' configuration) or 3 GB ('> 1 Node' configuration)
     (to sum 20 GB w/ main VM + 4 GB for host = total 24 GB)

Settings:
- Swapping disabled on host and VMs.
- Memory Overcommit enabled on host and VMs.
- THP on host is a variable. THP disabled on VMs.
- KSM on host is a variable. KSM disabled on VMs.


Results
=======

Reference is mainline kernel with THP disabled (its score is 
approximately 100%). It performed similarly (less than 2% difference) on 
the 4 permutations of KSM and Main VM memory size.

For the results of all permutations, see chart [1].
One interesting permutation seems to be: No THP (disabled); KSM (enabled).

Interpretation:
- higher is better;
- main VM should perform better than noise VMs;
- noise VMs should perform similarly.


Main VM < 1 Node
-----------------

                 Main VM     Noise VM    Noise VM
mainline        ~100%       60%         60%
numasched *     50%/135%    30%/58%     40%/68%
autonuma-a10    125%        60%         60%
autonuma-a13    126%        32%         32%

* numasched yielded a wide range of scores. Is this behavior expected?


Main VM > 1 Node.
-----------------

                 Main VM     Noise VM    Noise VM
mainline        ~100%       60%         59%
numasched       60%         48%         48%
autonuma-a10    62%         37%         38%
autonuma-a13    125%        61%         63%



Considerations:
---------------

The 3 VMs ran SPECjbb2005, synchronously starting the benchmark.

For the benchmark run to take about the same time on the 3 VMs, its 
configuration for the Noise VMs is different than for the Main VM.
So comparing VM1 scores w/ VM2 or VM3 scores is not reasonable.
But comparing scores between VM2 and VM3 is perfectly fine (it's 
evidence of the performed balancing).

Sometimes both autonuma and numasched prioritized one of the Noise VMs 
over the other Noise VM, or even over the Main VM. In these cases, some 
reruns would yield scores of 'expected proportion', given the VMs 
configuration (Main VM w/ the highest score, both Noise VMs with lower 
scores which are about the same).

The non-expected proportion scores happened less often w/ 
autonuma-alpha13, followed by autonuma-alpha10, and finally numasched 
(i.e., numasched had the greatest rate of non-expected proportion scores).

For most permutations, numasched didn't yield scores of expected 
proportion. I'd like to know how likely this is to happen, before 
performing additional runs to confirm it. If anyone would provide 
evidence or thoughts?


Links:
------

[1] http://dl.dropbox.com/u/82832537/kvm-numa-comparison-0.png


-- 
Mauricio Faria de Oliveira
IBM Linux Technology Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
