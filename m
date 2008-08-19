From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:39 -0400
Message-Id: <20080819210539.27199.97194.sendpatchset@lts-notebook>
In-Reply-To: <20080819210509.27199.6626.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [PATCH 5/6] Mlock:  revert mainline handling of mlock error return
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.27-rc3-mmotm-080819-0259

This can apply atop the mmotm series or anywhere after, say,
mlock-count-attempts-to-free-mlocked-page-2.patch.


Revert the change to make_page_present() error return.

This change is intended to make mlock() error returns correct.
make_page_present() is a lower level function used by more than
mlock(), although only mlock() currently examines the return
value.

Subsequent patch[es] will add this error return fixup in an mlock
specific path.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/memory.c |   14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/memory.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/memory.c	2008-08-18 14:50:36.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/memory.c	2008-08-18 14:53:15.000000000 -0400
@@ -2819,19 +2819,9 @@ int make_pages_present(unsigned long add
 	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
 	ret = get_user_pages(current, current->mm, addr,
 			len, write, 0, NULL, NULL);
-	if (ret < 0) {
-		/*
-		   SUS require strange return value to mlock
-		    - invalid addr generate to ENOMEM.
-		    - out of memory should generate EAGAIN.
-		*/
-		if (ret == -EFAULT)
-			ret = -ENOMEM;
-		else if (ret == -ENOMEM)
-			ret = -EAGAIN;
+	if (ret < 0)
 		return ret;
-	}
-	return ret == len ? 0 : -ENOMEM;
+	return ret == len ? 0 : -1;
 }
 
 #if !defined(__HAVE_ARCH_GATE_AREA)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
