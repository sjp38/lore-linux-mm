Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCBEA6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 20:28:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so47740040wme.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:28:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r3si4838131wmd.81.2016.11.29.17.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 17:28:22 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAU1NfpB027022
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 20:28:20 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271hre32qt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 20:28:20 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 29 Nov 2016 18:28:20 -0700
Date: Tue, 29 Nov 2016 17:28:17 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161129212308.GA12447@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129212308.GA12447@roeck-us.net>
Message-Id: <20161130012817.GH3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On Tue, Nov 29, 2016 at 01:23:08PM -0800, Guenter Roeck wrote:
> Hi Paul,
> 
> most of my qemu tests for sparc32 targets started to fail in next-20161129.
> The problem is only seen in SMP builds; non-SMP builds are fine.
> Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
> RCU CPU stall warnings"); reverting that commit fixes the problem.
> 
> Test scripts are available at:
> 	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc
> Test results are at:
> 	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc
> 
> Bisect log is attached.
> 
> Please let me know if there is anything I can do to help tracking down the
> problem.

Apologies!!!  Does the patch below help?

							Thanx, Paul

------------------------------------------------------------------------

commit 97708e737e2a55fed4bdbc005bf05ea909df6b73
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Nov 29 11:06:05 2016 -0800

    rcu: Allow boot-time use of cond_resched_rcu_qs()
    
    The cond_resched_rcu_qs() macro is used to force RCU quiescent states into
    long-running in-kernel loops.  However, some of these loops can execute
    during early boot when interrupts are disabled, and during which time
    it is therefore illegal to enter the scheduler.  This commit therefore
    makes cond_resched_rcu_qs() be a no-op during early boot.
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 525ca34603b7..b6944cc19a07 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -423,7 +423,7 @@ extern struct srcu_struct tasks_rcu_exit_srcu;
  */
 #define cond_resched_rcu_qs() \
 do { \
-	if (!cond_resched()) \
+	if (!is_idle_task(current) && !cond_resched()) \
 		rcu_note_voluntary_context_switch(current); \
 } while (0)
 
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index 7232d199a81c..20f5990deeee 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -228,6 +228,7 @@ static inline void exit_rcu(void)
 extern int rcu_scheduler_active __read_mostly;
 void rcu_scheduler_starting(void);
 #else /* #ifdef CONFIG_DEBUG_LOCK_ALLOC */
+#define rcu_scheduler_active false
 static inline void rcu_scheduler_starting(void)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
