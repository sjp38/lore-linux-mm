Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id C1DC86B009A
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 08:54:10 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id gd6so20752972lab.1
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 05:54:10 -0800 (PST)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id dd11si13280967lac.130.2015.01.11.05.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 05:54:09 -0800 (PST)
Received: by mail-lb0-f178.google.com with SMTP id u14so14175389lbd.9
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 05:54:09 -0800 (PST)
Subject: [PATCH] mm: fix corner case in anon_vma endless growing prevention
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 11 Jan 2015 16:54:06 +0300
Message-ID: <20150111135406.13266.42007.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, "Elifaz, Dana" <Dana.Elifaz@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>, Michal Hocko <mhocko@suse.cz>

Fix for BUG_ON(anon_vma->degree) splashes in unlink_anon_vmas()
("kernel BUG at mm/rmap.c:399!").

Anon_vma_clone() is usually called for a copy of source vma in destination
argument. If source vma has anon_vma it should be already in dst->anon_vma.
NULL in dst->anon_vma is used as a sign that it's called from anon_vma_fork().
In this case anon_vma_clone() finds anon_vma for reusing.

Vma_adjust() calls it differently and this breaks anon_vma reusing logic:
anon_vma_clone() links vma to old anon_vma and updates degree counters but
vma_adjust() overrides vma->anon_vma right after that. As a result final
unlink_anon_vmas() decrements degree for wrong anon_vma.

This patch assigns ->anon_vma before calling anon_vma_clone().

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
Tested-by: Chris Clayton <chris2553@googlemail.com>
Tested-by: Oded Gabbay <oded.gabbay@amd.com>
Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/mmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7b36aa7..12616c5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -778,10 +778,12 @@ again:			remove_next = 1 + (end > next->vm_end);
 		if (exporter && exporter->anon_vma && !importer->anon_vma) {
 			int error;
 
+			importer->anon_vma = exporter->anon_vma;
 			error = anon_vma_clone(importer, exporter);
-			if (error)
+			if (error) {
+				importer->anon_vma = NULL;
 				return error;
-			importer->anon_vma = exporter->anon_vma;
+			}
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
