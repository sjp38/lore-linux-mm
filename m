Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6766B0254
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:36:29 -0400 (EDT)
Received: by lbbzr7 with SMTP id zr7so18726961lbb.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:36:28 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id cq12si7964861lad.97.2015.07.24.09.36.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 09:36:27 -0700 (PDT)
Date: Fri, 24 Jul 2015 19:36:12 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: randconfig build error with next-20150724, in mm/page_ext.c
Message-ID: <20150724163612.GK8100@esperanza>
References: <CA+r1ZhhXUi3huTQ8GJmX5EeqWV58Fsni9eKjA-wd2irckJUagA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CA+r1ZhhXUi3huTQ8GJmX5EeqWV58Fsni9eKjA-wd2irckJUagA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Davis <jim.epost@gmail.com>
Cc: linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 09:27:53AM -0700, Jim Davis wrote:

> warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY && IDLE_PAGE_TRACKING)
> selects PROC_PAGE_MONITOR which has unmet direct dependencies (PROC_FS
> && MMU)
> 
> mm/built-in.o: In function `page_ext_init_flatmem':
> (.init.text+0x30ef): undefined reference to `page_idle_ops'
> mm/built-in.o: In function `page_ext_init_flatmem':
> (.init.text+0x3172): undefined reference to `page_idle_ops'

This has already been reported by the kbuild test robot, see:

  [mmotm:master 260/385] warning: (HWPOISON_INJECT && ..) selects PROC_PAGE_MONITOR which has unmet direct dependencies (PROC_FS && ..)

It should be fixed by:

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] mm/Kconfig: fix IDLE_PAGE_TRACKING dependencies

Fixes: proc-add-kpageidle-file
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/mm/Kconfig b/mm/Kconfig
index db817e2c2ec8..a1de09926171 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -657,6 +657,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
+	depends on PROC_FS && MMU
 	select PROC_PAGE_MONITOR
 	select PAGE_EXTENSION if !64BIT
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
