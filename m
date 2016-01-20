Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 87B6F6B0255
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:55:24 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id ik10so103414116igb.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:55:24 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id q70si42485621ioi.47.2016.01.20.07.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 07:55:23 -0800 (PST)
Date: Wed, 20 Jan 2016 09:55:22 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <569FAC90.5030407@oracle.com>
Message-ID: <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <20160120143719.GF14187@dhcp22.suse.cz> <569FA01A.4070200@oracle.com> <20160120151007.GG14187@dhcp22.suse.cz> <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org> <569FAC90.5030407@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Jan 2016, Sasha Levin wrote:

>
> As I've mentioned - this reproduces frequently. I'd be happy to add in debug
> information into the kernel that might help you reproduce it, but as it seems
> like a timing issue, I can't provide a simple reproducer.

This isnt really important I think. Lets remove it.


Subject: vmstat: Remove BUG_ON from vmstat_update

If we detect that there is nothing to do just set the flag and do not check
if it was already set before. Races really do not matter. If the flag is
set by any code then the shepherd will start dealing with the situation
and reenable the vmstat workers when necessary again.

Concurrent actions could be onlining and offlining of processors or be a
result of concurrency issues when updating the cpumask from multiple
processors.

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
