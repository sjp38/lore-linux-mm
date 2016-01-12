Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id C26514403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:23:09 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id t15so118785842igr.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:23:09 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id y9si33012162igf.14.2016.01.12.04.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 04:23:09 -0800 (PST)
Date: Tue, 12 Jan 2016 06:23:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 12 Jan 2016, Shiraz Hashim wrote:

> > +       refresh_cpu_vm_stats(false);
> > +       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> >
>
> shouldn't this be cancel_delayed_work_sync ?

Hmmm... This is executed with preemption off and the work is on the same
cpu. If it would be able to run concurrently then we would need this.

Ok but it could run from the timer interrupt if that is still on and
occuring shortly before we go idle. Guess this needs to be similar to
the code we execute on cpu down in the vmstat notifiers (see
vmstat_cpuup_callback).

Does this fix it? I have not been able to reproduce the issue so far.

Patch against -next.



Subject: vmstat: Use delayed work_sync and avoid loop.

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
+	cancel_delayed_work_sync(this_cpu_ptr(&vmstat_work));
+	cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
 }

 /*




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
