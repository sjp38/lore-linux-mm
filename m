Message-ID: <48F3ADAF.2080200@inria.fr>
Date: Mon, 13 Oct 2008 22:21:03 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH 1/5] mm: stop returning -ENOENT from sys_move_pages() if nothing
 got migrated
References: <48F3AD47.1050301@inria.fr>
In-Reply-To: <48F3AD47.1050301@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

There is no point in returning -ENOENT from sys_move_pages() if all
pages were already on the right node, while we return 0 if only 1 page
was not. Most application don't know where their pages are allocated,
so it's not an error to try to migrate them anyway.

Just return 0 and let the status array in user-space be checked if the
application needs details.

It will make the upcoming chunked-move_pages() support much easier.

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
---
 mm/migrate.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2a80136..e505b2f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -926,11 +926,10 @@ set_status:
 		pp->status = err;
 	}
 
+	err = 0;
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
-	else
-		err = -ENOENT;
 
 	up_read(&mm->mmap_sem);
 	return err;
-- 
1.5.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
