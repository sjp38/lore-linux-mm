Date: Tue, 10 Apr 2007 19:24:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101922280.17722@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> Could print_track() be simplified by using -mm's sprint_symbol()?


SLUB: Use __print_symbol instead of kallsyms_lookup

SLUB contains a complicated section with #ifdef CONFIG_KALLSYSM and yadda
dadda. Remove that and replace with __print_symbol.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 19:21:29.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 19:21:51.000000000 -0700
@@ -290,27 +290,11 @@ static void init_tracking(struct kmem_ca
 
 static void print_track(const char *s, struct track *t)
 {
-#ifdef CONFIG_KALLSYMS
-	char *modname;
-	const char *name;
-	unsigned long offset, size;
-	char namebuf[KSYM_NAME_LEN + 1];
-#endif
-
 	if (!t->addr)
 		return;
 
-#ifdef CONFIG_KALLSYMS
-	name = kallsyms_lookup((unsigned long)t->addr, &size, &offset,
-		&modname, namebuf);
-
-	if (name) {
-		printk(KERN_ERR "%s: %s+%#lx/%#lx", s, name, offset, size);
-		if (modname)
-			printk(" [%s]", modname);
-	} else
-#endif
-		printk(KERN_ERR "%s: 0x%p", s, t->addr);
+	printk(KERN_ERR "%s: ", s);
+	__print_symbol("%s", (unsigned long)t->addr);
 	printk(" jiffies_ago=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
