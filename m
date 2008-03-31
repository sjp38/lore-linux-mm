Date: Mon, 31 Mar 2008 13:19:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
In-Reply-To: <20080329150630.21019399.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0803311317060.9698@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com> <20080318182035.197900850@sgi.com>
 <20080328011240.fae44d52.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
 <20080328115919.12c0445b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803281159250.18120@schroedinger.engr.sgi.com>
 <20080328122313.aa8d7c8c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803291321020.26338@schroedinger.engr.sgi.com>
 <20080329150630.21019399.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: apw@shadowen.org, davem@davemloft.net, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, jeremy@goop.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 29 Mar 2008, Andrew Morton wrote:

> > This is the same process as used in arch/*/asm-offsets.*
> 
> Maybe that wasn't the best way of doing it.

Is there any alternative? It would be best if we could get the c compiler
to define a linker symbol with the values that we need without asm. I 
guess we could somehow stick this into ldlinux.lds.S but that is going to 
be ugly as well.

I checked and all arches use the same asm to define a symbol except for 
mips. If we allow an arch to override the way to define a symbol then it 
also works on mips.




From: Christoph Lameter <clameter@sgi.com>
Subject: Allow override of definition for asm constant

MIPS has a different way of defining asm constants which causes troubles
for bounds.h generation.

Add a new per arch CONFIG variable

	CONFIG_ASM_SYMBOL_PREFIX

which can be set to define an alternate header for asm constant definitions.
Use this for MIPS to make bounds determination work right.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/mips/Kconfig |    7 +++++++
 kernel/bounds.c   |   11 ++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc5-mm1/arch/mips/Kconfig
===================================================================
--- linux-2.6.25-rc5-mm1.orig/arch/mips/Kconfig	2008-03-31 13:14:26.888383587 -0700
+++ linux-2.6.25-rc5-mm1/arch/mips/Kconfig	2008-03-31 13:14:28.028403612 -0700
@@ -2019,6 +2019,13 @@ config I8253
 config ZONE_DMA32
 	bool
 
+#
+# Used to override gas symbol setup in kernel/bounds.c.
+#
+config ASM_SYMBOL_PREFIX
+	string
+	default "@@@#define "
+
 source "drivers/pcmcia/Kconfig"
 
 source "drivers/pci/hotplug/Kconfig"
Index: linux-2.6.25-rc5-mm1/kernel/bounds.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/kernel/bounds.c	2008-03-31 13:14:26.904383870 -0700
+++ linux-2.6.25-rc5-mm1/kernel/bounds.c	2008-03-31 13:14:28.028403612 -0700
@@ -9,8 +9,17 @@
 #include <linux/page-flags.h>
 #include <linux/mmzone.h>
 
+#ifdef CONFIG_ASM_SYMBOL_PREFIX
+#define PREFIX CONFIG_ASM_SYMBOL_PREFIX
+#else
+/*
+ * Standard gas way of defining an asm symbol
+ */
+#define PREFIX "->"
+#endif
+
 #define DEFINE(sym, val) \
-	asm volatile("\n->" #sym " %0 " #val : : "i" (val))
+	asm volatile("\n" PREFIX #sym " %0 " : : "i" (val))
 
 #define BLANK() asm volatile("\n->" : :)
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
