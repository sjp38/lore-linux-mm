From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage after unlocking it
Date: Mon, 28 Jan 2019 17:04:03 +0100
Message-ID: <20190128160403.16657-1-david@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org
List-Id: linux-mm.kvack.org

While debugging some crashes related to virtio-balloon deflation that
happened under the old balloon migration code, I stumbled over a race
that still exists today.

What we experienced:

drivers/virtio/virtio_balloon.c:release_pages_balloon():
- WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
- list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100

Turns out after having added the page to a local list when dequeuing,
the page would suddenly be moved to an LRU list before we would free it
via the local list, corrupting both lists. So a page we own and that is
!LRU was moved to an LRU list.

In __unmap_and_move(), we lock the old and newpage and perform the
migration. In case of vitio-balloon, the new page will become
movable, the old page will no longer be movable.

However, after unlocking newpage, there is nothing stopping the newpage
from getting dequeued and freed by virtio-balloon. This
will result in the newpage
1. No longer having PageMovable()
2. Getting moved to the local list before finally freeing it (using
   page->lru)

Back in the migration thread in __unmap_and_move(), we would after
unlocking the newpage suddenly no longer have PageMovable(newpage) and
will therefore call putback_lru_page(newpage), modifying page->lru
although that list is still in use by virtio-balloon.

To summarize, we have a race between migrating the newpage and checking
for PageMovable(newpage). Instead of checking PageMovable(newpage), we
can simply rely on is_lru of the original page.

Looks like this was introduced by d6d86c0a7f8d ("mm/balloon_compaction:
redesign ballooned pages management"), which was backported up to 3.12.
Old compaction code used PageBalloon() via -_is_movable_balloon_page()
instead of PageMovable(), however with the same semantics.

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
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org # 3.12+
Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
Reported-by: Vratislav Bendel <vbendel@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
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
