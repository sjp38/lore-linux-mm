Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 295F66B0087
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:44:55 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Fri, 04 Sep 2009 17:44:59 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH v3 2/5] kmemleak: add clear command support
Date: Fri, 4 Sep 2009 17:44:51 -0700
Message-ID: <1252111494-7593-3-git-send-email-lrodriguez@atheros.com>
In-Reply-To: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com, "Luis R. Rodriguez" <lrodriguez@atheros.com>
List-ID: <linux-mm.kvack.org>

In an ideal world your kmemleak output will be small, when its
not (usually during initial bootup) you can use the clear command
to ingore previously reported and unreferenced kmemleak objects. We
do this by painting all currently reported unreferenced objects grey.
We paint them grey instead of black to allow future scans on the same
objects as such objects could still potentially reference newly
allocated objects in the future.

To test a critical section on demand with a clean
/sys/kernel/debug/kmemleak you can do:

echo clear > /sys/kernel/debug/kmemleak
        test your kernel or modules
echo scan > /sys/kernel/debug/kmemleak

Then as usual to get your report with:

cat /sys/kernel/debug/kmemleak

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 Documentation/kmemleak.txt |   30 ++++++++++++++++++++++++++++++
 mm/kmemleak.c              |   31 +++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index fa93249..3a66dcf 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -27,6 +27,13 @@ To trigger an intermediate memory scan:
 
   # echo scan > /sys/kernel/debug/kmemleak
 
+To clear the list of all current possible memory leaks:
+
+  # echo clear > /sys/kernel/debug/kmemleak
+
+New leaks will then come up upon reading /sys/kernel/debug/kmemleak
+again.
+
 Note that the orphan objects are listed in the order they were allocated
 and one object at the beginning of the list may cause other subsequent
 objects to be reported as orphan.
@@ -35,6 +42,8 @@ Memory scanning parameters can be modified at run-time by writing to the
 /sys/kernel/debug/kmemleak file. The following parameters are supported:
 
   off		- disable kmemleak (irreversible)
+  clear		- clear list of current memory leak suspects, done by
+		  marking all current reported unreferenced objects grey.
   scan=on	- start the automatic memory scanning thread (default)
   scan=off	- stop the automatic memory scanning thread
   scan=<secs>	- set the automatic memory scanning period in seconds
@@ -85,6 +94,27 @@ avoid this, kmemleak can also store the number of values pointing to an
 address inside the block address range that need to be found so that the
 block is not considered a leak. One example is __vmalloc().
 
+Testing specific sections with kmemleak
+---------------------------------------
+
+Upon initial bootup your /sys/kernel/debug/kmemleak output page may be
+quite extensive. This can also be the case if you have very buggy code
+when doing development. To work around these situations you can use the
+'clear' command to clear all reported unreferenced objects from the
+/sys/kernel/debug/kmemleak output. By issuing a 'scan' after a 'clear'
+you can find new unreferenced objects; this should help with testing
+speficic sections of code.
+
+To test a critical section on demand with a clean kmemleak do:
+
+echo clear > /sys/kernel/debug/kmemleak
+        test your kernel or modules
+echo scan > /sys/kernel/debug/kmemleak
+
+Then as usual to get your report with
+
+cat /sys/kernel/debug/kmemleak
+
 Kmemleak API
 ------------
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index cde69f5..76dd7af 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1404,9 +1404,38 @@ static int dump_str_object_info(const char *str)
 }
 
 /*
+ * We use grey instead of black to ensure we can do future
+ * scans on the same objects. If we did not do future scans
+ * these black objects could potentially contain references to
+ * newly allocated objects in the future and we'd end up with
+ * false positives.
+ */
+static void kmemleak_clear(void)
+{
+	struct kmemleak_object *object;
+	unsigned long flags;
+
+	stop_scan_thread();
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(object, &object_list, object_list) {
+		spin_lock_irqsave(&object->lock, flags);
+		if ((object->flags & OBJECT_REPORTED) &&
+		    unreferenced_object(object))
+			object->min_count = -1;
+		spin_unlock_irqrestore(&object->lock, flags);
+	}
+	rcu_read_unlock();
+
+	start_scan_thread();
+}
+
+/*
  * File write operation to configure kmemleak at run-time. The following
  * commands can be written to the /sys/kernel/debug/kmemleak file:
  *   off	- disable kmemleak (irreversible)
+ *   clear	- mark all current reported unreferenced kmemleak objects as
+ *		  grey to ingore printing them
  *   scan=on	- start the automatic memory scanning thread
  *   scan=off	- stop the automatic memory scanning thread
  *   scan=...	- set the automatic memory scanning period in seconds (0 to
@@ -1432,6 +1461,8 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 
 	if (strncmp(buf, "off", 3) == 0)
 		kmemleak_disable();
+	else if (strncmp(buf, "clear", 5) == 0)
+		kmemleak_clear();
 	else if (strncmp(buf, "scan=on", 7) == 0)
 		start_scan_thread();
 	else if (strncmp(buf, "scan=off", 8) == 0)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
