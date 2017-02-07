Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD6C6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 05:42:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jz4so24561300wjb.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 02:42:52 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id w17si11689732wmw.22.2017.02.07.02.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 02:42:51 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id B42321C14F3
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:42:50 +0000 (GMT)
Date: Tue, 7 Feb 2017 10:42:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207104249.gpephtef2ajoqw62@techsingularity.net>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <614e9873-c894-de42-a38a-1798fc0be039@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <614e9873-c894-de42-a38a-1798fc0be039@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 10:23:31AM +0100, Vlastimil Babka wrote:
> > cpu offlining. I have to check the code but my impression was that WQ
> > code will ignore the cpu requested by the work item when the cpu is
> > going offline. If the offline happens while the worker function already
> > executes then it has to wait as we run with preemption disabled so we
> > should be safe here. Or am I missing something obvious?
> 
> Tejun suggested an alternative solution to avoiding get_online_cpus() in
> this thread:
> https://lkml.kernel.org/r/<20170123170329.GA7820@htj.duckdns.org>

But it would look like the following as it could be serialised against
pcpu_drain_mutex as the cpu hotplug teardown callback is allowed to sleep.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b93879990fd..8cd8b1bbe00c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2319,9 +2319,17 @@ static void drain_pages(unsigned int cpu)
 {
 	struct zone *zone;
 
+	/*
+	 * A per-cpu drain via a workqueue from drain_all_pages can be
+	 * rescheduled onto an unrelated CPU. That allows the hotplug
+	 * operation and the drain to potentially race on the same
+	 * CPU. Serialise hotplug versus drain using pcpu_drain_mutex
+	 */
+	mutex_lock(&pcpu_drain_mutex);
 	for_each_populated_zone(zone) {
 		drain_pages_zone(cpu, zone);
 	}
+	mutex_unlock(&pcpu_drain_mutex);
 }
 
 /*
@@ -2377,13 +2385,10 @@ void drain_all_pages(struct zone *zone)
 		mutex_lock(&pcpu_drain_mutex);
 	}
 
-	get_online_cpus();
-
 	/*
-	 * We don't care about racing with CPU hotplug event
-	 * as offline notification will cause the notified
-	 * cpu to drain that CPU pcps and on_each_cpu_mask
-	 * disables preemption as part of its processing
+	 * We don't care about racing with CPU hotplug event as offline
+	 * notification will cause the notified cpu to drain that CPU pcps
+	 * and it is serialised against here via pcpu_drain_mutex.
 	 */
 	for_each_online_cpu(cpu) {
 		struct per_cpu_pageset *pcp;
@@ -2418,7 +2423,6 @@ void drain_all_pages(struct zone *zone)
 	for_each_cpu(cpu, &cpus_with_pcps)
 		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
 
-	put_online_cpus();
 	mutex_unlock(&pcpu_drain_mutex);
 }
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
