Date: Fri, 3 Nov 2006 14:42:43 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] Fix sys_move_pages when a NULL node list is passed.
Message-Id: <20061103144243.4601ba76.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

sys_move_pages() uses vmalloc() to allocate an array of structures
that is fills with information passed from user mode and then passes to
do_stat_pages() (in the case the node list is NULL).  do_stat_pages()
depends on a marker in the node field of the structure to decide how large
the array is and this marker is correctly inserted into the last element
of the array.  However, vmalloc() doesn't zero the memory it allocates
and if the user passes NULL for the node list, then the node fields are
not filled in (except for the end marker).  If the memory the vmalloc()
returned happend to have a word with the marker value in it in just the
right place, do_pages_stat will fail to fill the status field of part
of the array and we will return (random) kernel data to user mode.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 mm/migrate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

This has been tested in PowerPC (after wiring up sys_move_pages).  This
should go into 2.6.19 as it leaks kernel memory.  It should also be
submitted to the 2.6.18 stable tree (as sys_move_pages was introduced
before 2.6.18-rc2).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/mm/migrate.c b/mm/migrate.c
index ba2453f..b4979d4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -952,7 +952,8 @@ asmlinkage long sys_move_pages(pid_t pid
 				goto out;
 
 			pm[i].node = node;
-		}
+		} else
+			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
 	}
 	/* End marker */
 	pm[nr_pages].node = MAX_NUMNODES;
-- 
1.4.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
