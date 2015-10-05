Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A0C036B0338
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 09:28:44 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so176592662pab.3
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 06:28:44 -0700 (PDT)
Received: from m50-134.163.com (m50-134.163.com. [123.125.50.134])
        by mx.google.com with ESMTP id cr7si40327179pad.107.2015.10.05.06.28.41
        for <linux-mm@kvack.org>;
        Mon, 05 Oct 2015 06:28:43 -0700 (PDT)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH v2 3/3] mm/nommu: drop unlikely behind BUG_ON()
Date: Mon,  5 Oct 2015 21:26:06 +0800
Message-Id: <4f765364227f9cdb0e837b165afe24ceb895548f.1444051018.git.geliangtang@163.com>
In-Reply-To: <482d18783d6df356809b67431de95addfa20aa79.1444051018.git.geliangtang@163.com>
References: <482d18783d6df356809b67431de95addfa20aa79.1444051018.git.geliangtang@163.com>
In-Reply-To: <6fa7125979f98bbeac26e268271769b6ca935c8d.1444051018.git.geliangtang@163.com>
References: <482d18783d6df356809b67431de95addfa20aa79.1444051018.git.geliangtang@163.com> <6fa7125979f98bbeac26e268271769b6ca935c8d.1444051018.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Joonsoo Kim <js1304@gmail.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Leon Romanovsky <leon@leon.nu>, Oleg Nesterov <oleg@redhat.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(1) For !CONFIG_BUG cases, the bug call is a no-op, so we couldn't care
less and the change is ok.

(2) ppc and mips, which HAVE_ARCH_BUG_ON, do not rely on branch predictions
as it seems to be pointless[1] and thus callers should not be trying to
push an optimization in the first place.

(3) For CONFIG_BUG and !HAVE_ARCH_BUG_ON cases, BUG_ON() contains an
unlikely compiler flag already.

Hence, we can drop unlikely behind BUG_ON().

[1] http://lkml.iu.edu/hypermail/linux/kernel/1101.3/02289.html

Signed-off-by: Geliang Tang <geliangtang@163.com>
Acked-by: Davidlohr Bueso <dave@stgolabs.net>
---
Changes in v2:
 - Just rewrite the commit log.
---
 mm/nommu.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 1e0f168..92be862 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -578,16 +578,16 @@ static noinline void validate_nommu_regions(void)
 		return;
 
 	last = rb_entry(lastp, struct vm_region, vm_rb);
-	BUG_ON(unlikely(last->vm_end <= last->vm_start));
-	BUG_ON(unlikely(last->vm_top < last->vm_end));
+	BUG_ON(last->vm_end <= last->vm_start);
+	BUG_ON(last->vm_top < last->vm_end);
 
 	while ((p = rb_next(lastp))) {
 		region = rb_entry(p, struct vm_region, vm_rb);
 		last = rb_entry(lastp, struct vm_region, vm_rb);
 
-		BUG_ON(unlikely(region->vm_end <= region->vm_start));
-		BUG_ON(unlikely(region->vm_top < region->vm_end));
-		BUG_ON(unlikely(region->vm_start < last->vm_top));
+		BUG_ON(region->vm_end <= region->vm_start);
+		BUG_ON(region->vm_top < region->vm_end);
+		BUG_ON(region->vm_start < last->vm_top);
 
 		lastp = p;
 	}
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
