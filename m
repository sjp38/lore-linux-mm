Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A3FBA8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:03:52 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p1113mLe013725
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:03:49 -0800
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by kpbe11.cbf.corp.google.com with ESMTP id p1113FDb012666
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:03:46 -0800
Received: by gxk25 with SMTP id 25so2681666gxk.37
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:03:46 -0800 (PST)
Date: Mon, 31 Jan 2011 17:03:41 -0800
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] mlock: operate on any regions with protection != PROT_NONE
Message-ID: <20110201010341.GA21676@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

As Tao Ma noticed, change 5ecfda0 breaks blktrace. This is because
blktrace mmaps a file with PROT_WRITE permissions but without PROT_READ,
so my attempt to not unnecessarity break COW during mlock ended up
causing mlock to fail with a permission problem.

I am proposing to let mlock ignore vma protection in all cases except
PROT_NONE. In particular, mlock should not fail for PROT_WRITE regions
(as in the blktrace case, which broke at 5ecfda0) or for PROT_EXEC
regions (which seem to me like they were always broken).

Please review. I am proposing this as a candidate for 2.6.38 inclusion,
because of the behavior change with blktrace.

diff --git a/mm/mlock.c b/mm/mlock.c
index 13e81ee..c3924c7f 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -178,6 +178,13 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
+	/*
+	 * We want mlock to succeed for regions that have any permissions
+	 * other than PROT_NONE.
+	 */
+	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
+		gup_flags |= FOLL_FORCE;
+
 	if (vma->vm_flags & VM_LOCKED)
 		gup_flags |= FOLL_MLOCK;
 

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
