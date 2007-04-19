Message-ID: <4627DBF0.1080303@redhat.com>
Date: Thu, 19 Apr 2007 17:15:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE 2/2
References: <46247427.6000902@redhat.com>
In-Reply-To: <46247427.6000902@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------080907040107030804000708"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080907040107030804000708
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Restore MADV_DONTNEED to its original Linux behaviour.  This is still
not the same behaviour as POSIX, but applications may be depending on
the Linux behaviour already. Besides, glibc catches POSIX_MADV_DONTNEED
and makes sure nothing is done...

Signed-off-by: Rik van Riel <riel@redhat.com>

---
This is to be applied over of the original MADV_FREE patch.
It turns out that the current glibc patch already falls back
to MADV_DONTNEED if it gets an -EINVAL.

--------------080907040107030804000708
Content-Type: text/x-patch;
 name="linux-2.6-madv-dontneed-restore.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-madv-dontneed-restore.patch"

--- linux-2.6.20.x86_64/mm/madvise.c.madv_free	2007-04-19 16:46:22.000000000 -0400
+++ linux-2.6.20.x86_64/mm/madvise.c	2007-04-19 16:52:19.000000000 -0400
@@ -130,7 +130,8 @@ static long madvise_willneed(struct vm_a
  */
 static long madvise_dontneed(struct vm_area_struct * vma,
 			     struct vm_area_struct ** prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     int behavior)
 {
 	*prev = vma;
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
@@ -142,12 +143,14 @@ static long madvise_dontneed(struct vm_a
 			.last_index = ULONG_MAX,
 		};
 		zap_page_range(vma, start, end - start, &details);
-	} else {
+	} else if (behavior == MADV_FREE) {
 		struct zap_details details = {
 			.madv_free = 1,
 		};
 		zap_page_range(vma, start, end - start, &details);
-	}
+	} else /* behavior == MADV_DONTNEED */
+		zap_page_range(vma, start, end - start, NULL);
+
 	return 0;
 }
 
@@ -219,10 +222,9 @@ madvise_vma(struct vm_area_struct *vma, 
 		error = madvise_willneed(vma, prev, start, end);
 		break;
 
-	/* FIXME: POSIX says that MADV_DONTNEED cannot throw away data. */
 	case MADV_DONTNEED:
 	case MADV_FREE:
-		error = madvise_dontneed(vma, prev, start, end);
+		error = madvise_dontneed(vma, prev, start, end, behavior);
 		break;
 
 	default:

--------------080907040107030804000708--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
