Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 53582900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:23:08 -0400 (EDT)
Date: Wed, 13 Apr 2011 17:23:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <alpine.DEB.2.00.1104131712070.29766@router.home>
Message-ID: <alpine.DEB.2.00.1104131721590.30103@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home> <alpine.DEB.2.00.1104131148070.20908@router.home> <20110413185618.GA3987@mtj.dyndns.org> <alpine.DEB.2.00.1104131521050.25812@router.home> <20110413215022.GI3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131712070.29766@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com, shaohua.li@intel.com


Suggested fixup. Return from slowpath and update percpu variable under
spinlock.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 lib/percpu_counter.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 17:20:41.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-13 17:21:33.000000000 -0500
@@ -82,13 +82,9 @@ void __percpu_counter_add(struct percpu_
 			spin_lock(&fbc->lock);
 			count = __this_cpu_read(*fbc->counters);
 			fbc->count += count + amount;
+			__this_cpu_write(*fbc->counters, 0);
 			spin_unlock(&fbc->lock);
-			/*
-			 * If cmpxchg fails then we need to subtract the amount that
-			 * we found in the percpu value.
-			 */
-			amount = -count;
-			new = 0;
+			return;
 		}

 	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
