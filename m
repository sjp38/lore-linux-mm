Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 040F26B0072
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:13:12 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:13:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] CPU hotplug, debug: Detect imbalance between
 get_online_cpus() and put_online_cpus()
Message-Id: <20121003141311.09fb3ffc.akpm@linux-foundation.org>
In-Reply-To: <506C3535.3070401@linux.vnet.ibm.com>
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz>
	<20121002170149.GC2465@linux.vnet.ibm.com>
	<alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz>
	<alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz>
	<alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz>
	<20121002233138.GD2465@linux.vnet.ibm.com>
	<alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz>
	<20121003001530.GF2465@linux.vnet.ibm.com>
	<alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
	<alpine.LNX.2.00.1210031143260.23544@pobox.suse.cz>
	<506C2E02.9080804@linux.vnet.ibm.com>
	<506C3535.3070401@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 03 Oct 2012 18:23:09 +0530
"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:

> The synchronization between CPU hotplug readers and writers is achieved by
> means of refcounting, safe-guarded by the cpu_hotplug.lock.
> 
> get_online_cpus() increments the refcount, whereas put_online_cpus() decrements
> it. If we ever hit an imbalance between the two, we end up compromising the
> guarantees of the hotplug synchronization i.e, for example, an extra call to
> put_online_cpus() can end up allowing a hotplug reader to execute concurrently with
> a hotplug writer. So, add a BUG_ON() in put_online_cpus() to detect such cases
> where the refcount can go negative.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  kernel/cpu.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/kernel/cpu.c b/kernel/cpu.c
> index f560598..00d29bc 100644
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -80,6 +80,7 @@ void put_online_cpus(void)
>  	if (cpu_hotplug.active_writer == current)
>  		return;
>  	mutex_lock(&cpu_hotplug.lock);
> +	BUG_ON(cpu_hotplug.refcount == 0);
>  	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
>  		wake_up_process(cpu_hotplug.active_writer);
>  	mutex_unlock(&cpu_hotplug.lock);

I think calling BUG() here is a bit harsh.  We should only do that if
there's a risk to proceeding: a risk of data loss, a reduced ability to
analyse the underlying bug, etc.

But a cpu-hotplug locking imbalance is a really really really minor
problem!  So how about we emit a warning then try to fix things up? 
This should increase the chance that the machine will keep running and
so will increase the chance that a user will be able to report the bug
to us.


--- a/kernel/cpu.c~cpu-hotplug-debug-detect-imbalance-between-get_online_cpus-and-put_online_cpus-fix
+++ a/kernel/cpu.c
@@ -80,9 +80,12 @@ void put_online_cpus(void)
 	if (cpu_hotplug.active_writer == current)
 		return;
 	mutex_lock(&cpu_hotplug.lock);
-	BUG_ON(cpu_hotplug.refcount == 0);
-	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
-		wake_up_process(cpu_hotplug.active_writer);
+	if (!--cpu_hotplug.refcount) {
+		if (WARN_ON(cpu_hotplug.refcount == -1))
+			cpu_hotplug.refcount++;	/* try to fix things up */
+		if (unlikely(cpu_hotplug.active_writer))
+			wake_up_process(cpu_hotplug.active_writer);
+	}
 	mutex_unlock(&cpu_hotplug.lock);
 
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
