Message-Id: <200205160612.g4G6CMY16004@Port.imtp.ilyichevsk.odessa.ua>
Content-Type: text/plain;
  charset="us-ascii"
From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Subject: Re: [RFC][PATCH] iowait statistics
Date: Thu, 16 May 2002 09:14:53 -0200
References: <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15 May 2002 14:13, Rik van Riel wrote:
> On Wed, 15 May 2002, Denis Vlasenko wrote:
> > I think two patches for same kernel piece at the same time is
> > too many. Go ahead and code this if you want.
>
> OK, here it is.   Changes against yesterday's patch:
>
> 1) make sure idle time can never go backwards by incrementing
>    the idle time in the timer interrupt too (surely we can
>    take this overhead if we're idle anyway ;))
>
> 2) get_request_wait also raises nr_iowait_tasks (thanks akpm)
>
> This patch is against the latest 2.5 kernel from bk and
> pretty much untested. If you have the time, please test
> it and let me know if it works.


--- 1.73/kernel/sched.c Mon Apr 29 09:16:24 2002
+++ edited/kernel/sched.c       Wed May 15 12:58:18 2002
@@ -679,6 +679,10 @@
        if (p == rq->idle) {
		[*]
                if (local_bh_count(cpu) || local_irq_count(cpu) > 1)
                        kstat.per_cpu_system[cpu] += system;
+               else if (atomic_read(&nr_iowait_tasks) > 0)
+                       kstat.per_cpu_iowait[cpu] += system;
+               else
+                       kstat.per_cpu_idle[cpu] += system;

[*] Maybe add if(system!=0) there?
--
vda
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
