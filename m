From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 6/7] VM statistics: Use CPU ops
Date: Wed, 05 Nov 2008 17:16:40 -0600
Message-ID: <20081105231649.791193871@quilx.com>
References: <20081105231634.133252042@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_ops_vmstat
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-Id: linux-mm.kvack.org

The use of CPU ops here avoids the offset calculations that we used to have
to do with per cpu operations. The result of this patch is that event counters
are coded with a single instruction the following way:

	incq   %gs:offset(%rip)

Without these patches this was:

	mov    %gs:0x8,%rdx
	mov    %eax,0x38(%rsp)
	mov    xxx(%rip),%eax
	mov    %eax,0x48(%rsp)
	mov    varoffset,%rax
	incq   0x110(%rax,%rdx,1)

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/vmstat.h |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: linux-2.6/include/linux/vmstat.h
===================================================================
--- linux-2.6.orig/include/linux/vmstat.h	2008-10-23 15:21:52.000000000 -0500
+++ linux-2.6/include/linux/vmstat.h	2008-10-23 15:34:02.000000000 -0500
@@ -75,24 +75,22 @@
 
 static inline void __count_vm_event(enum vm_event_item item)
 {
-	__get_cpu_var(vm_event_states).event[item]++;
+	__CPU_INC(per_cpu_var(vm_event_states).event[item]);
 }
 
 static inline void count_vm_event(enum vm_event_item item)
 {
-	get_cpu_var(vm_event_states).event[item]++;
-	put_cpu();
+	_CPU_INC(per_cpu_var(vm_event_states).event[item]);
 }
 
 static inline void __count_vm_events(enum vm_event_item item, long delta)
 {
-	__get_cpu_var(vm_event_states).event[item] += delta;
+	__CPU_ADD(per_cpu_var(vm_event_states).event[item], delta);
 }
 
 static inline void count_vm_events(enum vm_event_item item, long delta)
 {
-	get_cpu_var(vm_event_states).event[item] += delta;
-	put_cpu();
+	_CPU_ADD(per_cpu_var(vm_event_states).event[item], delta);
 }
 
 extern void all_vm_events(unsigned long *);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
