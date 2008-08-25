Date: Mon, 25 Aug 2008 20:40:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] Show quicklist at meminfo
Message-Id: <20080825203357.254D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Today, I rebase quicklist fix to current mainline and tested it.
Could you please pick it up.


Patch against: 2.6.27-rc4

----------------
Now, Quicklist can spent several GB memory.
So, if end user can't know how much spent memory, he misunderstand to memory leak happend.

after this patch applied, /proc/meminfo output following.

% cat /proc/meminfo

MemTotal:      7715392 kB
MemFree:       5401600 kB
Buffers:         80384 kB
Cached:         300800 kB
SwapCached:          0 kB
Active:         235584 kB
Inactive:       262656 kB
SwapTotal:     2031488 kB
SwapFree:      2031488 kB
Dirty:            3520 kB
Writeback:           0 kB
AnonPages:      117696 kB
Mapped:          38528 kB
Slab:          1589952 kB
SReclaimable:    23104 kB
SUnreclaim:    1566848 kB
PageTables:      14656 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
WritebackTmp:        0 kB
CommitLimit:   5889152 kB
Committed_AS:   393152 kB
VmallocTotal: 17592177655808 kB
VmallocUsed:     29056 kB
VmallocChunk: 17592177626432 kB
Quicklists:     130944 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:    262144 kB

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>

---
 fs/proc/proc_misc.c       |    7 +++++--
 include/linux/quicklist.h |    7 +++++++
 2 files changed, 12 insertions(+), 2 deletions(-)

Index: b/fs/proc/proc_misc.c
===================================================================
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -24,6 +24,7 @@
 #include <linux/tty.h>
 #include <linux/string.h>
 #include <linux/mman.h>
+#include <linux/quicklist.h>
 #include <linux/proc_fs.h>
 #include <linux/ioport.h>
 #include <linux/mm.h>
@@ -189,7 +190,8 @@ static int meminfo_read_proc(char *page,
 		"Committed_AS: %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
 		"VmallocUsed:  %8lu kB\n"
-		"VmallocChunk: %8lu kB\n",
+		"VmallocChunk: %8lu kB\n"
+		"Quicklists:   %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
@@ -221,7 +223,8 @@ static int meminfo_read_proc(char *page,
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
-		vmi.largest_chunk >> 10
+		vmi.largest_chunk >> 10,
+		K(quicklist_total_size())
 		);
 
 		len += hugetlb_report_meminfo(page + len);
Index: b/include/linux/quicklist.h
===================================================================
--- a/include/linux/quicklist.h
+++ b/include/linux/quicklist.h
@@ -80,6 +80,13 @@ void quicklist_trim(int nr, void (*dtor)
 
 unsigned long quicklist_total_size(void);
 
+#else
+
+static inline unsigned long quicklist_total_size(void)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* LINUX_QUICKLIST_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
