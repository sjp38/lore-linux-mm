Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 459F86B025D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:32:26 -0500 (EST)
Received: by iow186 with SMTP id 186so35770358iow.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:32:26 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id h134si19262903ioe.68.2015.12.14.10.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 10:32:25 -0800 (PST)
Date: Mon, 14 Dec 2015 12:32:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on
 idle
In-Reply-To: <alpine.DEB.2.20.1512101940230.21007@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1512141230560.25288@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org> <20151210153118.4f39d6a4f04c96189ce015c9@linux-foundation.org> <alpine.DEB.2.20.1512101940230.21007@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp

Hmmm... We got a race condition since quiet_vmstat touches cpu_stat_off
which may not be allocated early in the bootup sequence. Causes oopses on
boot.



Subject: vmstat: quieting vmstat requires a running system

Do not do anything unless the system is actually running. Otherwise
we may crash on bootup.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1270,6 +1270,9 @@ static void vmstat_update(struct work_st
  */
 void quiet_vmstat(void)
 {
+	if (system_state != SYSTEM_RUNNING)
+		return;
+
 	do {
 		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
 			cancel_delayed_work(this_cpu_ptr(&vmstat_work));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
