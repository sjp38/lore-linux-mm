Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF6B6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 13:21:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n4so34999633qte.18
        for <linux-mm@kvack.org>; Tue, 02 May 2017 10:21:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m63si17021055qkc.305.2017.05.02.10.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 10:21:53 -0700 (PDT)
Date: Tue, 2 May 2017 14:21:23 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170502172120.GB5457@amt.cnet>
References: <20170425135717.375295031@redhat.com>
 <20170425135846.203663532@redhat.com>
 <20170502102836.4a4d34ba@redhat.com>
 <20170502165159.GA5457@amt.cnet>
 <20170502131527.7532fc2e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502131527.7532fc2e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Tue, May 02, 2017 at 01:15:27PM -0400, Luiz Capitulino wrote:
> On Tue, 2 May 2017 13:52:00 -0300
> Marcelo Tosatti <mtosatti@redhat.com> wrote:
> 
> > > I have several questions about the tunables:
> > > 
> > >  - What does the vmstat_threshold value mean? What are the implications
> > >    of changing this value? What's the difference in choosing 1, 2, 3
> > >    or 500?  
> > 
> > Its the maximum value for a vmstat statistics counter to hold. After
> > that value, the statistics are transferred to the global counter:
> > 
> > void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
> >                                 long delta)
> > {
> >         struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
> >         s8 __percpu *p = pcp->vm_node_stat_diff + item;
> >         long x;
> >         long t;
> > 
> >         x = delta + __this_cpu_read(*p);
> > 
> >         t = __this_cpu_read(pcp->stat_threshold);
> > 
> >         if (unlikely(x > t || x < -t)) {
> >                 node_page_state_add(x, pgdat, item);
> >                 x = 0;
> >         }
> >         __this_cpu_write(*p, x);
> > }
> > EXPORT_SYMBOL(__mod_node_page_state);
> > 
> > BTW, there is a bug there, should change that to:
> > 
> >         if (unlikely(x >= t || x <= -t)) {
> > 
> > Increasing the threshold value does two things:
> > 	1) It decreases the number of inter-processor accesses.
> > 	2) It increases how much the global counters stay out of
> > 	   sync relative to actual current values.
> 
> OK, but I'm mostly concerned with the sysadmin who will have
> to change the tunable. So, I think it's a good idea to improve
> the doc to contain that information.

Yes, how is that:

Index: linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt	2017-05-02 13:48:45.946840708 -0300
@@ -0,0 +1,78 @@
+Userspace configurable vmstat thresholds
+========================================
+
+This document describes the tunables to control
+per-CPU vmstat threshold and per-CPU vmstat worker
+thread.
+
+/sys/devices/system/cpu/cpuN/vmstat/vmstat_threshold:
+
+This file contains the per-CPU vmstat threshold.
+This value is the maximum that a single per-CPU vmstat statistic
+can accumulate before transferring to the global counters.
+
+A value of 0 indicates that the value is set
+by the in kernel algorithm.
+
+A value different than 0 indicates that particular
+value is used for vmstat_threshold.
+
+/sys/devices/system/cpu/cpuN/vmstat/vmstat_worker:
+
+Enable/disable the per-CPU vmstat worker.
+
+What does the vmstat_threshold value mean? What are the implications
+of changing this value? What's the difference in choosing 1, 2, 3
+or 500?
+====================================================================
+
+Its the maximum value for a vmstat statistics counter to hold. After
+that value, the statistics are transferred to the global counter:
+
+void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+                                long delta)
+{
+        struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+        s8 __percpu *p = pcp->vm_node_stat_diff + item;
+        long x;
+        long t;
+
+        x = delta + __this_cpu_read(*p);
+
+        t = __this_cpu_read(pcp->stat_threshold);
+
+        if (unlikely(x > t || x < -t)) {
+                node_page_state_add(x, pgdat, item);
+                x = 0;
+        }
+        __this_cpu_write(*p, x);
+}
+
+Increasing the threshold value does two things:
+        1) It decreases the number of inter-processor accesses.
+        2) It increases how much the global counters stay out of
+           sync relative to actual current values.
+
+
+Usage example:
+=============
+
+In a realtime system, the worker thread waking up and executing
+vmstat_update can be an undesired source of latencies.
+
+To avoid the worker thread from waking up, executing vmstat_update
+on cpu 1, for example, perform the following steps:
+
+
+cd /sys/devices/system/cpu/cpu0/vmstat/
+
+# Set vmstat threshold to 1 for cpu1, so that no
+# vmstat statistics are collected in cpu1's per-cpu
+# stats, instead they are immediately transferred
+# to the global counter.
+
+$ echo 1 > vmstat_threshold
+
+# Disable vmstat_update worker for cpu1:
+$ echo 0 > vmstat_worker
+


> > >  - If the purpose of having vmstat_threshold is to allow disabling
> > >    the vmstat kworker, why can't the kernel pick a value automatically?  
> > 
> > Because it might be acceptable for the user to accept a small 
> > out of syncedness of the global counters in favour of performance
> > (one would have to analyze the situation).
> > 
> > Setting vmstat_threshold == 1 means the global counter is always
> > in sync with the page counter state of the pCPU.
> 
> IMHO, if vmstat_threshold == 1 is the required setting for
> disabling the vmstat kworker then I'd go with only one tunable
> for now. But that's just a suggestion.

I didnt want to force that on the user because allowing different 
tunables covers more cases.

> > >  - What are the implications of disabling the vmstat kworker? Will vm
> > >    stats still be collected someway or will it be completely off for
> > >    the CPU?  
> > 
> > It will not be necessary to collect vmstats because at every modification
> > of the vm statistics, pCPUs with vmstat_threshold=1 transfer their 
> > values to the global counters (that is, there is no queueing of statistics
> > locally to improve performance).
> 
> Ah, OK. Got this now. I'll give this patch a try. But I think we want
> to hear from Christoph (who worked on reducing the vmstat interruptions
> in the past).

Christoph?

> > > Also, shouldn't this patch be split into two?  
> > 
> > First add one sysfs file, then add another sysfs file, you mean?
> 
> Yes, one tunable per patch.

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
