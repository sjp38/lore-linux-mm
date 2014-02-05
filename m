Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2D86B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 17:18:59 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so930876pbc.41
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 14:18:58 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id q6si30517740pbf.64.2014.02.05.14.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 14:18:58 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 6 Feb 2014 03:48:55 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9CA321258054
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:50:42 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s15MIkI557344200
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 03:48:46 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s15MIp19018842
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 03:48:52 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 49/51] mm, zswap: Fix CPU hotplug callback registration
Date: Thu, 06 Feb 2014 03:43:37 +0530
Message-ID: <20140205221336.19080.49754.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org
Cc: mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com, linux-mm@kvack.org"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>

Subsystems that want to register CPU hotplug callbacks, as well as perform
initialization for the CPUs that are already online, often do it as shown
below:

	get_online_cpus();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	register_cpu_notifier(&foobar_cpu_notifier);

	put_online_cpus();

This is wrong, since it is prone to ABBA deadlocks involving the
cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
with CPU hotplug operations).

Instead, the correct and race-free way of performing the callback
registration is:

	cpu_maps_update_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_maps_update_done();


Fix the zswap code by using this latter form of callback registration.

Cc: linux-mm@kvack.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/zswap.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index e55bab9..681fa3f 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -387,18 +387,18 @@ static int zswap_cpu_init(void)
 {
 	unsigned long cpu;
 
-	get_online_cpus();
+	cpu_maps_update_begin();
 	for_each_online_cpu(cpu)
 		if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
 			goto cleanup;
-	register_cpu_notifier(&zswap_cpu_notifier_block);
-	put_online_cpus();
+	__register_cpu_notifier(&zswap_cpu_notifier_block);
+	cpu_maps_update_done();
 	return 0;
 
 cleanup:
 	for_each_online_cpu(cpu)
 		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
-	put_online_cpus();
+	cpu_maps_update_done();
 	return -ENOMEM;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
