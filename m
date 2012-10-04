Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B43626B00F1
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 02:16:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 4 Oct 2012 11:46:49 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q946GlGu30933170
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 11:46:47 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q94Bjs8W020592
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 21:45:55 +1000
Message-ID: <506D29A7.1000805@linux.vnet.ibm.com>
Date: Thu, 04 Oct 2012 11:46:07 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] CPU hotplug, debug: Detect imbalance between get_online_cpus()
 and put_online_cpus()
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz> <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz> <alpine.LNX.2.00.1210031143260.23544@pobox.suse.cz> <506C2E02.9080804@linux.vnet.ibm.com>	<506C3535.3070401@linux.vnet.ibm.com> <20121003141311.09fb3ffc.akpm@linux-foundation.org>
In-Reply-To: <20121003141311.09fb3ffc.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/04/2012 02:43 AM, Andrew Morton wrote:
> On Wed, 03 Oct 2012 18:23:09 +0530
> "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:
> 
>> The synchronization between CPU hotplug readers and writers is achieved by
>> means of refcounting, safe-guarded by the cpu_hotplug.lock.
>>
>> get_online_cpus() increments the refcount, whereas put_online_cpus() decrements
>> it. If we ever hit an imbalance between the two, we end up compromising the
>> guarantees of the hotplug synchronization i.e, for example, an extra call to
>> put_online_cpus() can end up allowing a hotplug reader to execute concurrently with
>> a hotplug writer. So, add a BUG_ON() in put_online_cpus() to detect such cases
>> where the refcount can go negative.
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>  kernel/cpu.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/kernel/cpu.c b/kernel/cpu.c
>> index f560598..00d29bc 100644
>> --- a/kernel/cpu.c
>> +++ b/kernel/cpu.c
>> @@ -80,6 +80,7 @@ void put_online_cpus(void)
>>  	if (cpu_hotplug.active_writer == current)
>>  		return;
>>  	mutex_lock(&cpu_hotplug.lock);
>> +	BUG_ON(cpu_hotplug.refcount == 0);
>>  	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
>>  		wake_up_process(cpu_hotplug.active_writer);
>>  	mutex_unlock(&cpu_hotplug.lock);
> 
> I think calling BUG() here is a bit harsh.  We should only do that if
> there's a risk to proceeding: a risk of data loss, a reduced ability to
> analyse the underlying bug, etc.
> 
> But a cpu-hotplug locking imbalance is a really really really minor
> problem!  So how about we emit a warning then try to fix things up? 

That would be better indeed, thanks!

> This should increase the chance that the machine will keep running and
> so will increase the chance that a user will be able to report the bug
> to us.
>

Yep, sounds good.
 
> 
> --- a/kernel/cpu.c~cpu-hotplug-debug-detect-imbalance-between-get_online_cpus-and-put_online_cpus-fix
> +++ a/kernel/cpu.c
> @@ -80,9 +80,12 @@ void put_online_cpus(void)
>  	if (cpu_hotplug.active_writer == current)
>  		return;
>  	mutex_lock(&cpu_hotplug.lock);
> -	BUG_ON(cpu_hotplug.refcount == 0);
> -	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
> -		wake_up_process(cpu_hotplug.active_writer);
> +	if (!--cpu_hotplug.refcount) {

This won't catch it. We'll enter this 'if' condition only when cpu_hotplug.refcount was
decremented to zero. We'll miss out the case when it went negative (which we intended to detect).

> +		if (WARN_ON(cpu_hotplug.refcount == -1))
> +			cpu_hotplug.refcount++;	/* try to fix things up */
> +		if (unlikely(cpu_hotplug.active_writer))
> +			wake_up_process(cpu_hotplug.active_writer);
> +	}
>  	mutex_unlock(&cpu_hotplug.lock);
> 
>  }

So how about something like below:

------------------------------------------------------>

From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] CPU hotplug, debug: Detect imbalance between get_online_cpus() and put_online_cpus()

The synchronization between CPU hotplug readers and writers is achieved by
means of refcounting, safe-guarded by the cpu_hotplug.lock.

get_online_cpus() increments the refcount, whereas put_online_cpus() decrements
it. If we ever hit an imbalance between the two, we end up compromising the
guarantees of the hotplug synchronization i.e, for example, an extra call to
put_online_cpus() can end up allowing a hotplug reader to execute concurrently with
a hotplug writer. So, add a WARN_ON() in put_online_cpus() to detect such cases
where the refcount can go negative, and also attempt to fix it up, so that we can
continue to run.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/cpu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/cpu.c b/kernel/cpu.c
index f560598..42bd331 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -80,6 +80,10 @@ void put_online_cpus(void)
 	if (cpu_hotplug.active_writer == current)
 		return;
 	mutex_lock(&cpu_hotplug.lock);
+
+	if (WARN_ON(!cpu_hotplug.refcount))
+		cpu_hotplug.refcount++; /* try to fix things up */
+
 	if (!--cpu_hotplug.refcount && unlikely(cpu_hotplug.active_writer))
 		wake_up_process(cpu_hotplug.active_writer);
 	mutex_unlock(&cpu_hotplug.lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
