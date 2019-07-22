Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83321C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 21:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0526821900
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 21:32:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="E/T6Tquq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0526821900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DEBF6B0003; Mon, 22 Jul 2019 17:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 669086B0005; Mon, 22 Jul 2019 17:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BC5F8E0001; Mon, 22 Jul 2019 17:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 093CB6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:32:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j12so20576771pll.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5EUBKEkEYUrECI+Cyg/rrvCPQbLH7/NVI8PTWn91MEY=;
        b=MEyW7IITi72pO1xOJ/a306st2qkaYQa61BYWhgZTtbFYSR5LHLBV+MoegYVKP/yIhj
         NLrAGkqxOdUJ/7Jf5Fa1G/UYgldjODtn0fPKynBzEjzohK6tlmxY5Gyz07yG7w6Evcp6
         Frl22/WIxG9uMy3rnLRnd8De5kxxuAEOv+0ZT691Bor4yrhBsaBLb6iBCSkdH7rkSU9B
         x5ws3ncQS26NVehZHdLAHYto30cj47WCOjB50pWcQacjR7zMjIY9gs+OeO7gtM9Ploiz
         hTOefvXkAaYEPj52NTylQMyS6/UtDz3xvygFf2LQ/lFLf6uaU4Z0ZSqGQKnz3WDKmBhT
         2ANA==
X-Gm-Message-State: APjAAAVSPku903f2KYnPxMSVtPHuqT1ka0HpeHXbgGL5CucdmtNJzkHh
	oK2jY8Jv+14sasigwocutR6HA+kSlZoaoMDmMrjb+U7OzNYjF3mJMDZoufHXjR2juXWcsRFdhmK
	Kuuhcsv10Q5xnEW3r4hKJp3md8+YPHx1XfSMA0BYo/P6yceg4xS23bPJGAz/O05TS5Q==
X-Received: by 2002:a17:90a:3ae8:: with SMTP id b95mr77109797pjc.68.1563831139587;
        Mon, 22 Jul 2019 14:32:19 -0700 (PDT)
X-Received: by 2002:a17:90a:3ae8:: with SMTP id b95mr77109725pjc.68.1563831138347;
        Mon, 22 Jul 2019 14:32:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563831138; cv=none;
        d=google.com; s=arc-20160816;
        b=VXcjBk3c1yZHd7GyxhDHfAB9XzAdQa0uUDVZhXyLPH44/ePBP16kw/HpCKv4lOWazu
         Ru163GaPKr26Lbde157RxFOB+qouPZ1m87e/q4DeoDq/8tRgx2xe9ix3U0O//xGBnak8
         MbExeXSEzIn5gpTt7u5lnuMZaEWfg8RIEbfM0i/2dNT0wIvHcKDk1ArsIIrzkc6vNCzj
         j7lpjmwcDsxZRo4L2GA7R83yPRt175wAtRt9+EGNenOiPp/AGGqu5hTaNIxNQWkMidoW
         hUC+FXQfIaDKKyIkeutbE6QjsBmZctg/A3PkVrrYkCekvkvdgPEBd2xXQn16AuGXr2me
         WxxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5EUBKEkEYUrECI+Cyg/rrvCPQbLH7/NVI8PTWn91MEY=;
        b=OBa3jXqmLFYMhza7t7PjAOWlcRGgDGloz+tW87gI13i3lRjgMiZWe4v14budQewyeL
         UwY9nq/65Bl+5+W5Cj+VZjU+YGEEXMAg8pGVz83OI84tW6AJPseK9PRQYB4mEuVYJETT
         73oYo3z66DmrXUhgL3y10WfCSizIJ3pQbXVAcIfUyho3/A6EA4ZE9dO3py3sPI2RgB2b
         DWBxTElzbw/RFzWu93iGag7drVD4Fb12CMF7t3DapycK5owDMLkFTGI5AdoREM6D/01x
         IjH34GPtFpJ3qwzlXT75w5JqYlw5yE3XewIMJI7kKg11HC1pvtOm+MHKPUXUA4SrCmUB
         niJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b="E/T6Tquq";
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor22147814pfh.6.2019.07.22.14.32.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 14:32:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b="E/T6Tquq";
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5EUBKEkEYUrECI+Cyg/rrvCPQbLH7/NVI8PTWn91MEY=;
        b=E/T6TquqnjxiArq6x8UhVOJNi11uNjNSnwAngmTiQXN3a2syDSyprsW+rhlZETd8m8
         prqn7Qs6K74dz/WID5slxvukGJWtWVOTqjM8DbEVp+fmQjo7uFJk1wfTqYFreSYaIClE
         uriORiXevVMV+X5ek7HdxCoFmQLhAntn8TYtk=
X-Google-Smtp-Source: APXvYqynAOfnrO/JgAM4UwXrY8K4C2lO2ZC8FkcSA1CoCMUuFmkrkCErApqNS0U/jNT03i6Ak1KChg==
X-Received: by 2002:a62:82c2:: with SMTP id w185mr2351928pfd.202.1563831137758;
        Mon, 22 Jul 2019 14:32:17 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id i14sm65202333pfk.0.2019.07.22.14.32.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 14:32:16 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>,
	kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>,
	dancol@google.com,
	David Howells <dhowells@redhat.com>,
	fmayer@google.com,
	joaodias@google.com,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@google.com,
	minchan@kernel.org,
	namhyung@google.com,
	sspatil@google.com,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	timmurray@google.com,
	tkjos@google.com,
	Vlastimil Babka <vbabka@suse.cz>,
	wvw@google.com
Subject: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle using virtual indexing
Date: Mon, 22 Jul 2019 17:32:04 -0400
Message-Id: <20190722213205.140845-1-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The page_idle tracking feature currently requires looking up the pagemap
for a process followed by interacting with /sys/kernel/mm/page_idle.
This is quite cumbersome and can be error-prone too. If between
accessing the per-PID pagemap and the global page_idle bitmap, if
something changes with the page then the information is not accurate.
More over looking up PFN from pagemap in Android devices is not
supported by unprivileged process and requires SYS_ADMIN and gives 0 for
the PFN.

This patch adds support to directly interact with page_idle tracking at
the PID level by introducing a /proc/<pid>/page_idle file. This
eliminates the need for userspace to calculate the mapping of the page.
It follows the exact same semantics as the global
/sys/kernel/mm/page_idle, however it is easier to use for some usecases
where looking up PFN is not needed and also does not require SYS_ADMIN.
It ended up simplifying userspace code, solving the security issue
mentioned and works quite well. SELinux does not need to be turned off
since no pagemap look up is needed.

In Android, we are using this for the heap profiler (heapprofd) which
profiles and pin points code paths which allocates and leaves memory
idle for long periods of time.

Documentation material:
The idle page tracking API for virtual address indexing using virtual page
frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
except that it uses virtual instead of physical frame numbers.

This idle page tracking API can be simpler to use than physical address
indexing, since the pagemap for a process does not need to be looked up
to mark or read a page's idle bit. It is also more accurate than
physical address indexing since in physical address indexing, address
space changes can occur between reading the pagemap and reading the
bitmap. In virtual address indexing, the process's mmap_sem is held for
the duration of the access.

Cc: vdavydov.dev@gmail.com
Cc: Brendan Gregg <bgregg@netflix.com>
Cc: kernel-team@android.com
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>

---
Internal review -> v1:
Fixes from Suren.
Corrections to change log, docs (Florian, Sandeep)

 fs/proc/base.c            |   3 +
 fs/proc/internal.h        |   1 +
 fs/proc/task_mmu.c        |  57 +++++++
 include/linux/page_idle.h |   4 +
 mm/page_idle.c            | 305 +++++++++++++++++++++++++++++++++-----
 5 files changed, 330 insertions(+), 40 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 77eb628ecc7f..a58dd74606e9 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -3021,6 +3021,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+	REG("page_idle", S_IRUSR|S_IWUSR, proc_page_idle_operations),
+#endif
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",       S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index cd0c8d5ce9a1..bc9371880c63 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -293,6 +293,7 @@ extern const struct file_operations proc_pid_smaps_operations;
 extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_page_idle_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4d2b860dbc3f..11ccc53da38e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1642,6 +1642,63 @@ const struct file_operations proc_pagemap_operations = {
 	.open		= pagemap_open,
 	.release	= pagemap_release,
 };
+
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+static ssize_t proc_page_idle_read(struct file *file, char __user *buf,
+				   size_t count, loff_t *ppos)
+{
+	int ret;
+	struct task_struct *tsk = get_proc_task(file_inode(file));
+
+	if (!tsk)
+		return -EINVAL;
+	ret = page_idle_proc_read(file, buf, count, ppos, tsk);
+	put_task_struct(tsk);
+	return ret;
+}
+
+static ssize_t proc_page_idle_write(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	int ret;
+	struct task_struct *tsk = get_proc_task(file_inode(file));
+
+	if (!tsk)
+		return -EINVAL;
+	ret = page_idle_proc_write(file, (char __user *)buf, count, ppos, tsk);
+	put_task_struct(tsk);
+	return ret;
+}
+
+static int proc_page_idle_open(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm;
+
+	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+	file->private_data = mm;
+	return 0;
+}
+
+static int proc_page_idle_release(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = file->private_data;
+
+	if (mm)
+		mmdrop(mm);
+	return 0;
+}
+
+const struct file_operations proc_page_idle_operations = {
+	.llseek		= mem_lseek, /* borrow this */
+	.read		= proc_page_idle_read,
+	.write		= proc_page_idle_write,
+	.open		= proc_page_idle_open,
+	.release	= proc_page_idle_release,
+};
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA
diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
index 1e894d34bdce..f1bc2640d85e 100644
--- a/include/linux/page_idle.h
+++ b/include/linux/page_idle.h
@@ -106,6 +106,10 @@ static inline void clear_page_idle(struct page *page)
 }
 #endif /* CONFIG_64BIT */
 
+ssize_t page_idle_proc_write(struct file *file,
+	char __user *buf, size_t count, loff_t *ppos, struct task_struct *tsk);
+ssize_t page_idle_proc_read(struct file *file,
+	char __user *buf, size_t count, loff_t *ppos, struct task_struct *tsk);
 #else /* !CONFIG_IDLE_PAGE_TRACKING */
 
 static inline bool page_is_young(struct page *page)
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 295512465065..874a60c41fef 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -11,6 +11,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/page_ext.h>
 #include <linux/page_idle.h>
+#include <linux/sched/mm.h>
 
 #define BITMAP_CHUNK_SIZE	sizeof(u64)
 #define BITMAP_CHUNK_BITS	(BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
@@ -28,15 +29,12 @@
  *
  * This function tries to get a user memory page by pfn as described above.
  */
-static struct page *page_idle_get_page(unsigned long pfn)
+static struct page *page_idle_get_page(struct page *page_in)
 {
 	struct page *page;
 	pg_data_t *pgdat;
 
-	if (!pfn_valid(pfn))
-		return NULL;
-
-	page = pfn_to_page(pfn);
+	page = page_in;
 	if (!page || !PageLRU(page) ||
 	    !get_page_unless_zero(page))
 		return NULL;
@@ -51,6 +49,15 @@ static struct page *page_idle_get_page(unsigned long pfn)
 	return page;
 }
 
+static struct page *page_idle_get_page_pfn(unsigned long pfn)
+{
+
+	if (!pfn_valid(pfn))
+		return NULL;
+
+	return page_idle_get_page(pfn_to_page(pfn));
+}
+
 static bool page_idle_clear_pte_refs_one(struct page *page,
 					struct vm_area_struct *vma,
 					unsigned long addr, void *arg)
@@ -118,6 +125,47 @@ static void page_idle_clear_pte_refs(struct page *page)
 		unlock_page(page);
 }
 
+/* Helper to get the start and end frame given a pos and count */
+static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
+				unsigned long *start, unsigned long *end)
+{
+	unsigned long max_frame;
+
+	/* If an mm is not given, assume we want physical frames */
+	max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
+
+	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	*start = pos * BITS_PER_BYTE;
+	if (*start >= max_frame)
+		return -ENXIO;
+
+	*end = *start + count * BITS_PER_BYTE;
+	if (*end > max_frame)
+		*end = max_frame;
+	return 0;
+}
+
+static bool page_really_idle(struct page *page)
+{
+	if (!page)
+		return false;
+
+	if (page_is_idle(page)) {
+		/*
+		 * The page might have been referenced via a
+		 * pte, in which case it is not idle. Clear
+		 * refs and recheck.
+		 */
+		page_idle_clear_pte_refs(page);
+		if (page_is_idle(page))
+			return true;
+	}
+
+	return false;
+}
+
 static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
 				     struct bin_attribute *attr, char *buf,
 				     loff_t pos, size_t count)
@@ -125,35 +173,21 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
 	u64 *out = (u64 *)buf;
 	struct page *page;
 	unsigned long pfn, end_pfn;
-	int bit;
-
-	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
-		return -EINVAL;
-
-	pfn = pos * BITS_PER_BYTE;
-	if (pfn >= max_pfn)
-		return 0;
+	int bit, ret;
 
-	end_pfn = pfn + count * BITS_PER_BYTE;
-	if (end_pfn > max_pfn)
-		end_pfn = max_pfn;
+	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
+	if (ret == -ENXIO)
+		return 0;  /* Reads beyond max_pfn do nothing */
+	else if (ret)
+		return ret;
 
 	for (; pfn < end_pfn; pfn++) {
 		bit = pfn % BITMAP_CHUNK_BITS;
 		if (!bit)
 			*out = 0ULL;
-		page = page_idle_get_page(pfn);
-		if (page) {
-			if (page_is_idle(page)) {
-				/*
-				 * The page might have been referenced via a
-				 * pte, in which case it is not idle. Clear
-				 * refs and recheck.
-				 */
-				page_idle_clear_pte_refs(page);
-				if (page_is_idle(page))
-					*out |= 1ULL << bit;
-			}
+		page = page_idle_get_page_pfn(pfn);
+		if (page && page_really_idle(page)) {
+			*out |= 1ULL << bit;
 			put_page(page);
 		}
 		if (bit == BITMAP_CHUNK_BITS - 1)
@@ -170,23 +204,16 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
 	const u64 *in = (u64 *)buf;
 	struct page *page;
 	unsigned long pfn, end_pfn;
-	int bit;
+	int bit, ret;
 
-	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
-		return -EINVAL;
-
-	pfn = pos * BITS_PER_BYTE;
-	if (pfn >= max_pfn)
-		return -ENXIO;
-
-	end_pfn = pfn + count * BITS_PER_BYTE;
-	if (end_pfn > max_pfn)
-		end_pfn = max_pfn;
+	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
+	if (ret)
+		return ret;
 
 	for (; pfn < end_pfn; pfn++) {
 		bit = pfn % BITMAP_CHUNK_BITS;
 		if ((*in >> bit) & 1) {
-			page = page_idle_get_page(pfn);
+			page = page_idle_get_page_pfn(pfn);
 			if (page) {
 				page_idle_clear_pte_refs(page);
 				set_page_idle(page);
@@ -224,10 +251,208 @@ struct page_ext_operations page_idle_ops = {
 };
 #endif
 
+/*  page_idle tracking for /proc/<pid>/page_idle */
+
+static DEFINE_SPINLOCK(idle_page_list_lock);
+struct list_head idle_page_list;
+
+struct page_node {
+	struct page *page;
+	unsigned long addr;
+	struct list_head list;
+};
+
+struct page_idle_proc_priv {
+	unsigned long start_addr;
+	char *buffer;
+	int write;
+};
+
+static void add_page_idle_list(struct page *page,
+			       unsigned long addr, struct mm_walk *walk)
+{
+	struct page *page_get;
+	struct page_node *pn;
+	int bit;
+	unsigned long frames;
+	struct page_idle_proc_priv *priv = walk->private;
+	u64 *chunk = (u64 *)priv->buffer;
+
+	if (priv->write) {
+		/* Find whether this page was asked to be marked */
+		frames = (addr - priv->start_addr) >> PAGE_SHIFT;
+		bit = frames % BITMAP_CHUNK_BITS;
+		chunk = &chunk[frames / BITMAP_CHUNK_BITS];
+		if (((*chunk >> bit) & 1) == 0)
+			return;
+	}
+
+	page_get = page_idle_get_page(page);
+	if (!page_get)
+		return;
+
+	pn = kmalloc(sizeof(*pn), GFP_ATOMIC);
+	if (!pn)
+		return;
+
+	pn->page = page_get;
+	pn->addr = addr;
+	list_add(&pn->list, &idle_page_list);
+}
+
+static int pte_page_idle_proc_range(pmd_t *pmd, unsigned long addr,
+				    unsigned long end,
+				    struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
+	pte_t *pte;
+	spinlock_t *ptl;
+	struct page *page;
+
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
+		if (pmd_present(*pmd)) {
+			page = follow_trans_huge_pmd(vma, addr, pmd,
+						     FOLL_DUMP|FOLL_WRITE);
+			if (!IS_ERR_OR_NULL(page))
+				add_page_idle_list(page, addr, walk);
+		}
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		if (!pte_present(*pte))
+			continue;
+
+		page = vm_normal_page(vma, addr, *pte);
+		if (page)
+			add_page_idle_list(page, addr, walk);
+	}
+
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
+			       size_t count, loff_t *pos,
+			       struct task_struct *tsk, int write)
+{
+	int ret;
+	char *buffer;
+	u64 *out;
+	unsigned long start_addr, end_addr, start_frame, end_frame;
+	struct mm_struct *mm = file->private_data;
+	struct mm_walk walk = { .pmd_entry = pte_page_idle_proc_range, };
+	struct page_node *cur, *next;
+	struct page_idle_proc_priv priv;
+	bool walk_error = false;
+
+	if (!mm || !mmget_not_zero(mm))
+		return -EINVAL;
+
+	if (count > PAGE_SIZE)
+		count = PAGE_SIZE;
+
+	buffer = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buffer) {
+		ret = -ENOMEM;
+		goto out_mmput;
+	}
+	out = (u64 *)buffer;
+
+	if (write && copy_from_user(buffer, ubuff, count)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = page_idle_get_frames(*pos, count, mm, &start_frame, &end_frame);
+	if (ret)
+		goto out;
+
+	start_addr = (start_frame << PAGE_SHIFT);
+	end_addr = (end_frame << PAGE_SHIFT);
+	priv.buffer = buffer;
+	priv.start_addr = start_addr;
+	priv.write = write;
+	walk.private = &priv;
+	walk.mm = mm;
+
+	down_read(&mm->mmap_sem);
+
+	/*
+	 * Protects the idle_page_list which is needed because
+	 * walk_page_vma() holds ptlock which deadlocks with
+	 * page_idle_clear_pte_refs(). So we have to collect all
+	 * pages first, and then call page_idle_clear_pte_refs().
+	 */
+	spin_lock(&idle_page_list_lock);
+	ret = walk_page_range(start_addr, end_addr, &walk);
+	if (ret)
+		walk_error = true;
+
+	list_for_each_entry_safe(cur, next, &idle_page_list, list) {
+		int bit, index;
+		unsigned long off;
+		struct page *page = cur->page;
+
+		if (unlikely(walk_error))
+			goto remove_page;
+
+		if (write) {
+			page_idle_clear_pte_refs(page);
+			set_page_idle(page);
+		} else {
+			if (page_really_idle(page)) {
+				off = ((cur->addr) >> PAGE_SHIFT) - start_frame;
+				bit = off % BITMAP_CHUNK_BITS;
+				index = off / BITMAP_CHUNK_BITS;
+				out[index] |= 1ULL << bit;
+			}
+		}
+remove_page:
+		put_page(page);
+		list_del(&cur->list);
+		kfree(cur);
+	}
+	spin_unlock(&idle_page_list_lock);
+
+	if (!write && !walk_error)
+		ret = copy_to_user(ubuff, buffer, count);
+
+	up_read(&mm->mmap_sem);
+out:
+	kfree(buffer);
+out_mmput:
+	mmput(mm);
+	if (!ret)
+		ret = count;
+	return ret;
+
+}
+
+ssize_t page_idle_proc_read(struct file *file, char __user *ubuff,
+			    size_t count, loff_t *pos, struct task_struct *tsk)
+{
+	return page_idle_proc_generic(file, ubuff, count, pos, tsk, 0);
+}
+
+ssize_t page_idle_proc_write(struct file *file, char __user *ubuff,
+			     size_t count, loff_t *pos, struct task_struct *tsk)
+{
+	return page_idle_proc_generic(file, ubuff, count, pos, tsk, 1);
+}
+
 static int __init page_idle_init(void)
 {
 	int err;
 
+	INIT_LIST_HEAD(&idle_page_list);
+
 	err = sysfs_create_group(mm_kobj, &page_idle_attr_group);
 	if (err) {
 		pr_err("page_idle: register sysfs failed\n");
-- 
2.22.0.657.g960e92d24f-goog

