Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAAFF6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:41:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q126so140906009pga.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:41:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 61si8699154pla.323.2017.03.17.06.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 06:41:13 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:41:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [locking/lockdep] 383776fa75:  INFO: trying to register
 non-static key.
Message-ID: <20170317134109.e7qmjwpryelpbgz2@hirez.programming.kicks-ass.net>
References: <58cad449.RTO+aYLdogbZs5Le%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58cad449.RTO+aYLdogbZs5Le%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@kernel.org>, wfg@linux.intel.com

On Fri, Mar 17, 2017 at 02:07:05AM +0800, kernel test robot wrote:

>     locking/lockdep: Handle statically initialized PER_CPU locks properly

> [   11.712266] INFO: trying to register non-static key.

Blergh; so the problem is that when we assign can_addr to lock->key, we
can, upon using a different subclass, reach static_obj(lock->key), which
will fail on the can_addr.

One way to fix this would be to redefine the canonical address as the
per-cpu address for a specific cpu; the below hard codes cpu0, but I'm
not sure we want to rely on cpu0 being a valid cpu.


---
diff --git a/kernel/module.c b/kernel/module.c
index 5ef618133849..bdd9d62ce08c 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -682,8 +682,10 @@ bool __is_module_percpu_address(unsigned long addr, unsigned long *can_addr)
 			void *va = (void *)addr;
 
 			if (va >= start && va < start + mod->percpu_size) {
-				if (can_addr)
+				if (can_addr) {
 					*can_addr = (unsigned long) (va - start);
+					*can_addr += (unsigned long)per_cpu_ptr(mod->percpu, 0);
+				}
 				preempt_enable();
 				return true;
 			}
diff --git a/mm/percpu.c b/mm/percpu.c
index e30c995f2b7b..a5d7b7477888 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1296,8 +1296,10 @@ bool __is_kernel_percpu_address(unsigned long addr, unsigned long *can_addr)
 		void *va = (void *)addr;
 
 		if (va >= start && va < start + static_size) {
-			if (can_addr)
+			if (can_addr) {
 				*can_addr = (unsigned long) (va - start);
+				*can_addr += (unsigned long)per_cpu_ptr(base, 0);
+			}
 			return true;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
