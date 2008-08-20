Date: Wed, 20 Aug 2008 20:07:06 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 1/2] Show quicklist at meminfo
In-Reply-To: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080820200607.12ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, Quicklist can spent several GB memory.
So, if end user can't hou much spent memory, he misunderstand to memory leak happend.


after this patch applied, /proc/meminfo output following.

% cat /proc/meminfo

MemTotal:        7701504 kB
MemFree:         5159040 kB
Buffers:          112960 kB
Cached:           337536 kB
SwapCached:            0 kB
Active:           218944 kB
Inactive:         350848 kB
Active(anon):     120832 kB
Inactive(anon):        0 kB
Active(file):      98112 kB
Inactive(file):   350848 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       2031488 kB
SwapFree:        2031488 kB
Dirty:               320 kB
Writeback:             0 kB
AnonPages:        119488 kB
Mapped:            38528 kB
Slab:            1595712 kB
SReclaimable:      23744 kB
SUnreclaim:      1571968 kB
PageTables:        14336 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5882240 kB
Committed_AS:     356672 kB
VmallocTotal:   17592177655808 kB
VmallocUsed:       29056 kB
VmallocChunk:   17592177626304 kB
Quicklists:       283776 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:    262144 kB


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 fs/proc/proc_misc.c       |    6 ++++--
 include/linux/quicklist.h |    7 +++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

Index: b/fs/proc/proc_misc.c
===================================================================
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -202,7 +202,8 @@ static int meminfo_read_proc(char *page,
 		"Committed_AS:   %8lu kB\n"
 		"VmallocTotal:   %8lu kB\n"
 		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n",
+		"VmallocChunk:   %8lu kB\n"
+		"Quicklists:     %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
@@ -242,7 +243,8 @@ static int meminfo_read_proc(char *page,
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
