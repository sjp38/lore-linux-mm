Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1C88D6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 08:08:51 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id e126so153600061ioa.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 05:08:51 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id o62si13740666ioi.143.2015.12.21.05.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 05:08:50 -0800 (PST)
Date: Mon, 21 Dec 2015 07:08:49 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <5674A5C3.1050504@oracle.com>
Message-ID: <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 18 Dec 2015, Sasha Levin wrote:

> [  531.164630] RIP vmstat_update (mm/vmstat.c:1408)

Hmmm.. Yes we need to fold the diffs first before disabling the timer
otherwise the shepherd task may intervene.

Does this patch fix it?


Subject: quiet_vmstat: Avoid race with shepherd by folding counters first

We need to fold the counters first otherwise the shepherd task may
remotely reactivate the vmstat worker.

This also avoids the strange loop. Nothing can really increase the
counters at that point since we are in the cpu idle loop. So
folding the counters once is enough. Cancelling work that does
not exist is fine too so just avoid the branches completely.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1419,11 +1419,9 @@ void quiet_vmstat(void)
 	if (system_state != SYSTEM_RUNNING)
 		return;

-	do {
-		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
-			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
-
-	} while (refresh_cpu_vm_stats(false));
+	refresh_cpu_vm_stats(false);
+	cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+	cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
