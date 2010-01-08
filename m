Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D64B6B0047
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 17:05:33 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/6] NOMMU: Remove a superfluous check of vm_region::vm_usage
Date: Fri, 08 Jan 2010 22:05:28 +0000
Message-ID: <20100108220527.23489.91998.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In split_vma(), there's no need to check if the VMA being split has a region
that's in use by more than one VMA because:

 (1) The preceding test prohibits splitting of non-anonymous VMAs and regions
     (eg: file or chardev backed VMAs).

 (2) Anonymous regions can't be mapped multiple times because there's no handle
     by which to refer to the already existing region.

 (3) If a VMA has previously been split, then the region backing it has also
     been split into two regions, each of usage 1.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 mm/nommu.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)


diff --git a/mm/nommu.c b/mm/nommu.c
index 5e39294..d6dd656 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1441,10 +1441,9 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	kenter("");
 
-	/* we're only permitted to split anonymous regions that have a single
-	 * owner */
-	if (vma->vm_file ||
-	    vma->vm_region->vm_usage != 1)
+	/* we're only permitted to split anonymous regions (these should have
+	 * only a single usage on the region) */
+	if (vma->vm_file)
 		return -ENOMEM;
 
 	if (mm->map_count >= sysctl_max_map_count)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
