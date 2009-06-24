Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 489B36B005A
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 09:17:53 -0400 (EDT)
Subject: Re: kmemleak: Early log buffer exceeded
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090624100809.GA3299@localdomain.by>
References: <20090623212648.GA9502@localdomain.by>
	 <1245836105.16283.13.camel@pc1117.cambridge.arm.com>
	 <20090624100809.GA3299@localdomain.by>
Content-Type: text/plain
Date: Wed, 24 Jun 2009 14:18:20 +0100
Message-Id: <1245849500.32629.22.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-24 at 13:08 +0300, Sergey Senozhatsky wrote:
> On (06/24/09 10:35), Catalin Marinas wrote:
> > > So, my questions are:
> > > 1. Is 200 really enough? Why 200 not 512, 1024 (for example)?
> > 
> > It seems that in your case it isn't. It is fine on the machines I tested
> > it on but choosing this figure wasn't too scientific.
> > 
> > I initially had it bigger and marked with the __init attribute to free
> > it after initialisation but this was causing (harmless) section mismatch
> > warnings.
> 
> Why not configure it?

Yes, that's the best approach for now. As for dynamic allocation,
alloc_bootmem is the only option but it needs more testing to make sure
it doesn't fail in certain circumstances.

> (Well, CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE is a bit ugly.)

I couldn't come up with a better one either. Here's the patch:


kmemleak: Allow the early log buffer to be configurable.

From: Catalin Marinas <catalin.marinas@arm.com>

Kmemleak needs to track all the memory allocations but some of these
happen before kmemleak is initialised. These are stored in an internal
buffer which may be exceeded in some kernel configurations. This patch
adds a configuration option with a default value of 300 and removes the
stack dump when the kmemleak early log buffer is exceeded.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 lib/Kconfig.debug |   12 ++++++++++++
 mm/kmemleak.c     |    5 +++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4c32b1a..5cba26f 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -359,6 +359,18 @@ config DEBUG_KMEMLEAK
 	  In order to access the kmemleak file, debugfs needs to be
 	  mounted (usually at /sys/kernel/debug).
 
+config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
+	int "Maximum kmemleak early log entries"
+	depends on DEBUG_KMEMLEAK
+	range 200 2000
+	default 300
+	help
+	  Kmemleak must track all the memory allocations to avoid
+	  reporting false positives. Since memory may be allocated or
+	  freed before kmemleak is initialised, an early log buffer is
+	  used to store these actions. If kmemleak reports "early log
+	  buffer exceeded", please increase this value.
+
 config DEBUG_KMEMLEAK_TEST
 	tristate "Simple test for the kernel memory leak detector"
 	depends on DEBUG_KMEMLEAK
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c96f2c8..17096d1 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -235,7 +235,7 @@ struct early_log {
 };
 
 /* early logging buffer and current position */
-static struct early_log early_log[200];
+static struct early_log early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE];
 static int crt_early_log;
 
 static void kmemleak_disable(void);
@@ -696,7 +696,8 @@ static void log_early(int op_type, const void *ptr, size_t size,
 	struct early_log *log;
 
 	if (crt_early_log >= ARRAY_SIZE(early_log)) {
-		kmemleak_stop("Early log buffer exceeded\n");
+		pr_warning("Early log buffer exceeded\n");
+		kmemleak_disable();
 		return;
 	}
 

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
