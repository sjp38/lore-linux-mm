Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92AD06B0031
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 21:53:16 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2545915pad.41
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 18:53:16 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id of8si3176106pbc.133.2014.02.06.18.53.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 18:53:14 -0800 (PST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D6C863EE0AE
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:53:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF93945DE55
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:53:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8796E45DE5A
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:53:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79A9AE0800B
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:53:12 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EADDE08003
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:53:12 +0900 (JST)
Message-ID: <52F44A55.2080007@jp.fujitsu.com>
Date: Fri, 7 Feb 2014 11:52:05 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 48/51] mm, vmstat: Fix CPU hotplug callback registration
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com> <20140205221322.19080.63386.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20140205221322.19080.63386.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org, mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org

(2014/02/06 7:13), Srivatsa S. Bhat wrote:
> Subsystems that want to register CPU hotplug callbacks, as well as perform
> initialization for the CPUs that are already online, often do it as shown
> below:
>
> 	get_online_cpus();
>
> 	for_each_online_cpu(cpu)
> 		init_cpu(cpu);
>
> 	register_cpu_notifier(&foobar_cpu_notifier);
>
> 	put_online_cpus();
>
> This is wrong, since it is prone to ABBA deadlocks involving the
> cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
> with CPU hotplug operations).
>
> Instead, the correct and race-free way of performing the callback
> registration is:
>
> 	cpu_maps_update_begin();
>
> 	for_each_online_cpu(cpu)
> 		init_cpu(cpu);
>
> 	/* Note the use of the double underscored version of the API */
> 	__register_cpu_notifier(&foobar_cpu_notifier);
>
> 	cpu_maps_update_done();
>
>
> Fix the vmstat code in the MM subsystem by using this latter form of callback
> registration.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Cody P Schafer <cody@linux.vnet.ibm.com>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: linux-mm@kvack.org
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu


>
>   mm/vmstat.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7249614..70668ba 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1290,14 +1290,14 @@ static int __init setup_vmstat(void)
>   #ifdef CONFIG_SMP
>   	int cpu;
>
> -	register_cpu_notifier(&vmstat_notifier);
> +	cpu_maps_update_begin();
> +	__register_cpu_notifier(&vmstat_notifier);
>
> -	get_online_cpus();
>   	for_each_online_cpu(cpu) {
>   		start_cpu_timer(cpu);
>   		node_set_state(cpu_to_node(cpu), N_CPU);
>   	}
> -	put_online_cpus();
> +	cpu_maps_update_done();
>   #endif
>   #ifdef CONFIG_PROC_FS
>   	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
