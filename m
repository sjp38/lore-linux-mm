Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DE3D46B0044
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 08:53:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 3 Oct 2012 22:51:49 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q93CiIaL26673370
	for <linux-mm@kvack.org>; Wed, 3 Oct 2012 22:44:19 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q93CroAK021056
	for <linux-mm@kvack.org>; Wed, 3 Oct 2012 22:53:51 +1000
Message-ID: <506C3535.3070401@linux.vnet.ibm.com>
Date: Wed, 03 Oct 2012 18:23:09 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] CPU hotplug, debug: Detect imbalance between get_online_cpus()
 and put_online_cpus()
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz> <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz> <alpine.LNX.2.00.1210031143260.23544@pobox.suse.cz> <506C2E02.9080804@linux.vnet.ibm.com>
In-Reply-To: <506C2E02.9080804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/03/2012 05:52 PM, Srivatsa S. Bhat wrote:
> On 10/03/2012 03:16 PM, Jiri Kosina wrote:
>> On Wed, 3 Oct 2012, Jiri Kosina wrote:
>>
>>> Good question. I believe it should be safe to drop slab_mutex earlier, as 
>>> cachep has already been unlinked. I am adding slab people and linux-mm to 
>>> CC (the whole thread on LKML can be found at 
>>> https://lkml.org/lkml/2012/10/2/296 for reference).
>>>
[...]
> 
> But, I'm also quite surprised that the put_online_cpus() code as it stands today
> doesn't have any checks for the refcount going negative. I believe that such a
> check would be valuable to help catch cases where we might end up inadvertently
> causing an imbalance between get_online_cpus() and put_online_cpus(). I'll post
> that as a separate patch.
> 


-----------------------------------


From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] CPU hotplug, debug: Detect imbalance between get_online_cpus() and put_online_cpus()

The synchronization between CPU hotplug readers and writers is achieved by
means of refcounting, safe-guarded by the cpu_hotplug.lock.

get_online_cpus() increments the refcount, whereas put_online_cpus() decrements
it. If we ever hit an imbalance between the two, we end up compromising the
guarantees of the hotplug synchronization i.e, for example, an extra call to
put_online_cpus() can end up allowing a hotplug reader to execute concurrently with
a hotplug writer. So, add a BUG_ON() in put_online_cpus() to detect such cases
where the refcount can go negative.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/cpu.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/cpu.c b/kernel/cpu.c
index f560598..00d29bc 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -80,6 +80,7 @@ void put_online_cpus(void)
 	if (cpu_hotplug.active_writer == current)
 		return;
 	mutex_lock(&cpu_hotplug.lock);
+	BUG_ON(cpu_hotplug.refcount == 0);
 	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
 		wake_up_process(cpu_hotplug.active_writer);
 	mutex_unlock(&cpu_hotplug.lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
