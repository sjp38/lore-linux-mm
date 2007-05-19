Date: Sat, 19 May 2007 10:53:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070519175320.GB19966@holomorphy.com>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181633240.24071@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705181633240.24071@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Nick Piggin wrote:
>> If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
>> which is quite a nice number for cache purposes.
>> However we don't have to let those 8 bytes go to waste: we can use them
>> to store the virtual address of the page, which kind of makes sense for
>> 64-bit, because they can likely to use complicated memory models.

On Fri, May 18, 2007 at 04:42:10PM +0100, Hugh Dickins wrote:
> Sooner rather than later, don't we need those 8 bytes to expand from
> atomic_t to atomic64_t _count and _mapcount?  Not that we really need
> all 64 bits of both, but I don't know how to work atomically with less.
> (Why do I have this sneaking feeling that you're actually wanting
> to stick something into the lower bits of page->virtual?)

I wonder how close we get to overflow on ->_mapcount and ->_count.
(untested/uncompiled).


-- wli


Index: mm-2.6.21/include/linux/mm.h
===================================================================
--- mm-2.6.21.orig/include/linux/mm.h	2007-05-19 10:17:17.682653270 -0700
+++ mm-2.6.21/include/linux/mm.h	2007-05-19 10:38:52.376433663 -0700
@@ -248,6 +248,24 @@
  * routine so they can be sure the page doesn't go away from under them.
  */
 
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
+static inline int page_count(struct page *page)
+{
+	return atomic_read(&compound_head(page)->_count);
+}
+
+#ifdef CONFIG_ATOMIC_HIWATER
+unsigned long count_hiwater(void);
+int put_page_testzero(struct page *);
+int get_page_unless_zero(struct page *);
+void get_page(struct page *);
+#else /* !CONFIG_ATOMIC_HIWATER */
 /*
  * Drop a ref, return true if the refcount fell to zero (the page has no users)
  */
@@ -267,24 +285,13 @@
 	return atomic_inc_not_zero(&page->_count);
 }
 
-static inline struct page *compound_head(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return page->first_page;
-	return page;
-}
-
-static inline int page_count(struct page *page)
-{
-	return atomic_read(&compound_head(page)->_count);
-}
-
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
 	VM_BUG_ON(atomic_read(&page->_count) == 0);
 	atomic_inc(&page->_count);
 }
+#endif /* !CONFIG_ATOMIC_HIWATER */
 
 static inline struct page *virt_to_head_page(const void *x)
 {
Index: mm-2.6.21/mm/Makefile
===================================================================
--- mm-2.6.21.orig/mm/Makefile	2007-05-18 09:58:43.851524250 -0700
+++ mm-2.6.21/mm/Makefile	2007-05-18 09:58:59.484415118 -0700
@@ -31,4 +31,4 @@
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-
+obj-$(CONFIG_ATOMIC_HIWATER) += atomic-hiwater.o
Index: mm-2.6.21/mm/atomic-hiwater.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mm-2.6.21/mm/atomic-hiwater.c	2007-05-19 10:46:09.713356074 -0700
@@ -0,0 +1,63 @@
+#include <linux/mm_types.h>
+#include <linux/percpu.h>
+#include <linux/module.h>
+#include <linux/irqflags.h>
+#include <linux/page-flags.h>
+#include <linux/mm.h>
+
+static DEFINE_PER_CPU(unsigned long, __count_hiwater);
+
+unsigned long count_hiwater(void)
+{
+	int cpu;
+	unsigned long *hiwater, count = 0;
+
+	for_each_online_cpu(cpu) {
+		hiwater = &per_cpu(__count_hiwater, cpu);
+		if (*hiwater > count)
+			count = *hiwater;
+	}
+	return count;
+}
+EXPORT_SYMBOL_GPL(count_hiwater);
+
+static void update_count_hiwater(unsigned long count)
+{
+	unsigned long flags, *hiwater;
+
+	local_irq_save(flags);
+	hiwater = &__get_cpu_var(__count_hiwater);
+	if (unlikely(count > *hiwater))
+		*hiwater = count;
+	local_irq_restore(flags);
+}
+
+int get_page_unless_zero(struct page *page)
+{
+	int ret;
+
+	VM_BUG_ON(PageCompound(page));
+	ret = atomic_inc_not_zero(&page->_count);
+	update_count_hiwater(atomic_read(&page->_count));
+	return ret;
+}
+EXPORT_SYMBOL(get_page_unless_zero);
+
+void get_page(struct page *page)
+{
+	page = compound_head(page);
+	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	update_count_hiwater(atomic_inc_return(&page->_count));
+}
+EXPORT_SYMBOL(get_page);
+
+int put_page_testzero(struct page *page)
+{
+	int count;
+
+	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	count = atomic_dec_return(&page->_count);
+	update_count_hiwater(count);
+	return count;
+}
+EXPORT_SYMBOL(put_page_testzero);
Index: mm-2.6.21/mm/Kconfig
===================================================================
--- mm-2.6.21.orig/mm/Kconfig	2007-05-19 10:20:24.361291479 -0700
+++ mm-2.6.21/mm/Kconfig	2007-05-19 10:22:17.231723598 -0700
@@ -168,3 +168,8 @@
 	depends on QUICKLIST
 	default "1"
 
+config ATOMIC_HIWATER
+	bool "Track page reference count high watermarks."
+	default n
+	help
+	  This option tracks the largest reference counts seen for a page.
Index: mm-2.6.21/mm/vmstat.c
===================================================================
--- mm-2.6.21.orig/mm/vmstat.c	2007-05-19 10:34:41.382130313 -0700
+++ mm-2.6.21/mm/vmstat.c	2007-05-19 10:38:38.519644010 -0700
@@ -607,6 +607,29 @@
 	return v + *pos;
 }
 
+#ifdef CONFIG_ATOMIC_HIWATER
+static void *vmstat_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	(*pos)++;
+	if (*pos == ARRAY_SIZE(vmstat_text))
+		return (void *)~0UL;
+	else if (*pos > ARRAY_SIZE(vmstat_text))
+		return NULL;
+	return (unsigned long *)m->private + *pos;
+}
+
+static int vmstat_show(struct seq_file *m, void *arg)
+{
+	unsigned long *l = arg;
+	unsigned long off = l - (unsigned long *)m->private;
+
+	if (off < ARRAY_SIZE(vmstat_text))
+		seq_printf(m, "%s %lu\n", vmstat_text[off], *l);
+	else
+		seq_printf(m, "count_hiwater %lu\n", count_hiwater());
+	return 0;
+}
+#else /* !CONFIG_ATOMIC_HIWATER */
 static void *vmstat_next(struct seq_file *m, void *arg, loff_t *pos)
 {
 	(*pos)++;
@@ -623,6 +646,7 @@
 	seq_printf(m, "%s %lu\n", vmstat_text[off], *l);
 	return 0;
 }
+#endif /* !CONFIG_ATOMIC_HIWATER */
 
 static void vmstat_stop(struct seq_file *m, void *arg)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
