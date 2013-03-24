Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DD3C46B0036
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:27:22 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa10so541360pad.13
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:27:22 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 03/39] c6x: normalize global variables exported by vmlinux.lds
Date: Sun, 24 Mar 2013 15:24:29 +0800
Message-Id: <1364109934-7851-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <a-jacquiot@ti.com>, linux-c6x-dev@linux-c6x.org

Normalize global variables exported by vmlinux.lds to conform usage
guidelines from include/asm-generic/sections.h.

Use _text to mark the start of the kernel image including the head text,
and _stext to mark the start of the .text section.

This patch also fixes possible bugs due to current address layout that
[__init_begin, __init_end] is a sub-range of [_stext, _etext] and pages
within range [__init_begin, __init_end] will be freed by free_initmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-kernel@vger.kernel.org
---
 arch/c6x/kernel/vmlinux.lds.S |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/c6x/kernel/vmlinux.lds.S b/arch/c6x/kernel/vmlinux.lds.S
index 1d81c4c..279d807 100644
--- a/arch/c6x/kernel/vmlinux.lds.S
+++ b/arch/c6x/kernel/vmlinux.lds.S
@@ -54,16 +54,15 @@ SECTIONS
 	}
 
 	. = ALIGN(PAGE_SIZE);
+	__init_begin = .;
 	.init :
 	{
-		_stext = .;
 		_sinittext = .;
 		HEAD_TEXT
 		INIT_TEXT
 		_einittext = .;
 	}
 
-	__init_begin = _stext;
 	INIT_DATA_SECTION(16)
 
 	PERCPU_SECTION(128)
@@ -74,6 +73,7 @@ SECTIONS
 	.text :
 	{
 		_text = .;
+		_stext = .;
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
