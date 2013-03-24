Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 1DA126B0027
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:27:16 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id s35so2797005dak.20
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:27:15 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 02/39] avr32: normalize global variables exported by vmlinux.lds
Date: Sun, 24 Mar 2013 15:24:28 +0800
Message-Id: <1364109934-7851-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

Normalize global variables exported by vmlinux.lds to conform usage
guidelines from include/asm-generic/sections.h.

Use _text to mark the start of the kernel image including the head text,
and _stext to mark the start of the .text section.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: linux-kernel@vger.kernel.org
---
 arch/avr32/kernel/setup.c       |    2 +-
 arch/avr32/kernel/vmlinux.lds.S |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/avr32/kernel/setup.c b/arch/avr32/kernel/setup.c
index b4247f4..209ae5a 100644
--- a/arch/avr32/kernel/setup.c
+++ b/arch/avr32/kernel/setup.c
@@ -555,7 +555,7 @@ void __init setup_arch (char **cmdline_p)
 {
 	struct clk *cpu_clk;
 
-	init_mm.start_code = (unsigned long)_text;
+	init_mm.start_code = (unsigned long)_stext;
 	init_mm.end_code = (unsigned long)_etext;
 	init_mm.end_data = (unsigned long)_edata;
 	init_mm.brk = (unsigned long)_end;
diff --git a/arch/avr32/kernel/vmlinux.lds.S b/arch/avr32/kernel/vmlinux.lds.S
index 9cd2bd9..a458917 100644
--- a/arch/avr32/kernel/vmlinux.lds.S
+++ b/arch/avr32/kernel/vmlinux.lds.S
@@ -23,7 +23,7 @@ SECTIONS
 {
 	. = CONFIG_ENTRY_ADDRESS;
 	.init		: AT(ADDR(.init) - LOAD_OFFSET) {
-		_stext = .;
+		_text = .;
 		__init_begin = .;
 			_sinittext = .;
 			*(.text.reset)
@@ -46,7 +46,7 @@ SECTIONS
 
 	.text		: AT(ADDR(.text) - LOAD_OFFSET) {
 		_evba = .;
-		_text = .;
+		_stext = .;
 		*(.ex.text)
 		*(.irq.text)
 		KPROBES_TEXT
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
