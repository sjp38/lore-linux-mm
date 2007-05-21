Message-ID: <465177E9.3060601@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net>	<464ED258.2010903@users.sourceforge.net> <20070520203123.5cde3224.akpm@linux-foundation.org>
In-Reply-To: <20070520203123.5cde3224.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Mon, 21 May 2007 12:44:20 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Well OK.  But vdso-print-fatal-signals.patch is designated not-for-mainline
> anyway.
> 
> I think the DoS which you identify has been available for a very long time
> on ia64, x86_64 and perhaps others.
> 

For the mainline a fix could be the following...

---

Limit the rate of the kernel logging for the segfaults of user applications, to
avoid potential message floods or denial-of-service attacks.

Signed-off-by: Andrea Righi <a.righi@cineca.it>

diff -urpN linux-2.6.22-rc2/arch/avr32/mm/fault.c linux-2.6.22-rc2-limit-segfaults-printk-rate/arch/avr32/mm/fault.c
--- linux-2.6.22-rc2/arch/avr32/mm/fault.c	2007-05-19 13:11:30.000000000 +0200
+++ linux-2.6.22-rc2-limit-segfaults-printk-rate/arch/avr32/mm/fault.c	2007-05-21 11:48:37.000000000 +0200
@@ -158,7 +158,7 @@ bad_area:
 	up_read(&mm->mmap_sem);
 
 	if (user_mode(regs)) {
-		if (exception_trace)
+		if (exception_trace && printk_ratelimit())
 			printk("%s%s[%d]: segfault at %08lx pc %08lx "
 			       "sp %08lx ecr %lu\n",
 			       is_init(tsk) ? KERN_EMERG : KERN_INFO,
diff -urpN linux-2.6.22-rc2/arch/x86_64/mm/fault.c linux-2.6.22-rc2-limit-segfaults-printk-rate/arch/x86_64/mm/fault.c
--- linux-2.6.22-rc2/arch/x86_64/mm/fault.c	2007-05-21 11:42:07.000000000 +0200
+++ linux-2.6.22-rc2-limit-segfaults-printk-rate/arch/x86_64/mm/fault.c	2007-05-21 11:45:55.000000000 +0200
@@ -489,7 +489,8 @@ bad_area_nosemaphore:
 		    (address >> 32))
 			return;
 
-		if (exception_trace && unhandled_signal(tsk, SIGSEGV)) {
+		if (exception_trace && unhandled_signal(tsk, SIGSEGV) &&
+		    printk_ratelimit()) {
 			printk(
 		       "%s%s[%d]: segfault at %016lx rip %016lx rsp %016lx error %lx\n",
 					tsk->pid > 1 ? KERN_INFO : KERN_EMERG,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
