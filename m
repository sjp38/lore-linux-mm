Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l34Gan4Z099578
	for <linux-mm@kvack.org>; Wed, 4 Apr 2007 16:36:49 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l34GamHJ2297998
	for <linux-mm@kvack.org>; Wed, 4 Apr 2007 17:36:48 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l34Gamkd022328
	for <linux-mm@kvack.org>; Wed, 4 Apr 2007 17:36:48 +0100
Subject: [S390] page_mkclean data corruption.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
Content-Type: text/plain
Date: Wed, 04 Apr 2007 18:37:04 +0200
Message-Id: <1175704624.31111.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org, gregkh@suse.de
Cc: linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus, Greg,
the attached patch fixes a data corruption problem that has been
introduced with the page_mkclean/clear_page_dirty_for_io change
(the "Yes, Virginia, this is indeed insane." problem :-/)

In essence the fact that clear_page_dirty_for_io is called for
not-uptodate pages causes data corruption for architectures that use
page_test_and_clear_dirty (which is s390 only).

This should go into 2.6.21-rc and 2.6.20-stable.
Please pull message from git390 will follow.

blue skies,
  Martin.

--
Subject: [S390] page_mkclean data corruption.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

The git commit c2fda5fed81eea077363b285b66eafce20dfd45a which
added the page_test_and_clear_dirty call to page_mkclean and the
git commit 7658cc289288b8ae7dd2c2224549a048431222b3 which fixes
the "nasty and subtle race in shared mmap'ed page writeback"
problem in clear_page_dirty_for_io cause data corruption on s390.

The effect of the two changes is that for every call to
clear_page_dirty_for_io a page_test_and_clear_dirty is done. If
the per page dirty bit is set set_page_dirty is called. Strangly
clear_page_dirty_for_io is called for not-uptodate pages, e.g.
over this call-chain:

 [<000000000007c0f2>] clear_page_dirty_for_io+0x12a/0x130
 [<000000000007c494>] generic_writepages+0x258/0x3e0 
 [<000000000007c692>] do_writepages+0x76/0x7c 
 [<00000000000c7a26>] __writeback_single_inode+0xba/0x3e4
 [<00000000000c831a>] sync_sb_inodes+0x23e/0x398 
 [<00000000000c8802>] writeback_inodes+0x12e/0x140 
 [<000000000007b9ee>] wb_kupdate+0xd2/0x178 
 [<000000000007cca2>] pdflush+0x162/0x23c 

The bad news now is that page_test_and_clear_dirty might claim
that a not-uptodate page is dirty since SetPageUptodate which
resets the per page dirty bit has not yet been called. The page
writeback that follows clobbers the data on disk.

The simplest solution to this problem is to move the call to
page_test_and_clear_dirty under the "if (page_mapped(page))".
If a file backed page is mapped it is uptodate.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 mm/rmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-04-04 14:23:22.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-04-04 14:23:35.000000000 +0200
@@ -498,9 +498,9 @@ int page_mkclean(struct page *page)
 		struct address_space *mapping = page_mapping(page);
 		if (mapping)
 			ret = page_mkclean_file(mapping, page);
+		if (page_test_and_clear_dirty(page))
+			ret = 1;
 	}
-	if (page_test_and_clear_dirty(page))
-		ret = 1;
 
 	return ret;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
