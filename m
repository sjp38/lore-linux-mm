Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 68B426B0031
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 04:29:03 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so554135wib.0
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 01:29:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hx1si7784852wjb.169.2014.06.26.01.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 01:29:02 -0700 (PDT)
Date: Thu, 26 Jun 2014 10:29:00 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [mmotm:master 155/319] kernel/printk/printk.c:269:37: error:
	'CONFIG_LOG_CPU_MAX_BUF_SHIFT' undeclared
Message-ID: <20140626082900.GD27687@wotan.suse.de>
References: <53ab75fb.TL6r6DI5RYoz6W9P%fengguang.wu@intel.com> <20140626022455.GC27687@wotan.suse.de> <alpine.DEB.2.02.1406252308160.3960@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406252308160.3960@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Wed, Jun 25, 2014 at 11:10:28PM -0700, David Rientjes wrote:
> On Thu, 26 Jun 2014, Luis R. Rodriguez wrote:
> 
> > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > index 83f7a95..65ed0a6 100644
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> > @@ -266,7 +266,11 @@ static u32 clear_idx;
> >  #define LOG_ALIGN __alignof__(struct printk_log)
> >  #endif
> >  #define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
> > +#if defined(CONFIG_LOG_CPU_MAX_BUF_SHIFT)
> >  #define __LOG_CPU_MAX_BUF_LEN (1 << CONFIG_LOG_CPU_MAX_BUF_SHIFT)
> > +#else
> > +#define __LOG_CPU_MAX_BUF_LEN 1
> > +#endif
> >  static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
> >  static char *log_buf = __log_buf;
> >  static u32 log_buf_len = __LOG_BUF_LEN;
> 
> No, I think this would be much cleaner to just define 
> CONFIG_LOG_CPU_MAX_BUF_SHIFT unconditionally to 0 when !SMP || BASE_SMALL 
> and otherwise allow it to be configured according to the allowed range.
> 
> The verbosity of this configuration option is just downright excessive.

Good point, this seems to do it:

diff --git a/init/Kconfig b/init/Kconfig
index 573d3f6..2339118 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -822,10 +822,9 @@ config LOG_BUF_SHIFT
 
 config LOG_CPU_MAX_BUF_SHIFT
 	int "CPU kernel log buffer size contribution (13 => 8 KB, 17 => 128KB)"
-	range 0 21
-	default 12
-	depends on SMP
-	depends on !BASE_SMALL
+	range 0 21 if SMP && !BASE_SMALL
+	default 12 if SMP && !BASE_SMALL
+	default 0 if !SMP || BASE_SMALL
 	help
 	  The kernel ring buffer will get additional data logged onto it
 	  when multiple CPUs are supported. Typically the contributions are

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
