Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B99266B0204
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 10:04:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so1000994pad.0
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 07:04:54 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id et3si1507754pbc.377.2014.03.20.07.04.53
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 07:04:53 -0700 (PDT)
Date: Thu, 20 Mar 2014 09:04:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: kswapd using __this_cpu_add() in preemptible code
In-Reply-To: <20140318142216.317bf986d10a564881791100@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1403200859050.4107@nuc>
References: <20140318185329.GB430@swordfish> <20140318142216.317bf986d10a564881791100@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Mar 2014, Andrew Morton wrote:

> Christoph caught one.  How does this look?

The fundamental decision to be made here is if we want the counter
overhead coming on platforms that do not have lockless percpu atomics
and therefore would require an irq on/off sequence for safe counter
increments.

So far we have said that we do allow the counters to be racy for
performance sake. Your patch would remove the races.

If we want to keep the races and the performance than we need to change
__count_vm_events to use raw_cpu_add instead of __this_cpu_add.


Subject: vmstat: Use raw_cpu_ops to avoid false positives on preemption checks

vm counters are allowed to be racy. Use raw_cpu_ops to avoid preemption checks.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h	2014-02-10 08:54:02.318697828 -0600
+++ linux/include/linux/vmstat.h	2014-03-20 09:02:05.132852038 -0500
@@ -29,7 +29,7 @@ DECLARE_PER_CPU(struct vm_event_state, v

 static inline void __count_vm_event(enum vm_event_item item)
 {
-	__this_cpu_inc(vm_event_states.event[item]);
+	raw_cpu_inc(vm_event_states.event[item]);
 }

 static inline void count_vm_event(enum vm_event_item item)
@@ -39,7 +39,7 @@ static inline void count_vm_event(enum v

 static inline void __count_vm_events(enum vm_event_item item, long delta)
 {
-	__this_cpu_add(vm_event_states.event[item], delta);
+	raw_cpu_add(vm_event_states.event[item], delta);
 }

 static inline void count_vm_events(enum vm_event_item item, long delta)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
