Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B31728E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:09:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h1-v6so5267254pld.21
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:09:09 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0067.outbound.protection.outlook.com. [104.47.40.67])
        by mx.google.com with ESMTPS id a21-v6si9092211pls.372.2018.09.24.06.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 06:09:07 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH] mm: fix COW faults after mlock()
Date: Mon, 24 Sep 2018 16:08:52 +0300
Message-Id: <20180924130852.12996-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dan Williams <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Michel Lespinasse <walken@google.com>, Souptick Joarder <jrdr.linux@gmail.com>, Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Yury Norov <ynorov@caviumnetworks.com>

After mlock() on newly mmap()ed shared memory I observe page faults.

The problem is that populate_vma_page_range() doesn't set FOLL_WRITE
flag for writable shared memory in mlock() path, arguing that like:
/*
 * We want to touch writable mappings with a write fault in order
 * to break COW, except for shared mappings because these don't COW
 * and we would not want to dirty them for nothing.
 */

But they are actually COWed. The most straightforward way to avoid it
is to set FOLL_WRITE flag for shared mappings as well as for private ones.

This is the partial revert of commit 5ecfda041e4b4 ("mlock: avoid
dirtying pages and triggering writeback"). So it re-enables dirtying.

The fix works for me (arm64, kernel v4.19-rc4 and v4.9), but after digging
into the code I still don't understand why we need to do copy-on-write on
shared memory. If comment above was correct when 5ecfda041e4b4 became
upstreamed (2011), shared mappings were not COWed back in 2011, but are
COWed now. If so, this is another issue to be fixed.

Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 mm/gup.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1abc8b4afff6..1899e8bac06b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1202,10 +1202,9 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 		gup_flags &= ~FOLL_POPULATE;
 	/*
 	 * We want to touch writable mappings with a write fault in order
-	 * to break COW, except for shared mappings because these don't COW
-	 * and we would not want to dirty them for nothing.
+	 * to break COW.
 	 */
-	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+	if (vma->vm_flags & VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
 	/*
-- 
2.17.1
