Message-Id: <20061116024438.604985000@sous-sol.org>
References: <20061116024332.124753000@sous-sol.org>
Date: Wed, 15 Nov 2006 18:43:36 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 04/30] Fix sys_move_pages when a NULL node list is passed.
Content-Disposition: inline; filename=fix-sys_move_pages-when-a-null-node-list-is-passed.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org, Christoph Lameter <clameter@sgi.com>
Cc: Justin Forbes <jmforbes@linuxtx.org>, Zwane Mwaikambo <zwane@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Randy Dunlap <rdunlap@xenotime.net>, Dave Jones <davej@redhat.com>, Chuck Wolber <chuckw@quantumlinux.com>, Chris Wedgwood <reviews@ml.cw.f00f.org>, Michael Krufky <mkrufky@linuxtv.org>, torvalds@osdl.org, akpm@osdl.org, alan@lxorguk.ukuu.org.uk, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-stable review patch.  If anyone has any objections, please let us know.
------------------

From: Stephen Rothwell <sfr@canb.auug.org.au>

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
Acked-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 mm/migrate.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.18.2.orig/mm/migrate.c
+++ linux-2.6.18.2/mm/migrate.c
@@ -950,7 +950,8 @@ asmlinkage long sys_move_pages(pid_t pid
 				goto out;
 
 			pm[i].node = node;
-		}
+		} else
+			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
 	}
 	/* End marker */
 	pm[nr_pages].node = MAX_NUMNODES;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
