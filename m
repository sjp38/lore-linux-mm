Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4497B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:47:15 -0500 (EST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 20 Jan 2012 03:17:11 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0JLl5QL3727410
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 03:17:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0JLl3l9027785
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:47:04 +1100
Message-ID: <4F188F52.1060303@linux.vnet.ibm.com>
Date: Fri, 20 Jan 2012 03:16:58 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
References: <1326276668-19932-1-git-send-email-mgorman@suse.de> <1326276668-19932-3-git-send-email-mgorman@suse.de> <1326381492.2442.188.camel@twins> <20120112153712.GL4118@suse.de> <1326383551.2442.203.camel@twins> <20120112171847.GN4118@suse.de> <no-drain-reply@mdm.bga.com> <20120119162057.GD3143@suse.de>
In-Reply-To: <20120119162057.GD3143@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Milton Miller <miltonm@bga.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, mszeredi@novell.com, ebiederm@xmission.com, Greg Kroah-Hartman <gregkh@suse.de>, gong.chen@intel.com, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@amd64.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, linux-edac@vger.kernel.org, Andi Kleen <andi@firstfloor.org>

[Reinstating the original Cc list]

On 01/19/2012 09:50 PM, Mel Gorman wrote:> 

> On a different x86-64 machines with an intel-specific MCE, I have
> also noted that the value of num_online_cpus() can change while
> stop_machine() is running.


That is expected and intentional right? Meaning, it is during the
stop_machine() thing itself that a CPU is actually taken offline.
And at the same time, it is removed from the cpu_online_mask.

On Intel boxes, essentially, the following gets executed on the dying
CPU, as set up by the stop_machine stuff.

__cpu_disable()
    native_cpu_disable()
        cpu_disable_common()
            remove_cpu_from_maps()
                set_cpu_online(cpu, false)
			^^^^^^
So, set_cpu_online will remove this CPU from the cpu_online_mask.
And all this runs while still under the stop machine context.
And this is exactly what we want right?

> This is sensitive to timing and part of
> the problem seems to be due to cmci_rediscover() running without the
> CPU hotplug mutex held. This is not related to the IPI mess and is
> unrelated to memory pressure but is just to note that CPU hotplug in
> general can be fragile in parts.
> 


For the cmci_rediscover() part, I feel a simple get/put_online_cpus()
around it should work.

Something like the following patch? (It is untested at the moment, but
I will run it later and see if it works well).

I would like the opinion of MCE/Intel maintainers as to whether this is
a proper fix or something else would have been better..

----
From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] x86/intel mce: Fix race with CPU hotplug in cmci_rediscover()

cmci_rediscover() is invoked upon the CPU_POST_DEAD notification, when
the cpu_hotplug lock is no longer held. And cmci_rediscover() iterates
over all the online cpus. So this can race with an ongoing CPU hotplug
operation. Fix this by wrapping the iteration code within the pair
get_online_cpus() / put_online_cpus().

Reported-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/kernel/cpu/mcheck/mce_intel.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce_intel.c b/arch/x86/kernel/cpu/mcheck/mce_intel.c
index 38e49bc..1c30397 100644
--- a/arch/x86/kernel/cpu/mcheck/mce_intel.c
+++ b/arch/x86/kernel/cpu/mcheck/mce_intel.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 #include <linux/percpu.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 #include <asm/apic.h>
 #include <asm/processor.h>
 #include <asm/msr.h>
@@ -179,6 +180,7 @@ void cmci_rediscover(int dying)
 		return;
 	cpumask_copy(old, &current->cpus_allowed);
 
+	get_online_cpus();
 	for_each_online_cpu(cpu) {
 		if (cpu == dying)
 			continue;
@@ -188,6 +190,7 @@ void cmci_rediscover(int dying)
 		if (cmci_supported(&banks))
 			cmci_discover(banks, 0);
 	}
+	put_online_cpus();
 
 	set_cpus_allowed_ptr(current, old);
 	free_cpumask_var(old);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
