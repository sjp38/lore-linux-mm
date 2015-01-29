Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 300E66B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 12:32:47 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so36261523iec.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 09:32:46 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id cd4si6585237icc.40.2015.01.29.09.32.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 09:32:45 -0800 (PST)
Date: Thu, 29 Jan 2015 11:32:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150116154922.GB4650@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501291131510.22780@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Fri, 16 Jan 2015, Michal Hocko wrote:

> __round_jiffies_relative can easily make timeout 2HZ from 1HZ. Now we
> have vmstat_shepherd which waits to be queued and then wait to run. When
> it runs finally it only queues per-cpu vmstat_work which can also end
> up being 2HZ for some CPUs. So we can indeed have 4 seconds spent just
> for queuing. Not even mentioning work item latencies. Especially when
> workers are overloaded e.g. by fs work items and no additional workers
> cannot be created e.g. due to memory pressure so they are processed only
> by the workqueue rescuer. And latencies would grow a lot.

Here is a small fix to ensure that the 4 seconds interval does not happen:




Subject: vmstat: Reduce time interval to stat update on idle cpu

It was noted that the vm stat shepherd runs every 2 seconds and
that the vmstat update is then scheduled 2 seconds in the future.

This yields an interval of double the time interval which is not
desired.

Change the shepherd so that it does not delay the vmstat update
on the other cpu. We stil have to use schedule_delayed_work since
we are using a delayed_work_struct but we can set the delay to 0.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1435,8 +1435,8 @@ static void vmstat_shepherd(struct work_
 		if (need_update(cpu) &&
 			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))

-			schedule_delayed_work_on(cpu, &per_cpu(vmstat_work, cpu),
-				__round_jiffies_relative(sysctl_stat_interval, cpu));
+			schedule_delayed_work_on(cpu,
+				&per_cpu(vmstat_work, cpu), 0);

 	put_online_cpus();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
