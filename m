From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 04/11] RFP prot support: disallow mprotect() on manyprots
	mappings
Date: Sat, 31 Mar 2007 02:35:31 +0200
Message-ID: <20070331003531.3415.18234.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

For now we (I and Hugh) have found no agreement on which behavior to implement
here. So, at least as a stop-gap, return an error here.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/mprotect.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 07f04fa..f372c20 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -251,6 +251,13 @@ int do_mprotect(unsigned long start, size_t len, unsigned long prot)
 	error = -ENOMEM;
 	if (!vma)
 		goto out;
+
+	/* If a need is felt, an appropriate behaviour may be implemented for
+	 * this case. We haven't agreed yet on which behavior is appropriate. */
+	error = -EACCES;
+	if (vma->vm_flags & VM_MANYPROTS)
+		goto out;
+
 	if (unlikely(grows & PROT_GROWSDOWN)) {
 		if (vma->vm_start >= end)
 			goto out;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
