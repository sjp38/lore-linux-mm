Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 7E07A6B00E9
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:36:59 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so3131lbb.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:36:57 -0700 (PDT)
From: Avery Pennarun <apenwarr@gmail.com>
Subject: [PATCH 5/5] printk: CONFIG_PRINTK_PERSIST: persist printk buffer across reboots.
Date: Tue, 13 Mar 2012 01:36:41 -0400
Message-Id: <1331617001-20906-6-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Avery Pennarun <apenwarr@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Instead of using alloc_bootmem() when log_buf_len= is provided on the
command line, use reserve_bootmem() instead to try to reserve the memory at
a predictable physical address.  If we manage to get such an address, check
whether it has a valid header from last time, and if so, keep the data in
the existing buffer as if it had been printk'd as part of the current
session.  You can then retrieve or clear it with dmesg.  Note: you must
supply log_buf_len= on the kernel command line to activate this feature.

If reserve_bootmem() doesn't work out, we fall back to the old
alloc_bootmem() method.

The nice thing about this feature is it allows us to capture and upload
printk results after a crash and reboot, even if the system had hard crashed
so there was no chance to do something like panic or kexec.  The last few
messages before the crash might give a clue as to the crash.

Note: None of this is any use if your bootloader or BIOS wipes memory
between reboots.  On embedded systems, you have somewhat more control over
this.

Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
---
 init/Kconfig    |   12 ++++++
 kernel/printk.c |  106 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 109 insertions(+), 9 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 3f42cd6..d182c07 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1040,6 +1040,18 @@ config PRINTK
 	  very difficult to diagnose system problems, saying N here is
 	  strongly discouraged.
 
+config PRINTK_PERSIST
+	default n
+	bool "printk log persists across reboots" if PRINTK
+	help
+	  This option tries to keep the printk memory buffer in a well-known
+	  location in physical memory. It isn't cleared on reboot (unless RAM
+	  is wiped by your boot loader or BIOS) so if your system crashes
+	  or panics, you might get to examine all the log messages next time you
+	  boot. The persisted log messages show up in your 'dmesg' output.
+	  Note: you must supply the log_buf_len= kernel parameter to
+	  activate this feature.
+
 config BUG
 	bool "BUG() support" if EXPERT
 	default y
diff --git a/kernel/printk.c b/kernel/printk.c
index bf96a7d..f9045d9 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -110,7 +110,12 @@ static DEFINE_RAW_SPINLOCK(logbuf_lock);
  */
 static unsigned log_start;	/* Index into log_buf: next char to be read by syslog() */
 static unsigned con_start;	/* Index into log_buf: next char to be sent to consoles */
+
+#ifdef CONFIG_PRINTK_PERSIST
+#define log_end (logbits->_log_end)
+#else
 static unsigned log_end;	/* Index into log_buf: most-recently-written-char + 1 */
+#endif
 
 /*
  * If exclusive_console is non-NULL then only this console is to be printed to.
@@ -143,11 +148,93 @@ static int console_may_schedule;
 
 #ifdef CONFIG_PRINTK
 
+static int saved_console_loglevel = -1;
 static char __log_buf[__LOG_BUF_LEN];
 static char *log_buf = __log_buf;
+
+#ifndef CONFIG_PRINTK_PERSIST
+
 static int log_buf_len = __LOG_BUF_LEN;
 static unsigned logged_chars; /* Number of chars produced since last read+clear operation */
-static int saved_console_loglevel = -1;
+
+#else  /* CONFIG_PRINTK_PERSIST */
+
+struct logbits {
+	int magic; /* needed to verify the memory across reboots */
+	int _log_buf_len; /* leading _ so they aren't replaced by #define */
+	unsigned _logged_chars;
+	unsigned _log_end;
+};
+static struct logbits __logbits = {
+	._log_buf_len = __LOG_BUF_LEN,
+};
+static struct logbits *logbits = &__logbits;
+#define log_buf_len (logbits->_log_buf_len)
+#define logged_chars (logbits->_logged_chars)
+
+#define PERSIST_SEARCH_END 0xfe000000
+#define PERSIST_SEARCH_JUMP (16*1024*1024)
+#define PERSIST_MAGIC 0xbabb1e
+
+#endif /* CONFIG_PRINTK_PERSIST */
+
+/*
+ * size is a power of 2 so that the printk offset mask will work.  We'll add
+ * a bit more space to the end of the buffer for our extra data, but that
+ * won't change the alignment of the buffer itself.
+ */
+static __init char *log_buf_alloc(int early, unsigned long size,
+	unsigned *dest_offset)
+{
+#ifdef CONFIG_PRINTK_PERSIST
+	unsigned long where;
+	char *buf;
+	unsigned long full_size = size + sizeof(struct logbits);
+	struct logbits *new_logbits;
+
+	for (where = PERSIST_SEARCH_END - size;
+			where >= PERSIST_SEARCH_JUMP;
+			where -= PERSIST_SEARCH_JUMP) {
+		where &= ~(roundup_pow_of_two(size) - 1);
+		if (reserve_bootmem(where, full_size, BOOTMEM_EXCLUSIVE))
+			continue;
+
+		printk(KERN_INFO "printk_persist: memory reserved @ 0x%08lx\n",
+			where);
+		buf = phys_to_virt(where);
+		new_logbits = phys_to_virt(where + size);
+		if (new_logbits->magic != PERSIST_MAGIC ||
+				new_logbits->_log_buf_len != size ||
+				new_logbits->_logged_chars > size ||
+				new_logbits->_log_end > size * 2) {
+			printk(KERN_INFO "printk_persist: header invalid, "
+				"cleared.\n");
+			memset(buf, 0, full_size);
+			new_logbits->magic = PERSIST_MAGIC;
+			new_logbits->_log_buf_len = size;
+			new_logbits->_logged_chars = 0;
+			new_logbits->_log_end = 0;
+		} else {
+			printk(KERN_INFO "printk_persist: header valid; "
+				"logged=%d next=%d\n",
+				new_logbits->_logged_chars,
+				new_logbits->_log_end);
+		}
+		*dest_offset = new_logbits->_log_end;
+		new_logbits->_log_end = log_end;
+		new_logbits->_logged_chars += logged_chars;
+		logbits = new_logbits;
+		return buf;
+	}
+	goto error;
+
+error:
+	/* replace the buffer, but don't bother to swap struct logbits */
+	printk(KERN_ERR "printk_persist: failed to reserve bootmem "
+		"area. disabled.\n");
+#endif  /* CONFIG_PRINTK_PERSIST */
+	return alloc_bootmem_nopanic(size);
+}
 
 #ifdef CONFIG_KEXEC
 /*
@@ -187,14 +274,14 @@ early_param("log_buf_len", log_buf_len_setup);
 void __init setup_log_buf(int early)
 {
 	unsigned long flags;
-	unsigned start, dest_idx, offset;
+	unsigned start, dest_idx, dest_offset = 0, offset;
 	char *new_log_buf;
 	int free;
 
 	if (!new_log_buf_len)
 		return;
 
-	new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
+	new_log_buf = log_buf_alloc(early, new_log_buf_len, &dest_offset);
 	if (unlikely(!new_log_buf)) {
 		pr_err("log_buf_len: %ld bytes not available\n",
 			new_log_buf_len);
@@ -204,21 +291,22 @@ void __init setup_log_buf(int early)
 	raw_spin_lock_irqsave(&logbuf_lock, flags);
 	log_buf_len = new_log_buf_len;
 	log_buf = new_log_buf;
-	new_log_buf_len = 0;
 	free = __LOG_BUF_LEN - log_end;
 
 	offset = start = min(con_start, log_start);
-	dest_idx = 0;
+	dest_idx = dest_offset;
 	while (start != log_end) {
 		unsigned log_idx_mask = start & (__LOG_BUF_LEN - 1);
 
-		log_buf[dest_idx] = __log_buf[log_idx_mask];
+		log_buf[dest_idx & (new_log_buf_len - 1)] =
+			__log_buf[log_idx_mask];
 		start++;
 		dest_idx++;
 	}
-	log_start -= offset;
-	con_start -= offset;
-	log_end -= offset;
+	log_start += dest_offset - offset;
+	con_start += dest_offset - offset;
+	log_end += dest_offset - offset;
+	new_log_buf_len = 0;
 	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
 
 	pr_info("log_buf_len: %d\n", log_buf_len);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
