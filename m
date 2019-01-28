Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19E128E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:16:25 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k66so18116297qkf.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 04:16:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f64si1446125qva.93.2019.01.28.04.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 04:16:24 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC] mm: migrate: don't rely on PageMovable() of newpage after unlocking it
Date: Mon, 28 Jan 2019 13:16:09 +0100
Message-Id: <20190128121609.9528-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>, Rafael Aquini <aquini@redhat.com>

While debugging some crashes related to virtio-balloon deflation that
happened under the old balloon migration code, I stumbled over a possible
race I think.

What we experienced:

drivers/virtio/virtio_balloon.c:release_pages_balloon():
- WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
- list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100

Turns out after having added the page to a local list when dequeuing,
the page would suddenly be moved to an LRU list before we would free it
via the local list, corrupting both lists. So a page we own and that is
!LRU was moved to an LRU list.

For us, this was triggered by backporting 195a8c43e93d8 ("virtio-balloon:
deflate via a page list") onto old balloon compaction code, but I think
this only made the BUG become visible and the race still exists in
new !LRU migraton code.

My theory:

In __unmap_and_move(), we lock the old and newpage and perform the
migration. In case of vitio-balloon, the new page will become
movable, the old page will no longer be movable.

However, after unlocking newpage, I think there is nothing stopping
the newpage from getting dequeued and freed by virtio-balloon. This
will result in the newpage
1. No longer having PageMovable()
2. Getting moved to the local list before finally freeing it (using
   page->lru)

Back in the migration thread in __unmap_and_move(), we would after
unlocking the newpage suddenly no longer have PageMovable(newpage) and
will therefore call putback_lru_page(newpage), modifying page->lru
although that list is still in use by virtio-balloon.

To summarize, we have a race between migrating the newpage and checking
for PageMovable(newpage). Instead of checking __PageMovable(newpage), we
can simply rely on is_lru. Because if the old page was not an LRU page, the
new page also shouldn't be. If there is a problem with that, we could check
for __PageMovable(newpage) before unlocking the new page.

As I am not yet sure if this race actually exists, especially also
upstream, I am sending this as RFC.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vratislav Bendel <vbendel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>
Reported-by: Vratislav Bendel <vbendel@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/migrate.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4512afab46ac..31e002270b05 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1135,10 +1135,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * If migration is successful, decrease refcount of the newpage
 	 * which will not free the page because new page owner increased
 	 * refcounter. As well, if it is LRU page, add the page to LRU
-	 * list in here.
+	 * list in here. Don't rely on PageMovable(newpage), as that could
+	 * already have changed after unlocking newpage (e.g.
+	 * virtio-balloon deflation).
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__PageMovable(newpage)))
+		if (unlikely(!is_lru))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
-- 
2.17.2
