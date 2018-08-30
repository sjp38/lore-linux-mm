Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7B526B5038
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 03:43:31 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id o22-v6so46638lfk.5
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 00:43:31 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id i27-v6si4910207lfb.0.2018.08.30.00.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 00:43:30 -0700 (PDT)
Date: Thu, 30 Aug 2018 09:43:27 +0200
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: Re: [PATCHv2] kmemleak: Add option to print warnings to dmesg
Message-ID: <20180830074327.ivjq6g25lw7kpz2l@axis.com>
References: <20180827083821.7706-1-vincent.whitchurch@axis.com>
 <20180827151641.59bdca4e1ea2e532b10cd9fd@linux-foundation.org>
 <20180828101412.mb7t562roqbhsbjw@axis.com>
 <20180828102621.yawpcrkikhh4kagv@armageddon.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828102621.yawpcrkikhh4kagv@armageddon.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 28, 2018 at 11:26:22AM +0100, Catalin Marinas wrote:
> On Tue, Aug 28, 2018 at 12:14:12PM +0200, Vincent Whitchurch wrote:
> > On Mon, Aug 27, 2018 at 03:16:41PM -0700, Andrew Morton wrote:
> > > On Mon, 27 Aug 2018 10:38:21 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:
> > > > +config DEBUG_KMEMLEAK_WARN
> > > > +	bool "Print kmemleak object warnings to log buffer"
> > > > +	depends on DEBUG_KMEMLEAK
> > > > +	help
> > > > +	  Say Y here to make kmemleak print information about unreferenced
> > > > +	  objects (including stacktraces) as warnings to the kernel log buffer.
> > > > +	  Otherwise this information is only available by reading the kmemleak
> > > > +	  debugfs file.
> > > 
> > > Why add the config option?  Why not simply make the change for all
> > > configs?
> > 
> > No particular reason other than preserving the current behaviour for
> > existing users.  I can remove the config option if Catalin is fine with
> > it.
> 
> IIRC, in the early kmemleak days, people complained about it being to
> noisy (the false positives rate was also much higher), so the default
> behaviour was changed to monitor (almost) quietly with the details
> available via debugfs. I'd like to keep this default behaviour but we
> could have a "verbose" command via both debugfs and kernel parameter (as
> we do with "off" and "on"). Would this work for you?

Either a config option or a parameter are usable for me.  How about
something like this?  It can be enabled with kmemleak.verbose=1 or "echo
1 > /sys/module/kmemleak/parameters/verbose":

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 9a3fc905b8bd..ab1b599202bc 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -593,15 +593,6 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
 	  Say Y here to disable kmemleak by default. It can then be enabled
 	  on the command line via kmemleak=on.
 
-config DEBUG_KMEMLEAK_WARN
-	bool "Print kmemleak object warnings to log buffer"
-	depends on DEBUG_KMEMLEAK
-	help
-	  Say Y here to make kmemleak print information about unreferenced
-	  objects (including stacktraces) as warnings to the kernel log buffer.
-	  Otherwise this information is only available by reading the kmemleak
-	  debugfs file.
-
 config DEBUG_STACK_USAGE
 	bool "Stack utilization instrumentation"
 	depends on DEBUG_KERNEL && !IA64
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 22662715a3dc..c91d43738596 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -86,6 +86,7 @@
 #include <linux/seq_file.h>
 #include <linux/cpumask.h>
 #include <linux/spinlock.h>
+#include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/rcupdate.h>
 #include <linux/stacktrace.h>
@@ -236,6 +237,9 @@ static int kmemleak_skip_disable;
 /* If there are leaks that can be reported */
 static bool kmemleak_found_leaks;
 
+static bool kmemleak_verbose;
+module_param_named(verbose, kmemleak_verbose, bool, 0600);
+
 /*
  * Early object allocation/freeing logging. Kmemleak is initialized after the
  * kernel allocator. However, both the kernel allocator and kmemleak may
@@ -1618,9 +1622,10 @@ static void kmemleak_scan(void)
 		if (unreferenced_object(object) &&
 		    !(object->flags & OBJECT_REPORTED)) {
 			object->flags |= OBJECT_REPORTED;
-#ifdef CONFIG_DEBUG_KMEMLEAK_WARN
-			print_unreferenced(NULL, object);
-#endif
+
+			if (kmemleak_verbose)
+				print_unreferenced(NULL, object);
+
 			new_leaks++;
 		}
 		spin_unlock_irqrestore(&object->lock, flags);
