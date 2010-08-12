Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 852EF6B02A5
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 21:22:58 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1545892Ab0HLBWY (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 12 Aug 2010 03:22:24 +0200
Date: Thu, 12 Aug 2010 03:22:24 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - third fully working version
Message-ID: <20100812012224.GA16479@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: jeremy@goop.org, konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

Hi,

Here is the third version of memory hotplug support
for Xen guests patch. This one cleanly applies to
git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git
repository, xen/memory-hotplug head.

On Fri, Aug 06, 2010 at 04:03:18PM +0400, Vasiliy G Tolstov wrote:
[...]
> Testing on sles 11 sp1 and opensuse 11.3. On results - send e-mail..

Thx.

On Fri, Aug 06, 2010 at 12:34:08PM -0400, Konrad Rzeszutek Wilk wrote:
[...]
> > +static int allocate_additional_memory(unsigned long nr_pages)
> > +{
> > +	long rc;
> > +	resource_size_t r_min, r_size;
> > +	struct resource *r;
> > +	struct xen_memory_reservation reservation = {
> > +		.address_bits = 0,
> > +		.extent_order = 0,
> > +		.domid        = DOMID_SELF
> > +	};
> > +	unsigned long flags, i, pfn;
> > +
> > +	if (nr_pages > ARRAY_SIZE(frame_list))
> > +		nr_pages = ARRAY_SIZE(frame_list);
> > +
> > +	spin_lock_irqsave(&balloon_lock, flags);
> > +
> > +	if (!is_memory_resource_reserved()) {
> > +
> > +		/*
> > +		 * Look for first unused memory region starting at page
> > +		 * boundary. Skip last memory section created at boot time
> > +		 * becuase it may contains unused memory pages with PG_reserved
> > +		 * bit not set (online_pages require PG_reserved bit set).
> > +		 */
> > +
> > +		r = kzalloc(sizeof(struct resource), GFP_KERNEL);
>
> You are holding a spinlock here. Kzalloc can sleep

Thx. Fixed.

On Fri, Aug 06, 2010 at 10:42:48AM -0700, Jeremy Fitzhardinge wrote:
> >   - PV on HVM mode is supported now; it was tested on
> >     git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git
> >     repository, 2.6.34-pvhvm head,
>
> Good.  I noticed you have some specific tests for "xen_pv_domain()" -
> are there many differences between pv and hvm?

No. Only those changes are needed where
xen_domain()/xen_pv_domain() is used.

> >>>+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> >>>+static inline unsigned long current_target(void)
> >>>+{
> >>>+	return balloon_stats.target_pages;
> >>Why does this need its own version?
> >Because original version return values not bigger
> >then initial memory allocation which does not allow
> >memory hotplug to function.
>
> But surely they can be combined?  A system without
> XEN_BALLOON_MEMORY_HOTPLUG is identical to a system with
> XEN_BALLOON_MEMORY_HOTPLUG which hasn't yet added any memory.  Some
> variables may become constants (because memory can never be hot-added),
> but the logic of the code should be the same.

Done.

> Overall, this looks much better.  The next step is to split this into at
> least two patches: one for the core code, and one for the Xen bits.
> Each patch should do just one logical operation, so if you have several
> distinct changes to the core code, put them in separate patches.

I will do that if this patch will be accepted.

> >diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> >index 38434da..beb1aa7 100644
> >--- a/arch/x86/Kconfig
> >+++ b/arch/x86/Kconfig
> >@@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
> >  	depends on ARCH_SPARSEMEM_ENABLE
> >
> >  config ARCH_MEMORY_PROBE
> >-	def_bool y
> >+	def_bool X86_64&&  !XEN
> >  	depends on MEMORY_HOTPLUG
>
> The trouble with making anything statically depend on Xen at config time
> is that you lose it even if you're not running under Xen.  A pvops
> kernel can run on bare hardware as well, and we don't want to lose
> functionality (assume that CONFIG_XEN is always set, since distros do
> always set it).
>
> Can you find a clean way to prevent/disable ARCH_MEMORY_PROBE at runtime
> when in a Xen context?

There is no simple way to do that. It requiers to do some
changes in drivers/base/memory.c code. I think it should
be done as kernel boot option (on by default to not break
things using this interface now). If it be useful for maintainers
of mm/memory_hotplug.c and drivers/base/memory.c code then
I could do that. Currently original arch/x86/Kconfig version
is restored.

> >+/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
> >*/
> >+static int __ref xen_add_memory(int nid, u64 start, u64 size)
>
> Could this be __meminit too then?

Good question. I looked throught the code and could
not find any simple explanation why mm/memory_hotplug.c
authors used __ref instead __meminit. Could you (mm/memory_hotplug.c
authors/maintainers) tell us why ???

> >+{
> >+	pg_data_t *pgdat = NULL;
> >+	int new_pgdat = 0, ret;
> >+
> >+	lock_system_sleep();
>
> What's this for?  I see all its other users are in the memory hotplug
> code, but presumably they're concerned about a real S3 suspend.  Do we
> care about that here?

Yes, because as I know S3 state is supported by Xen guests.

> Actually, this is nearly identical to mm/memory_hotplug.c:add_memory().
> It looks to me like you should:
>
>    * pull the common core out into mm/memory_hotplug.c:__add_memory()
>      (or a better name)
>    * make add_memory() do its
>      register_memory_resource()/firmware_map_add_hotplug() around that
>      (assuming they're definitely unwanted in the Xen case)
>    * make xen_add_memory() just call __add_memory() along with whatever
>      else it needs (which is nothing?)
>
> That way you can export a high-level __add_memory function from
> memory_hotplug.c rather than the two internal detail functions.

Done.

> >+		r->name = "System RAM";
>
> How about making it clear its Xen hotplug RAM?  Or do things care about
> the "System RAM" name?

As I know no however as I saw anybody do not differentiate between
normal and hotplugged memory. I thought about that ealier however
stated that this soultion does not give us any real gain. That is why
I decided to use standard name for hotplugged memory.

If you have a questions please drop me a line.

Daniel

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/Kconfig               |    2 +-
 drivers/xen/balloon.c          |   95 ++++++++-------------------------------
 include/linux/memory_hotplug.h |    3 +-
 mm/memory_hotplug.c            |   55 ++++++++++++++++-------
 4 files changed, 61 insertions(+), 94 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index beb1aa7..9458685 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	depends on ARCH_SPARSEMEM_ENABLE
 
 config ARCH_MEMORY_PROBE
-	def_bool X86_64 && !XEN
+	def_bool X86_64
 	depends on MEMORY_HOTPLUG
 
 config ILLEGAL_POINTER_VALUE
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 31edc26..5120075 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -193,63 +193,11 @@ static void balloon_alarm(unsigned long unused)
 }
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-static inline unsigned long current_target(void)
-{
-	return balloon_stats.target_pages;
-}
-
 static inline u64 is_memory_resource_reserved(void)
 {
 	return balloon_stats.hotplug_start_paddr;
 }
 
-/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-static int __ref xen_add_memory(int nid, u64 start, u64 size)
-{
-	pg_data_t *pgdat = NULL;
-	int new_pgdat = 0, ret;
-
-	lock_system_sleep();
-
-	if (!node_online(nid)) {
-		pgdat = hotadd_new_pgdat(nid, start);
-		ret = -ENOMEM;
-		if (!pgdat)
-			goto out;
-		new_pgdat = 1;
-	}
-
-	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size);
-
-	if (ret < 0)
-		goto error;
-
-	/* we online node here. we can't roll back from here. */
-	node_set_online(nid);
-
-	if (new_pgdat) {
-		ret = register_one_node(nid);
-		/*
-		 * If sysfs file of new node can't create, cpu on the node
-		 * can't be hot-added. There is no rollback way now.
-		 * So, check by BUG_ON() to catch it reluctantly..
-		 */
-		BUG_ON(ret);
-	}
-
-	goto out;
-
-error:
-	/* rollback pgdat allocation */
-	if (new_pgdat)
-		rollback_node_hotadd(nid, pgdat);
-
-out:
-	unlock_system_sleep();
-	return ret;
-}
-
 static int allocate_additional_memory(unsigned long nr_pages)
 {
 	long rc;
@@ -265,8 +213,6 @@ static int allocate_additional_memory(unsigned long nr_pages)
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
-	spin_lock_irqsave(&balloon_lock, flags);
-
 	if (!is_memory_resource_reserved()) {
 
 		/*
@@ -280,7 +226,7 @@ static int allocate_additional_memory(unsigned long nr_pages)
 
 		if (!r) {
 			rc = -ENOMEM;
-			goto out;
+			goto out_0;
 		}
 
 		r->name = "System RAM";
@@ -293,12 +239,14 @@ static int allocate_additional_memory(unsigned long nr_pages)
 
 		if (rc < 0) {
 			kfree(r);
-			goto out;
+			goto out_0;
 		}
 
 		balloon_stats.hotplug_start_paddr = r->start;
 	}
 
+	spin_lock_irqsave(&balloon_lock, flags);
+
 	pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr + balloon_stats.hotplug_size);
 
 	for (i = 0; i < nr_pages; ++i, ++pfn)
@@ -310,7 +258,7 @@ static int allocate_additional_memory(unsigned long nr_pages)
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
 
 	if (rc < 0)
-		goto out;
+		goto out_1;
 
 	pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr + balloon_stats.hotplug_size);
 
@@ -323,9 +271,10 @@ static int allocate_additional_memory(unsigned long nr_pages)
 	balloon_stats.hotplug_size += rc << PAGE_SHIFT;
 	balloon_stats.current_pages += rc;
 
-out:
+out_1:
 	spin_unlock_irqrestore(&balloon_lock, flags);
 
+out_0:
 	return rc < 0 ? rc : rc != nr_pages;
 }
 
@@ -337,11 +286,11 @@ static void hotplug_allocated_memory(void)
 
 	nid = memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
 
-	ret = xen_add_memory(nid, balloon_stats.hotplug_start_paddr,
+	ret = add_registered_memory(nid, balloon_stats.hotplug_start_paddr,
 						balloon_stats.hotplug_size);
 
 	if (ret) {
-		pr_err("%s: xen_add_memory: Memory hotplug failed: %i\n",
+		pr_err("%s: add_registered_memory: Memory hotplug failed: %i\n",
 			__func__, ret);
 		goto error;
 	}
@@ -388,18 +337,6 @@ out:
 	balloon_stats.hotplug_size = 0;
 }
 #else
-static unsigned long current_target(void)
-{
-	unsigned long target = balloon_stats.target_pages;
-
-	target = min(target,
-		     balloon_stats.current_pages +
-		     balloon_stats.balloon_low +
-		     balloon_stats.balloon_high);
-
-	return target;
-}
-
 static inline u64 is_memory_resource_reserved(void)
 {
 	return 0;
@@ -407,13 +344,21 @@ static inline u64 is_memory_resource_reserved(void)
 
 static inline int allocate_additional_memory(unsigned long nr_pages)
 {
+	/*
+	 * CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set.
+	 * balloon_stats.target_pages could not be bigger
+	 * than balloon_stats.current_pages because additional
+	 * memory allocation is not possible.
+	 */
+	balloon_stats.target_pages = balloon_stats.current_pages;
+
 	return 0;
 }
 
 static inline void hotplug_allocated_memory(void)
 {
 }
-#endif
+#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
 
 static int increase_reservation(unsigned long nr_pages)
 {
@@ -553,7 +498,7 @@ static void balloon_process(struct work_struct *work)
 	mutex_lock(&balloon_mutex);
 
 	do {
-		credit = current_target() - balloon_stats.current_pages;
+		credit = balloon_stats.target_pages - balloon_stats.current_pages;
 
 		if (credit > 0) {
 			if (balloon_stats.balloon_low || balloon_stats.balloon_high)
@@ -572,7 +517,7 @@ static void balloon_process(struct work_struct *work)
 	} while ((credit != 0) && !need_sleep);
 
 	/* Schedule more work if there is some still to be done. */
-	if (current_target() != balloon_stats.current_pages)
+	if (balloon_stats.target_pages != balloon_stats.current_pages)
 		mod_timer(&balloon_timer, jiffies + HZ);
 	else if (is_memory_resource_reserved())
 		hotplug_allocated_memory();
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6652eae..37f1894 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -202,8 +202,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-extern pg_data_t *hotadd_new_pgdat(int nid, u64 start);
-extern void rollback_node_hotadd(int nid, pg_data_t *pgdat);
+extern int add_registered_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 143e03c..48a65bb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -453,7 +453,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
+static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
 	struct pglist_data *pgdat;
 	unsigned long zones_size[MAX_NR_ZONES] = {0};
@@ -473,32 +473,21 @@ pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 	return pgdat;
 }
-EXPORT_SYMBOL_GPL(hotadd_new_pgdat);
 
-void rollback_node_hotadd(int nid, pg_data_t *pgdat)
+static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
 {
 	arch_refresh_nodedata(nid, NULL);
 	arch_free_nodedata(pgdat);
 	return;
 }
-EXPORT_SYMBOL_GPL(rollback_node_hotadd);
-
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory(int nid, u64 start, u64 size)
+static int __ref __add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
 	int new_pgdat = 0;
-	struct resource *res;
 	int ret;
 
-	lock_system_sleep();
-
-	res = register_memory_resource(start, size);
-	ret = -EEXIST;
-	if (!res)
-		goto out;
-
 	if (!node_online(nid)) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		ret = -ENOMEM;
@@ -535,11 +524,45 @@ error:
 	/* rollback pgdat allocation and others */
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
-	if (res)
-		release_memory_resource(res);
 
 out:
+	return ret;
+}
+
+int __ref add_registered_memory(int nid, u64 start, u64 size)
+{
+	int ret;
+
+	lock_system_sleep();
+	ret = __add_memory(nid, start, size);
 	unlock_system_sleep();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_registered_memory);
+
+int __ref add_memory(int nid, u64 start, u64 size)
+{
+	int ret = -EEXIST;
+	struct resource *res;
+
+	lock_system_sleep();
+
+	res = register_memory_resource(start, size);
+
+	if (!res)
+		goto out;
+
+	ret = __add_memory(nid, start, size);
+
+	if (!ret)
+		goto out;
+
+	release_memory_resource(res);
+
+out:
+	unlock_system_sleep();
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
