Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5D1736B0006
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:27:57 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p12so160817pdj.5
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:27:56 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 07/39] UML: normalize global variables exported by vmlinux.lds
Date: Sun, 24 Mar 2013 15:24:33 +0800
Message-Id: <1364109934-7851-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Al Viro <viro@zeniv.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net

Normalize global variables exported by vmlinux.lds to conform usage
guidelines from include/asm-generic/sections.h.

1) Use _text to mark the start of the kernel image including the head
text, and _stext to mark the start of the .text section.
2) Export mandatory global variables __bss_stop.
3) Adjust __init_begin and __init_end to avoid acrossing .text and
   .data sections.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org
---
 arch/um/include/asm/common.lds.S |    1 -
 arch/um/kernel/dyn.lds.S         |    6 ++++--
 arch/um/kernel/uml.lds.S         |    7 +++++--
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/arch/um/include/asm/common.lds.S b/arch/um/include/asm/common.lds.S
index 4938de5..1dd5bd8 100644
--- a/arch/um/include/asm/common.lds.S
+++ b/arch/um/include/asm/common.lds.S
@@ -57,7 +57,6 @@
 	*(.uml.initcall.init)
 	__uml_initcall_end = .;
   }
-  __init_end = .;
 
   SECURITY_INIT
 
diff --git a/arch/um/kernel/dyn.lds.S b/arch/um/kernel/dyn.lds.S
index fb8fd6f..adde088 100644
--- a/arch/um/kernel/dyn.lds.S
+++ b/arch/um/kernel/dyn.lds.S
@@ -14,8 +14,6 @@ SECTIONS
   __binary_start = .;
   . = ALIGN(4096);		/* Init code and data */
   _text = .;
-  _stext = .;
-  __init_begin = .;
   INIT_TEXT_SECTION(PAGE_SIZE)
 
   . = ALIGN(PAGE_SIZE);
@@ -67,6 +65,7 @@ SECTIONS
   } =0x90909090
   .plt            : { *(.plt) }
   .text           : {
+    _stext = .;
     TEXT_TEXT
     SCHED_TEXT
     LOCK_TEXT
@@ -91,7 +90,9 @@ SECTIONS
 
   #include <asm/common.lds.S>
 
+  __init_begin = .;
   init.data : { INIT_DATA }
+  __init_end = .;
 
   /* Ensure the __preinit_array_start label is properly aligned.  We
      could instead move the label definition inside the section, but
@@ -155,6 +156,7 @@ SECTIONS
    . = ALIGN(32 / 8);
   . = ALIGN(32 / 8);
   }
+   __bss_stop = .;
   _end = .;
   PROVIDE (end = .);
 
diff --git a/arch/um/kernel/uml.lds.S b/arch/um/kernel/uml.lds.S
index ff65fb4..6899195 100644
--- a/arch/um/kernel/uml.lds.S
+++ b/arch/um/kernel/uml.lds.S
@@ -20,13 +20,12 @@ SECTIONS
   . = START + SIZEOF_HEADERS;
 
   _text = .;
-  _stext = .;
-  __init_begin = .;
   INIT_TEXT_SECTION(0)
   . = ALIGN(PAGE_SIZE);
 
   .text      :
   {
+    _stext = .;
     TEXT_TEXT
     SCHED_TEXT
     LOCK_TEXT
@@ -62,7 +61,10 @@ SECTIONS
 
   #include <asm/common.lds.S>
 
+  __init_begin = .;
   init.data : { INIT_DATA }
+  __init_end = .;
+
   .data    :
   {
     INIT_TASK_DATA(KERNEL_STACK_SIZE)
@@ -97,6 +99,7 @@ SECTIONS
   PROVIDE(_bss_start = .);
   SBSS(0)
   BSS(0)
+   __bss_stop = .;
   _end = .;
   PROVIDE (end = .);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
