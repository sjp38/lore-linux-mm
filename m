Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 4CA636B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:54:40 -0400 (EDT)
Message-ID: <4FE96A3A.2080307@intel.com>
Date: Tue, 26 Jun 2012 15:52:26 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: AutoNUMA15
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <20120529133627.GA7637@shutemov.name> <20120529154308.GA10790@dhcp-27-244.brq.redhat.com> <20120531180834.GP21339@redhat.com> <CAGjg+kHNe4RkhHKt5JYKDnE2oqs0ZBNUkL_XYOwfDK1S5cxjvw@mail.gmail.com> <20120621145552.GG4954@redhat.com>
In-Reply-To: <20120621145552.GG4954@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Shi <lkml.alex@gmail.com>, Petr Holasek <pholasek@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, "Chen, Tim C" <tim.c.chen@intel.com>

On 06/21/2012 10:55 PM, Andrea Arcangeli wrote:

> On Thu, Jun 21, 2012 at 03:29:52PM +0800, Alex Shi wrote:
>>> I released an AutoNUMA15 branch that includes all pending fixes:
>>>
>>> git clone --reference linux -b autonuma15 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
>>>
>>
>> I did a quick testing on our
>> specjbb2005/oltp/hackbench/tbench/netperf-loop/fio/ffsb on NHM EP/EX,
>> Core2 EP, Romely EP machine, In generally no clear performance change
>> found. Is this results expected for this patch set?
> 
> hackbench and network benchs won't get benefit (the former
> overschedule like crazy so there's no way any autonuma balancing can
> have effect with such an overscheduling and zillion of threads, the
> latter is I/O dominated usually taking so little RAM it doesn't
> matter, the memory accesses on the kernel side and DMA issue should
> dominate it in CPU utilization). Similar issue for filesystem
> benchmarks like fio.
> 
> On all _system_ time dominated kernel benchmarks it is expected not to
> measure a performance optimization and if you don't measure a
> regression it's more than enough.
> 
> The only benchmarks that gets benefit are userland where the user/nice
> time in top dominates. AutoNUMA cannot optimize or move kernel memory
> around, it only optimizes userland computations.
> 
> So you should run HPC jobs. The only strange thing here is that
> specjbb2005 gets a measurable significant boost with AutoNUMA so if
> you didn't even get a boost with that you may want to verify:
> 
> cat /sys/kernel/mm/autonuma/enabled == 1
> 
> Also verify:
> 
> CONFIG_AUTONUMA_DEFAULT_ENABLED=y
> 
> If that's 1 well maybe the memory interconnect is so fast that there's
> no benefit?
> 
> My numa01/02 benchmarks measures the best worst case of the hardware
> (not software), with -DINVERSE_BIND -DHARD_BIND parameters, you can
> consider running that to verify.


Could you like to give a url for the benchmarks?

> 
> Probably there should be a little boot time kernel benchmark to
> measure the inverse bind vs hard bind performance across the first two
> nodes, if the difference is nil AutoNUMA should disengage and not even
> allocate the page_autonuma (now only 12 bytes per page but anyway).
> 
> If you can retest with autonuma17 it would help too as there was some
> performance issue fixed and it'd stress the new autonuma migration lru
> code:
> 
> git clone --reference linux -b autonuma17 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git autonuma17
> 
> And the very latest is always at the autonuma branch:
> 
> git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git autonuma


I got the commit till 2c7535e100805d. and retested specjbb2005 with
jrockit and openjdk again on my Romely EP(2P * 8 cores * HT, with 64GB
memory). find the openjdk has about 2% regression, while jrockit has no
clear change.


the testing user 2 instances, each of them are pinned to a node. some
setting is here:
  per_jvm_warehouse_rampup = 3.0
  per_jvm_warehouse_rampdown = 20.0
  jvm_instances = 2
  deterministic_random_seed = false
  ramp_up_seconds = 30
  measurement_seconds = 240
  starting_number_warehouses = 1
  increment_number_warehouses = 1
  ending_number_warehouses = 34
  expected_peak_warehouse = 16

openjdk
java options:
-Xmx8g -Xms8g -Xincgc

jrockit use hugetlb and its options:
-Xmx8g -Xms8g -Xns4g -XXaggressive -Xlargepages -XXlazyUnlocking
-Xgc:genpar -XXtlasize:min=16k,preferred=64k

> 
> Thanks,
> Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
