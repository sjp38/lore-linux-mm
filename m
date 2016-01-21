Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7520A6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 12:38:48 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id z14so130907808igp.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 09:38:48 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id p9si6007381ioe.174.2016.01.21.09.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 09:38:47 -0800 (PST)
Date: Thu, 21 Jan 2016 11:38:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160121165148.GF29520@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
References: <20160120143719.GF14187@dhcp22.suse.cz> <569FA01A.4070200@oracle.com> <20160120151007.GG14187@dhcp22.suse.cz> <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org> <569FAC90.5030407@oracle.com> <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
 <20160120212806.GA26965@dhcp22.suse.cz> <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org> <20160121082402.GA29520@dhcp22.suse.cz> <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org> <20160121165148.GF29520@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 21 Jan 2016, Michal Hocko wrote:

> It goes like this:
> CPU0:						CPU1
> vmstat_update
>   cpumask_test_and_set_cpu (0->1)
> [...]
> 						vmstat_shepherd
> <enter idle>					  cpumask_test_and_clear_cpu(CPU0) (1->0)
> quiet_vmstat
>   cpumask_test_and_set_cpu (0->1)
>   						  queue_delayed_work_on(CPU0)
> refresh_cpu_vm_stats()
> [...]
> vmstat_update
>   nothing_to_do
>   cpumask_test_and_set_cpu (1->1)
>   VM_BUG_ON
>
> Or am I missing something?

Ok then the following should fix it:



Subject: vmstat: Queue work before clearing cpu_stat_off

There is a race between vmstat_shepherd and quiet_vmstat() because
the responsibility for checking for counter updates changes depending
on the state of teh bit in cpu_stat_off. So queue the work before
changing state of the bit in vmstat_shepherd. That way quiet_vmstat
is guaranteed to remove the work request when clearing the bit and the
bug in vmstat_update wont trigger anymore.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1480,12 +1480,14 @@ static void vmstat_shepherd(struct work_
 	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
 	for_each_cpu(cpu, cpu_stat_off)
-		if (need_update(cpu) &&
-			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
+		if (need_update(cpu)) {

 			queue_delayed_work_on(cpu, vmstat_wq,
 				&per_cpu(vmstat_work, cpu), 0);

+			cpumask_clear_cpu(smp_processor_id(), cpu_stat_off);
+		}
+
 	put_online_cpus();

 	schedule_delayed_work(&shepherd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
