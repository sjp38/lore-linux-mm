Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id ACBBD6B00F0
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:57:17 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bi5so1681146pad.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:57:15 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 03/39] c6x: normalize global variables exported by vmlinux.lds
Date: Tue, 26 Mar 2013 23:54:22 +0800
Message-Id: <1364313298-17336-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Aurelien Jacquiot <a-jacquiot@ti.com>, linux-c6x-dev@linux-c6x.org

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
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
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
