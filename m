Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2855D6B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:37:31 -0400 (EDT)
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130522002020.60c3808f.akpm@linux-foundation.org>
References: 
	 <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	 <20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
	 <1369178849.27102.330.camel@schen9-DESK>
	 <20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
	 <1369183390.27102.337.camel@schen9-DESK>
	 <20130522002020.60c3808f.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 22 May 2013 16:37:18 -0700
Message-ID: <1369265838.27102.351.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2013-05-22 at 00:20 -0700, Andrew Morton wrote:

> > +#ifdef CONFIG_SMP
> > +extern int vm_committed_as_batch;
> > +
> > +static inline void mm_compute_batch(void)
> > +{
> > +        int nr = num_present_cpus();
> > +        int batch = max(32, nr*2);
> > +
> > +        /* batch size set to 0.4% of (total memory/#cpus) */
> > +        vm_committed_as_batch = max((int) (totalram_pages/nr) / 256, batch);
> 
> Use max_t() here.
> That expression will overflow when the machine has two exabytes of RAM ;)
> 

I've updated the computation to use max_t and also added a check for
overflow.

> > +}
> > +#else
> > +#define vm_committed_as_batch 0
> > +
> > +static inline void mm_compute_batch(void)
> > +{
> > +}
> > +#endif
> 
> I think it would be better if all the above was not inlined.  There's
> no particular reason to inline it, and putting it here requires that
> mman.h include a bunch more header files (which the patch forgot to
> do).
> 

Now mm_compute_batch has been moved to mm_init.c and not inlined. Also
a memory hot plug notifier is registered to recompute batch size 
when memory size changes.

> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index 298884d..9ad16ba 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -527,11 +527,15 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
> >  /*
> >   * initialise the VMA and region record slabs
> >   */
> > +
> > +int vm_committed_as_batch;
> 
> This definition duplicates the one in mmap.c?

Only one copy defined in mm_init.c now.

Thanks

Tim

Currently the per cpu counter's batch size for memory accounting is
configured as twice the number of cpus in the system.  However,
for system with very large memory, it is more appropriate to make it
proportional to the memory size per cpu in the system.

For example, for a x86_64 system with 64 cpus and 128 GB of memory,
the batch size is only 2*64 pages (0.5 MB).  So any memory accounting
changes of more than 0.5MB will overflow the per cpu counter into
the global counter.  Instead, for the new scheme, the batch size
is configured to be 0.4% of the memory/cpu = 8MB (128 GB/64 /256),
which is more inline with the memory size.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/mman.h |  8 +++++++-
 mm/mm_init.c         | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9aa863d..92dc257 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -11,11 +11,17 @@ extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
 
+#ifdef CONFIG_SMP
+extern s32 vm_committed_as_batch;
+#else
+#define vm_committed_as_batch 0
+#endif
+
 unsigned long vm_memory_committed(void);
 
 static inline void vm_acct_memory(long pages)
 {
-	percpu_counter_add(&vm_committed_as, pages);
+	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
 }
 
 static inline void vm_unacct_memory(long pages)
diff --git a/mm/mm_init.c b/mm/mm_init.c
index c280a02..bfb9034 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -9,6 +9,8 @@
 #include <linux/init.h>
 #include <linux/kobject.h>
 #include <linux/export.h>
+#include <linux/memory.h>
+#include <linux/notifier.h>
 #include "internal.h"
 
 #ifdef CONFIG_DEBUG_MEMORY_INIT
@@ -147,6 +149,51 @@ early_param("mminit_loglevel", set_mminit_loglevel);
 struct kobject *mm_kobj;
 EXPORT_SYMBOL_GPL(mm_kobj);
 
+#ifdef CONFIG_SMP
+s32 vm_committed_as_batch = 32;
+
+static void __meminit mm_compute_batch(void)
+{
+	u64 memsized_batch;
+	s32 nr = num_present_cpus();
+	s32 batch = max_t(s32, nr*2, 32);
+
+	/* batch size set to 0.4% of (total memory/#cpus), or max int32 */
+	memsized_batch = min_t(u64, (totalram_pages/nr)/256, 0x7fffffff);
+
+	vm_committed_as_batch = max_t(s32, memsized_batch, batch);
+}
+
+static int __meminit mm_compute_batch_notifier(struct notifier_block *self,
+					unsigned long action, void *arg)
+{
+	switch (action) {
+	case MEM_ONLINE:
+	case MEM_OFFLINE:
+		mm_compute_batch();
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block compute_batch_nb = {
+	.notifier_call = mm_compute_batch_notifier,
+	.priority = IPC_CALLBACK_PRI, /* use lowest priority */
+};
+
+static int __init mm_compute_batch_init(void)
+{
+	mm_compute_batch();
+	register_hotmemory_notifier(&compute_batch_nb);
+
+	return 0;
+}
+
+__initcall(mm_compute_batch_init);
+
+#endif
+
 static int __init mm_sysfs_init(void)
 {
 	mm_kobj = kobject_create_and_add("mm", kernel_kobj);
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
