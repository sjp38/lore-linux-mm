Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA19028
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 22:37:10 -0700 (PDT)
Message-ID: <3DB63586.A3D4AC22@digeo.com>
Date: Tue, 22 Oct 2002 22:37:10 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: install_page() lockup
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm getting lockups in install_page() with shared pagetables
enabled.  I haven't really delved into it.  It happens under
heavy memory pressure on SMP.

Ingo's new patch is using install_page much more than we
used to (I don't think I've ever run it before), so we're
running fairly untested codepaths here.

I tried this:

 mm/fremap.c |    2 ++
 1 files changed, 2 insertions(+)

--- 25/mm/fremap.c~a	Tue Oct 22 22:08:26 2002
+++ 25-akpm/mm/fremap.c	Tue Oct 22 22:09:02 2002
@@ -72,7 +72,9 @@ int install_page(struct mm_struct *mm, s
 		pte_page_lock(ptepage);
 		if (page_count(ptepage) > 1) {
 			pte = pte_unshare(mm, pmd, addr);
+			pte_page_unlock(ptepage);
 			ptepage = pmd_page(*pmd);
+			pte_page_lock(ptepage);
 		} else
 			pte = pte_offset_map(pmd, addr);
 	} else {

.

Because doing a pte_page_lock(ptepage) and then losing
track of the page we just locked looks fishy.  Didn't
help though.

Dave could you please review the code in there?  It's probably
something simple.

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
