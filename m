Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E06356B0036
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 16:40:11 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id g10so7647967pdj.27
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:40:11 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id q5si17890718pbh.194.2014.03.10.13.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 13:40:11 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 11 Mar 2014 02:10:08 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id D1C993940023
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 02:10:05 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2AKe24N50266194
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 02:10:02 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2AKe48g014346
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 02:10:05 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 36/52] zsmalloc: Fix CPU hotplug callback registration
Date: Tue, 11 Mar 2014 02:09:59 +0530
Message-ID: <20140310203959.10746.61303.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
References: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulus@samba.org, oleg@redhat.com, mingo@kernel.org, rjw@rjwysocki.net, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org
Cc: paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-pm@vger.kernel.org, linuxppc-dev@ozlabs.org, srivatsa.bhat@linux.vnet.ibm.com, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>

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

	cpu_notifier_register_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_notifier_register_done();


Fix the zsmalloc code by using this latter form of callback registration.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/zsmalloc.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c03ca5e..36b4591 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -814,21 +814,32 @@ static void zs_exit(void)
 {
 	int cpu;
 
+	cpu_notifier_register_begin();
+
 	for_each_online_cpu(cpu)
 		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
-	unregister_cpu_notifier(&zs_cpu_nb);
+	__unregister_cpu_notifier(&zs_cpu_nb);
+
+	cpu_notifier_register_done();
 }
 
 static int zs_init(void)
 {
 	int cpu, ret;
 
-	register_cpu_notifier(&zs_cpu_nb);
+	cpu_notifier_register_begin();
+
+	__register_cpu_notifier(&zs_cpu_nb);
 	for_each_online_cpu(cpu) {
 		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
-		if (notifier_to_errno(ret))
+		if (notifier_to_errno(ret)) {
+			cpu_notifier_register_done();
 			goto fail;
+		}
 	}
+
+	cpu_notifier_register_done();
+
 	return 0;
 fail:
 	zs_exit();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
