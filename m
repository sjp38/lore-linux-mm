Date: Fri, 28 Feb 2003 12:48:06 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
In-Reply-To: <20030227160656.40ebeb93.akpm@digeo.com>
Message-ID: <Pine.LNX.4.44.0302281245170.1203-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Con Kolivas <kernel@kolivas.org>, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Feb 2003, Andrew Morton wrote:
> 
> No, it is still wrong.  Mapped cannot exceed MemTotal.

It needs this in addition to Dave's patch from yesterday:

--- 2.5.63-objfix-1/mm/rmap.c	Thu Feb 27 23:37:28 2003
+++ 2.5.63-objfix-2/mm/rmap.c	Fri Feb 28 12:33:58 2003
@@ -349,7 +349,8 @@
 			BUG();
 		if (atomic_read(&page->pte.mapcount) == 0)
 			BUG();
-		atomic_dec(&page->pte.mapcount);
+		if (atomic_dec_and_test(&page->pte.mapcount))
+			dec_page_state(nr_mapped);
 		return;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
