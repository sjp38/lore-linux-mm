Date: 24 May 2004 02:09:29 +0200
Date: Mon, 24 May 2004 02:09:29 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: current -linus tree dies on x86_64
Message-ID: <20040524000929.GA91820@colin2.muc.de>
References: <20040522144857.3af1fc2c.akpm@osdl.org> <20040522235831.7bdb509d.akpm@osdl.org> <20040523012149.68fcde6d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040523012149.68fcde6d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 23, 2004 at 01:21:49AM -0700, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Andrew Morton <akpm@osdl.org> wrote:
> >  >
> >  > As soon as I put in enough memory pressure to start swapping it oopses in
> >  >  release_pages().
> > 
> >  I'm doing the bsearch on this.
> 
> The crash is caused by the below changeset.  I was using my own .config so
> the defconfig update is not the cause.  I guess either the pageattr.c
> changes or the instruction replacements.  The lesson here is to split dem
> patches up a bit!
> 
> Anyway.  Over to you, Andi.

Reverting this patch seems to fix it. But I have no idea why.
More tomorrow. 

-Andi



diff -burpN -X ../KDIFX linux-vanilla/include/asm-x86_64/processor.h linux-2.6.6-amd64/include/asm-x86_64/processor.h
--- linux-vanilla/include/asm-x86_64/processor.h	2004-05-14 13:13:50.000000000 +0200
+++ linux-2.6.6-amd64/include/asm-x86_64/processor.h	2004-05-09 23:10:51.000000000 +0200
@@ -345,7 +345,17 @@ struct extended_sigtable {
 /* '6' because it used to be for P6 only (but now covers Pentium 4 as well) */
 #define MICROCODE_IOCFREE	_IO('6',0)
 
+/* generic versions from gas */
+#define GENERIC_NOP1	".byte 0x90\n"
+#define GENERIC_NOP2    	".byte 0x89,0xf6\n"
+#define GENERIC_NOP3        ".byte 0x8d,0x76,0x00\n"
+#define GENERIC_NOP4        ".byte 0x8d,0x74,0x26,0x00\n"
+#define GENERIC_NOP5        GENERIC_NOP1 GENERIC_NOP4
+#define GENERIC_NOP6	".byte 0x8d,0xb6,0x00,0x00,0x00,0x00\n"
+#define GENERIC_NOP7	".byte 0x8d,0xb4,0x26,0x00,0x00,0x00,0x00\n"
+#define GENERIC_NOP8	GENERIC_NOP1 GENERIC_NOP7
 
+#ifdef CONFIG_MK8
 #define ASM_NOP1 K8_NOP1
 #define ASM_NOP2 K8_NOP2
 #define ASM_NOP3 K8_NOP3
@@ -354,6 +364,16 @@ struct extended_sigtable {
 #define ASM_NOP6 K8_NOP6
 #define ASM_NOP7 K8_NOP7
 #define ASM_NOP8 K8_NOP8
+#else
+#define ASM_NOP1 GENERIC_NOP1
+#define ASM_NOP2 GENERIC_NOP2
+#define ASM_NOP3 GENERIC_NOP3
+#define ASM_NOP4 GENERIC_NOP4
+#define ASM_NOP5 GENERIC_NOP5
+#define ASM_NOP6 GENERIC_NOP6
+#define ASM_NOP7 GENERIC_NOP7
+#define ASM_NOP8 GENERIC_NOP8
+#endif
 
 /* Opteron nops */
 #define K8_NOP1 ".byte 0x90\n"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
