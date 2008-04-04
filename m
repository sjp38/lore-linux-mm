From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 08/10] xpmem: Locking rules for taking multiple
	mmap_sem locks.
Date: Fri, 04 Apr 2008 15:30:56 -0700
Message-ID: <20080404223132.971442620@sgi.com>
References: <20080404223048.374852899@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=xpmem_v003_lock-rule
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Dean Nelson <dcn@sgi.com>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: linux-mm.kvack.org

This patch adds a lock ordering rule to avoid a potential deadlock when
multiple mmap_sems need to be locked.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---
 mm/filemap.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-04-01 13:02:41.374608387 -0700
+++ linux-2.6/mm/filemap.c	2008-04-01 13:05:02.777015782 -0700
@@ -80,6 +80,9 @@ generic_file_direct_IO(int rw, struct ki
  *  ->i_mutex			(generic_file_buffered_write)
  *    ->mmap_sem		(fault_in_pages_readable->do_page_fault)
  *
+ *    When taking multiple mmap_sems, one should lock the lowest-addressed
+ *    one first proceeding on up to the highest-addressed one.
+ *
  *  ->i_mutex
  *    ->i_alloc_sem             (various)
  *

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
