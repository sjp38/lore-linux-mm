Date: Sun, 14 Nov 1999 11:06:25 +1300
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [patch] zoned-2.3.28-G5, zone-allocator, highmem, bootmem fixes
Message-ID: <19991114110625.A155@caffeine.ix.net.nz>
References: <Pine.LNX.4.10.9911132007310.4346-200000@chiara.csoma.elte.hu> <Pine.LNX.4.10.9911132231550.5769-101000@chiara.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.9911132231550.5769-101000@chiara.csoma.elte.hu>; from Ingo Molnar on Sat, Nov 13, 1999 at 10:33:29PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Christoph Rohland <hans-christoph.rohland@sap.com>
List-ID: <linux-mm.kvack.org>

> - modules should compile again.

you missed:

--- kernel/ksyms.c.orig	Sun Nov 14 10:38:09 1999
+++ kernel/ksyms.c	Sun Nov 14 10:38:24 1999
@@ -92,6 +92,7 @@
 EXPORT_SYMBOL(exit_sighand);
 
 /* internal kernel memory management */
+EXPORT_SYMBOL(zonelists);
 EXPORT_SYMBOL(__alloc_pages);
 EXPORT_SYMBOL(__free_pages_ok);
 EXPORT_SYMBOL(kmem_find_general_cachep);

> - cleaned up pgtable.h, split into lowlevel and highlevel parts, this
>   fixes dependencies in mm.h & misc.c.

should asm-i386/pgtable include pgalloc.h? This is required for
binfmt_aout but I don't think it is verr clean

--- fs/binfmt_aout.c.orig	Sun Nov 14 10:39:17 1999
+++ fs/binfmt_aout.c	Sun Nov 14 10:57:50 1999
@@ -28,6 +28,9 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
+#ifdef CONFIG_X86
+#include <asm/pgalloc.h>
+#endif
 
 static int load_aout_binary(struct linux_binprm *, struct pt_regs * regs);
 static int load_aout_library(int fd);

> - fixed boot task's swapper_pg_dir clearing

what else needs to be done to alloc the buffer cache to use the low
16MB? 

Oh, and on my laptop, performance is way down and it now swaps where
it did not before... (looks like processes can't use the lower 16M
either)



-cw



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
