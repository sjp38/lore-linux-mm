Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 97C3D6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:42:58 -0500 (EST)
Received: by paceu11 with SMTP id eu11so38337638pac.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 11:42:58 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id zt3si2238989pac.109.2015.02.24.11.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 11:42:57 -0800 (PST)
Message-ID: <1424806966.6539.84.camel@stgolabs.net>
Subject: [PATCH v3 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 24 Feb 2015 11:42:46 -0800
In-Reply-To: <201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
References: <1424324307.18191.5.camel@stgolabs.net>
	 <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
	 <1424370153.18191.12.camel@stgolabs.net>
	 <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	 <1424449696.2317.0.camel@stgolabs.net>
	 <201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org, tomoyo-dev-en@lists.sourceforge.jp

The mm->exe_file is currently serialized with mmap_sem (shared) in order
to both safely (1) read the file and (2) compute the realpath by calling
tomoyo_realpath_from_path, making it an absolute overkill. Good users will,
on the other hand, make use of the more standard get_mm_exe_file(), requiring
only holding the mmap_sem to read the value, and relying on reference

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

Changes from v2: remove cleanups and cp initialization.

 security/tomoyo/util.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
index 2952ba5..29f3b65 100644
--- a/security/tomoyo/util.c
+++ b/security/tomoyo/util.c
@@ -948,16 +948,19 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
  */
 const char *tomoyo_get_exe(void)
 {
-	struct mm_struct *mm = current->mm;
-	const char *cp = NULL;
+       struct file *exe_file;
+       const char *cp;
+       struct mm_struct *mm = current->mm;
 
-	if (!mm)
-		return NULL;
-	down_read(&mm->mmap_sem);
-	if (mm->exe_file)
-		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
-	up_read(&mm->mmap_sem);
-	return cp;
+       if (!mm)
+	       return NULL;
+       exe_file = get_mm_exe_file(mm);
+       if (!exe_file)
+	       return NULL;
+
+       cp = tomoyo_realpath_from_path(&exe_file->f_path);
+       fput(exe_file);
+       return cp;
 }
 
 /**
-- 
2.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
