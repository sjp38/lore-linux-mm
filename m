Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD9F6B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:20 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so45314562wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:20 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/18] mm: make vm_brk killable
Date: Mon, 29 Feb 2016 14:26:45 +0100
Message-Id: <1456752417-9626-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Now that all the callers handle vm_brk failure we can change it
wait for mmap_sem killable to help oom_reaper to not get blocked
just because vm_brk gets blocked behind mmap_sem readers.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 2 +-
 mm/mmap.c          | 9 +++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4ee6a3561540..dccaea8682f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2077,7 +2077,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
 
 /* These take the mm semaphore themselves */
-extern unsigned long vm_brk(unsigned long, unsigned long);
+extern unsigned long __must_check vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
 extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
         unsigned long, unsigned long,
diff --git a/mm/mmap.c b/mm/mmap.c
index 5d33c841e3a2..3f264fb14118 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2718,12 +2718,9 @@ unsigned long vm_brk(unsigned long addr, unsigned long len)
 	unsigned long ret;
 	bool populate;
 
-	/*
-	 * XXX not all users are chcecking the return value, convert
-	 * to down_write_killable after they are able to cope with
-	 * error
-	 */
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	ret = do_brk(addr, len);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
 	up_write(&mm->mmap_sem);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
