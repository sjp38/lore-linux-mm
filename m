Date: Tue, 06 May 2008 16:02:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: make vmstat cpu-unplug safe
Message-Id: <20080506154938.AC6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

btw: I think all_vm_event() author is Cristoph Lameter, right?


--------------------------------------------
When access cpu_online_map, We should prevent that dynamically 
change cpu_online_map by get_online_cpus().

Unfortunately, all_vm_events() doesn't it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Christoph Lameter <clameter@sgi.com>

---
 mm/vmstat.c |    2 ++
 1 file changed, 2 insertions(+)

Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c       2008-05-04 23:00:52.000000000 +0900
+++ b/mm/vmstat.c       2008-05-06 16:13:32.000000000 +0900
@@ -42,7 +42,9 @@ static void sum_vm_events(unsigned long
 */
 void all_vm_events(unsigned long *ret)
 {
+       get_online_cpus();
        sum_vm_events(ret, &cpu_online_map);
+       put_online_cpus();
 }
 EXPORT_SYMBOL_GPL(all_vm_events);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
