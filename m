Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F1020900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:49:54 -0400 (EDT)
Date: Wed, 13 Apr 2011 11:49:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: percpu: preemptless __per_cpu_counter_add
In-Reply-To: <alpine.DEB.2.00.1104130942500.16214@router.home>
Message-ID: <alpine.DEB.2.00.1104131148070.20908@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com

Duh the retry setup if the number overflows is not correct.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 lib/percpu_counter.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 11:43:23.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-13 11:43:30.000000000 -0500
@@ -80,9 +80,14 @@ void __percpu_counter_add(struct percpu_
 		/* In case of overflow fold it into the global counter instead */
 		if (new >= batch || new <= -batch) {
 			spin_lock(&fbc->lock);
-			fbc->count += __this_cpu_read(*fbc->counters) + amount;
+			count = __this_cpu_read(*fbc->counters);
+			fbc->count += count + amount;
 			spin_unlock(&fbc->lock);
-			amount = 0;
+			/*
+			 * If cmpxchg fails then we need to subtract the amount that
+			 * we found in the percpu value.
+			 */
+			amount = -count;
 			new = 0;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
