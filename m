Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id m5BKUkbu031037
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 21:30:46 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by spaceape7.eur.corp.google.com with ESMTP id m5BKUjsU021965
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 21:30:46 +0100
Received: by rv-out-0708.google.com with SMTP id k29so4062806rvb.8
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 13:30:45 -0700 (PDT)
Message-ID: <485035E7.3000103@google.com>
Date: Wed, 11 Jun 2008 13:30:31 -0700
From: Paul Menage <menage@google.com>
MIME-Version: 1.0
Subject: [PATCH] Fix 32-bit truncation of segment sizes in /proc/sysvipc/shm
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Waychison <mikew@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sysvipc_shm_proc_show() picks between format strings (based on the
expected maximum length of a SHM segment) in a way that prevents 
gcc from performing format checks on the seq_printf() parameters. This
hid two format errors - shp->shm_segsz and shp->shm_nattach are both
unsigned long, but were being printed as unsigned int and signed int
respectively. This leads to 32-bit truncation of SHM segment sizes 
reported in /proc/sysvipc/shm. (And for nattach, but that's less of a
problem for most users).

This patch makes the format string directly visible to gcc's format
specifier checker, and fixes the two broken format specifiers.

Signed-off-by: Paul Menage <menage@google.com>

---


 ipc/shm.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: shm-2.6.26-rc5-mm2/ipc/shm.c
===================================================================
--- shm-2.6.26-rc5-mm2.orig/ipc/shm.c
+++ shm-2.6.26-rc5-mm2/ipc/shm.c
@@ -1062,16 +1062,16 @@ asmlinkage long sys_shmdt(char __user *s
 static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 {
 	struct shmid_kernel *shp = it;
-	char *format;
 
-#define SMALL_STRING "%10d %10d  %4o %10u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
-#define BIG_STRING   "%10d %10d  %4o %21u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
+#if BITS_PER_LONG <= 32
+#define SIZE_SPEC "%10lu"
+#else
+#define SIZE_SPEC "%21lu"
+#endif
 
-	if (sizeof(size_t) <= sizeof(int))
-		format = SMALL_STRING;
-	else
-		format = BIG_STRING;
-	return seq_printf(s, format,
+	return seq_printf(s,
+			  "%10d %10d  %4o " SIZE_SPEC " %5u %5u  "
+			  "%5lu %5u %5u %5u %5u %10lu %10lu %10lu\n",
 			  shp->shm_perm.key,
 			  shp->shm_perm.id,
 			  shp->shm_perm.mode,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
