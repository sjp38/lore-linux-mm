Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 518016B00F6
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:57:52 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id uo1so964530pbc.19
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:57:51 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 06/39] tile: normalize global variables exported by vmlinux.lds
Date: Tue, 26 Mar 2013 23:54:25 +0800
Message-Id: <1364313298-17336-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Rusty Russell <rusty@rustcorp.com.au>, Bjorn Helgaas <bhelgaas@google.com>, "David S. Miller" <davem@davemloft.net>

Normalize global variables exported by vmlinux.lds to conform usage
guidelines from include/asm-generic/sections.h.

1) Use _text to mark the start of the kernel image including the head
text, and _stext to mark the start of the .text section.
2) Export mandatory global variables __init_begin and __init_end.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: David Howells <dhowells@redhat.com>
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
 arch/tile/include/asm/sections.h |    2 +-
 arch/tile/kernel/setup.c         |    4 ++--
 arch/tile/kernel/vmlinux.lds.S   |    4 +++-
 arch/tile/mm/init.c              |    2 +-
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/tile/include/asm/sections.h b/arch/tile/include/asm/sections.h
index d062d46..7d8a935 100644
--- a/arch/tile/include/asm/sections.h
+++ b/arch/tile/include/asm/sections.h
@@ -34,7 +34,7 @@ extern char __sys_cmpxchg_grab_lock[];
 extern char __start_atomic_asm_code[], __end_atomic_asm_code[];
 #endif
 
-/* Handle the discontiguity between _sdata and _stext. */
+/* Handle the discontiguity between _sdata and _text. */
 static inline int arch_is_kernel_data(unsigned long addr)
 {
 	return addr >= (unsigned long)_sdata &&
diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
index d1e15f7..a986b71 100644
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -307,8 +307,8 @@ static void __cpuinit store_permanent_mappings(void)
 		hv_store_mapping(addr, pages << PAGE_SHIFT, pa);
 	}
 
-	hv_store_mapping((HV_VirtAddr)_stext,
-			 (uint32_t)(_einittext - _stext), 0);
+	hv_store_mapping((HV_VirtAddr)_text,
+			 (uint32_t)(_einittext - _text), 0);
 }
 
 /*
diff --git a/arch/tile/kernel/vmlinux.lds.S b/arch/tile/kernel/vmlinux.lds.S
index 631f10d..a13ed90 100644
--- a/arch/tile/kernel/vmlinux.lds.S
+++ b/arch/tile/kernel/vmlinux.lds.S
@@ -27,7 +27,6 @@ SECTIONS
   .intrpt1 (LOAD_OFFSET) : AT ( 0 )   /* put at the start of physical memory */
   {
     _text = .;
-    _stext = .;
     *(.intrpt1)
   } :intrpt1 =0
 
@@ -36,6 +35,7 @@ SECTIONS
 
   /* Now the real code */
   . = ALIGN(0x20000);
+  _stext = .;
   .text : AT (ADDR(.text) - LOAD_OFFSET) {
     HEAD_TEXT
     SCHED_TEXT
@@ -58,11 +58,13 @@ SECTIONS
   #define LOAD_OFFSET PAGE_OFFSET
 
   . = ALIGN(PAGE_SIZE);
+  __init_begin = .;
   VMLINUX_SYMBOL(_sinitdata) = .;
   INIT_DATA_SECTION(16) :data =0
   PERCPU_SECTION(L2_CACHE_BYTES)
   . = ALIGN(PAGE_SIZE);
   VMLINUX_SYMBOL(_einitdata) = .;
+  __init_end = .;
 
   _sdata = .;                   /* Start of data section */
 
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 45ce26d..f2ac2f4 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -562,7 +562,7 @@ static void __init kernel_physical_mapping_init(pgd_t *pgd_base)
 			prot = ktext_set_nocache(prot);
 		}
 
-		BUG_ON(address != (unsigned long)_stext);
+		BUG_ON(address != (unsigned long)_text);
 		pte = NULL;
 		for (; address < (unsigned long)_einittext;
 		     pfn++, address += PAGE_SIZE) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
