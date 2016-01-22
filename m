Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD2A6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:46:16 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id ik10so14651621igb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:46:16 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id i15si13175675iod.68.2016.01.22.08.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 08:46:15 -0800 (PST)
Date: Fri, 22 Jan 2016 10:46:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160122161201.GC19465@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601221046020.17984@east.gentwo.org>
References: <569FAC90.5030407@oracle.com> <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org> <20160120212806.GA26965@dhcp22.suse.cz> <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org> <20160121082402.GA29520@dhcp22.suse.cz> <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
 <20160121165148.GF29520@dhcp22.suse.cz> <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org> <20160122140418.GB19465@dhcp22.suse.cz> <alpine.DEB.2.20.1601220950290.17929@east.gentwo.org> <20160122161201.GC19465@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 22 Jan 2016, Michal Hocko wrote:

> Could you repost the patch with the updated description?

Subject: vmstat: Remove BUG_ON from vmstat_update

If we detect that there is nothing to do just set the flag and do not check
if it was already set before. Races really do not matter. If the flag is
set by any code then the shepherd will start dealing with the situation
and reenable the vmstat workers when necessary again.

Since 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
shut down on idle") quiet_vmstat might update cpu_stat_off and mark a
particular cpu to be handled by vmstat_shepherd. This might trigger
a VM_BUG_ON in vmstat_update because the work item might have been
sleeping during the idle period and see the cpu_stat_off updated after
the wake up. The VM_BUG_ON is therefore misleading and no more
appropriate. Moreover it doesn't really suite any protection from real
bugs because vmstat_shepherd will simply reschedule the vmstat_work
anytime it sees a particular cpu set or vmstat_update would do the same
from the worker context directly. Even when the two would race the
result wouldn't be incorrect as the counters update is fully idempotent.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1408,17 +1408,7 @@ static void vmstat_update(struct work_st
 		 * Defer the checking for differentials to the
 		 * shepherd thread on a different processor.
 		 */
-		int r;
-		/*
-		 * Shepherd work thread does not race since it never
-		 * changes the bit if its zero but the cpu
-		 * online / off line code may race if
-		 * worker threads are still allowed during
-		 * shutdown / startup.
-		 */
-		r = cpumask_test_and_set_cpu(smp_processor_id(),
-			cpu_stat_off);
-		VM_BUG_ON(r);
+		cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
