Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C86C76B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 22:24:58 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so2904850wgh.23
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 19:24:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si7808818wjy.2.2014.06.25.19.24.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 19:24:57 -0700 (PDT)
Date: Thu, 26 Jun 2014 04:24:55 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [mmotm:master 155/319] kernel/printk/printk.c:269:37: error:
	'CONFIG_LOG_CPU_MAX_BUF_SHIFT' undeclared
Message-ID: <20140626022455.GC27687@wotan.suse.de>
References: <53ab75fb.TL6r6DI5RYoz6W9P%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ab75fb.TL6r6DI5RYoz6W9P%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, Jun 26, 2014 at 09:23:07AM +0800, kbuild test robot wrote:
>    kernel/printk/printk.c: In function 'log_buf_add_cpu':
> >> kernel/printk/printk.c:269:37: error: 'CONFIG_LOG_CPU_MAX_BUF_SHIFT' undeclared (first use in this function)
>     #define __LOG_CPU_MAX_BUF_LEN (1 << CONFIG_LOG_CPU_MAX_BUF_SHIFT)

Indeed, this fixes it, Andrew should I respin or submit a fix for this
as a separate patch, let me know what you prefer.

  Luis

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 83f7a95..65ed0a6 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -266,7 +266,11 @@ static u32 clear_idx;
 #define LOG_ALIGN __alignof__(struct printk_log)
 #endif
 #define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
+#if defined(CONFIG_LOG_CPU_MAX_BUF_SHIFT)
 #define __LOG_CPU_MAX_BUF_LEN (1 << CONFIG_LOG_CPU_MAX_BUF_SHIFT)
+#else
+#define __LOG_CPU_MAX_BUF_LEN 1
+#endif
 static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
 static char *log_buf = __log_buf;
 static u32 log_buf_len = __LOG_BUF_LEN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
