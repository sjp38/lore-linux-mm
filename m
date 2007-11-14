Received: by wr-out-0506.google.com with SMTP id c57so325109wra
        for <linux-mm@kvack.org>; Wed, 14 Nov 2007 10:31:15 -0800 (PST)
Message-ID: <e04d66f60711141031waeb9f1bu34a8fa4cadd5d6c3@mail.gmail.com>
Date: Wed, 14 Nov 2007 18:31:15 +0000
From: "Robert Bragg" <robert@sixbynine.org>
Subject: [PATCH] mm: Don't allow ioremapping of ranges larger than vmalloc space
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When running with a 16M IOREMAP_MAX_ORDER (on armv7) we found that the vmlist
search routine in __get_vm_area_node can mistakenly allow a driver to ioremap
a range larger than vmalloc space.

If at the time of the ioremap all existing vmlist areas sit below the determined
alignment then the search routine continues past all entries and exits the for
loop - straight into the found: label - without ever testing for integer
wrapping or that the requested size fits.

We were seeing a driver successfully ioremap 128M of flash even though there was
only 120M of vmalloc space. From that point the system was left with
the remainder
of the first 16M of space to vmalloc/ioremap within.

Signed-off-by: Robert Bragg <robert@sixbynine.org>

---

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index af77e17..06a7f3a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -216,6 +216,10 @@ static struct vm_struct *__get_vm_area_node
 		if (addr > end - size)
 			goto out;
 	}
+	if ((size + addr) < addr)
+		goto out;
+	if (addr > end - size)
+		goto out;

 found:
 	area->next = *p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
