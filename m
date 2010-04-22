Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C46B86B0202
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:38:30 -0400 (EDT)
Received: by wwe15 with SMTP id 15so39589wwe.14
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:38:27 -0700 (PDT)
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH] ummunotify: Userspace support for MMU notifications V2
Date: Thu, 22 Apr 2010 16:38:13 +0300
Message-Id: <1271943493-12120-1-git-send-email-ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org, linux-mm@kvack.org, rolandd@cisco.com, peterz@infradead.org, mingo@elte.hu, pavel@ucw.cz, jsquyres@cisco.com, randy.dunlap@oracle.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Roland Dreier <rolandd@cisco.com>

As discussed in <http://article.gmane.org/gmane.linux.drivers.openib/61925>
and follow-up messages, libraries using RDMA would like to track
precisely when application code changes memory mapping via free(),
munmap(), etc.  Current pure-userspace solutions using malloc hooks
and other tricks are not robust, and the feeling among experts is that
the issue is unfixable without kernel help.

We solve this not by implementing the full API proposed in the email
linked above but rather with a simpler and more generic interface,
which may be useful in other contexts.  Specifically, we implement a
new character device driver, ummunotify, that creates a /dev/ummunotify
node.  A userspace process can open this node read-only and use the fd
as follows:

 1. ioctl() to register/unregister an address range to watch in the
    kernel (cf struct ummunotify_register_ioctl in <linux/ummunotify.h>).

 2. read() to retrieve events generated when a mapping in a watched
    address range is invalidated (cf struct ummunotify_event in
    <linux/ummunotify.h>).  select()/poll()/epoll() and SIGIO are
    handled for this IO.

 3. mmap() one page at offset 0 to map a kernel page that contains a
    generation counter that is incremented each time an event is
    generated.  This allows userspace to have a fast path that checks
    that no events have occurred without a system call.

Thanks to Jason Gunthorpe <jgunthorpe <at> obsidianresearch.com> for
suggestions on the interface design.  Also thanks to Jeff Squyres
<jsquyres <at> cisco.com> for prototyping support for this in Open MPI, which
helped find several bugs during development.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>

---

Changes from V1:
- Update Kbuild to handle test program build properly
- Update documentation to cover questions not addressed in previous
  thread
---
 Documentation/Makefile                  |    3 +-
 Documentation/ummunotify/Makefile       |    7 +
 Documentation/ummunotify/ummunotify.txt |  162 +++++++++
 Documentation/ummunotify/umn-test.c     |  200 +++++++++++
 drivers/char/Kconfig                    |   12 +
 drivers/char/Makefile                   |    1 +
 drivers/char/ummunotify.c               |  567 +++++++++++++++++++++++++++++++
 include/linux/Kbuild                    |    1 +
 include/linux/ummunotify.h              |  121 +++++++
 9 files changed, 1073 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/ummunotify/Makefile
 create mode 100644 Documentation/ummunotify/ummunotify.txt
 create mode 100644 Documentation/ummunotify/umn-test.c
 create mode 100644 drivers/char/ummunotify.c
 create mode 100644 include/linux/ummunotify.h

diff --git a/Documentation/Makefile b/Documentation/Makefile
index 6fc7ea1..27ba76a 100644
--- a/Documentation/Makefile
+++ b/Documentation/Makefile
@@ -1,3 +1,4 @@
 obj-m := DocBook/ accounting/ auxdisplay/ connector/ \
 	filesystems/ filesystems/configfs/ ia64/ laptops/ networking/ \
-	pcmcia/ spi/ timers/ video4linux/ vm/ watchdog/src/
+	pcmcia/ spi/ timers/ video4linux/ vm/ ummunotify/ \
+	watchdog/src/
diff --git a/Documentation/ummunotify/Makefile b/Documentation/ummunotify/Makefile
new file mode 100644
index 0000000..89f31a0
--- /dev/null
+++ b/Documentation/ummunotify/Makefile
@@ -0,0 +1,7 @@
+# List of programs to build
+hostprogs-y := umn-test
+
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
+
+HOSTCFLAGS_umn-test.o += -I$(objtree)/usr/include
diff --git a/Documentation/ummunotify/ummunotify.txt b/Documentation/ummunotify/ummunotify.txt
new file mode 100644
index 0000000..d6c2ccc
--- /dev/null
+++ b/Documentation/ummunotify/ummunotify.txt
@@ -0,0 +1,162 @@
+UMMUNOTIFY
+
+  Ummunotify relays MMU notifier events to userspace.  This is useful
+  for libraries that need to track the memory mapping of applications;
+  for example, MPI implementations using RDMA want to cache memory
+  registrations for performance, but tracking all possible crazy cases
+  such as when, say, the FORTRAN runtime frees memory is impossible
+  without kernel help.
+
+Basic Model
+
+  A userspace process uses it by opening /dev/ummunotify, which
+  returns a file descriptor.  Interest in address ranges is registered
+  using ioctl() and MMU notifier events are retrieved using read(), as
+  described in more detail below.  Userspace can register multiple
+  address ranges to watch, and can unregister individual ranges.
+
+  Userspace can also mmap() a single read-only page at offset 0 on
+  this file descriptor.  This page contains (at offest 0) a single
+  64-bit generation counter that the kernel increments each time an
+  MMU notifier event occurs.  Userspace can use this to very quickly
+  check if there are any events to retrieve without needing to do a
+  system call.
+
+Control
+
+  To start using ummunotify, a process opens /dev/ummunotify in
+  read-only mode.  This will attach to current->mm because the current
+  consumers of this functionality do all monitoring in the process
+  being monitored.  It is currently not possible to use this device to
+  monitor other processes.  Control from userspace is done via ioctl().
+  An ioctl was chosen because the number of files required to register
+  a new address range in sysfs would be unwieldy and new procfs entries
+  are discouraged.  The defined ioctls are:
+
+    UMMUNOTIFY_EXCHANGE_FEATURES: This ioctl takes a single 32-bit
+      word of feature flags as input, and the kernel updates the
+      features flags word to contain only features requested by
+      userspace and also supported by the kernel.
+
+      This ioctl is only included for forward compatibility; no
+      feature flags are currently defined, and the kernel will simply
+      update any requested feature mask to 0.  The kernel will always
+      default to a feature mask of 0 if this ioctl is not used, so
+      current userspace does not need to perform this ioctl.
+
+    UMMUNOTIFY_REGISTER_REGION: Userspace uses this ioctl to tell the
+      kernel to start delivering events for an address range.  The
+      range is described using struct ummunotify_register_ioctl:
+
+	struct ummunotify_register_ioctl {
+		__u64	start;
+		__u64	end;
+		__u64	user_cookie;
+		__u32	flags;
+		__u32	reserved;
+	};
+
+      start and end give the range of userspace virtual addresses;
+      start is included in the range and end is not, so an example of
+      a 4 KB range would be start=0x1000, end=0x2000.
+
+      user_cookie is an opaque 64-bit quantity that is returned by the
+      kernel in events involving the range, and used by userspace to
+      stop watching the range.  Each registered address range must
+      have a distinct user_cookie.
+
+      It is fine with the kernel if userspace registers multiple
+      overlapping or even duplicate address ranges, as long as a
+      different cookie is used for each registration.
+
+      flags and reserved are included for forward compatibility;
+      userspace should simply set them to 0 for the current interface.
+
+    UMMUNOTIFY_UNREGISTER_REGION: Userspace passes in the 64-bit
+      user_cookie used to register a range to tell the kernel to stop
+      watching an address range.  Once this ioctl completes, the
+      kernel will not deliver any further events for the range that is
+      unregistered.
+
+Events
+
+  When an event occurs that invalidates some of a process's memory
+  mapping in an address range being watched, ummunotify queues an
+  event report for that address range.  If more than one event
+  invalidates parts of the same address range before userspace
+  retrieves the queued report, then further reports for the same range
+  will not be queued -- when userspace does read the queue, only a
+  single report for a given range will be returned.
+
+  If multiple ranges being watched are invalidated by a single event
+  (which is especially likely if userspace registers overlapping
+  ranges), then an event report structure will be queued for each
+  address range registration.
+
+  It is possible, if a large enough number of overlapping ranges are
+  registered and the list of invalidated events is busy enough and
+  ignored long enough, to cause the kernel to run out of memory.
+  Because this situation is unlikely to occur, the event queue size
+  is not bounded in order to avoid dropping events if the queue grows
+  beyond set bounds.
+
+  Userspace retrieves queued events via read() on the ummunotify file
+  descriptor; a buffer that is at least as big as struct
+  ummunotify_event should be used to retrieve event reports, and if a
+  larger buffer is passed to read(), multiple reports will be returned
+  (if available).
+
+  If the ummunotify file descriptor is in blocking mode, a read() call
+  will wait for an event report to be available.  Userspace may also
+  set the ummunotify file descriptor to non-blocking mode and use all
+  standard ways of waiting for data to be available on the ummunotify
+  file descriptor, including epoll/poll()/select() and SIGIO.
+
+  The format of event reports is:
+
+	struct ummunotify_event {
+		__u32	type;
+		__u32	flags;
+		__u64	hint_start;
+		__u64	hint_end;
+		__u64	user_cookie_counter;
+	};
+
+  where the type field is either UMMUNOTIFY_EVENT_TYPE_INVAL or
+  UMMUNOTIFY_EVENT_TYPE_LAST.  Events of type INVAL describe
+  invalidation events as follows: user_cookie_counter contains the
+  cookie passed in when userspace registered the range that the event
+  is for.  hint_start and hint_end contain the start address and end
+  address that were invalidated.
+
+  The flags word contains bit flags, with only UMMUNOTIFY_EVENT_FLAG_HINT
+  defined at the moment.  If HINT is set, then the invalidation event
+  invalidated less than the full address range and the kernel returns
+  the exact range invalidated; if HINT is not sent then hint_start and
+  hint_end are set to the original range registered by userspace.
+  (HINT will not be set if, for example, multiple events invalidated
+  disjoint parts of the range and so a single start/end pair cannot
+  represent the parts of the range that were invalidated)
+
+  If the event type is LAST, then the read operation has emptied the
+  list of invalidated regions, and the flags, hint_start and hint_end
+  fields are not used.  user_cookie_counter holds the value of the
+  kernel's generation counter (see below of more details) when the
+  empty list occurred.
+
+Generation Count
+
+  Userspace may mmap() a page on a ummunotify file descriptor via
+
+	mmap(NULL, sizeof (__u64), PROT_READ, MAP_SHARED, ummunotify_fd, 0);
+
+  to get a read-only mapping of the kernel's 64-bit generation
+  counter.  The kernel will increment this generation counter each
+  time an event report is queued.
+
+  Userspace can use the generation counter as a quick check to avoid
+  system calls; if the value read from the mapped kernel counter is
+  still equal to the value returned in user_cookie_counter for the
+  most recent LAST event retrieved, then no further events have been
+  queued and there is no need to try a read() on the ummunotify file
+  descriptor.
diff --git a/Documentation/ummunotify/umn-test.c b/Documentation/ummunotify/umn-test.c
new file mode 100644
index 0000000..143db2c
--- /dev/null
+++ b/Documentation/ummunotify/umn-test.c
@@ -0,0 +1,200 @@
+/*
+ * Copyright (c) 2009 Cisco Systems.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <stdint.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <unistd.h>
+
+#include <linux/ummunotify.h>
+
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/ioctl.h>
+
+#define UMN_TEST_COOKIE 123
+
+static int		umn_fd;
+static volatile __u64  *umn_counter;
+
+static int umn_init(void)
+{
+	__u32 flags;
+
+	umn_fd = open("/dev/ummunotify", O_RDONLY);
+	if (umn_fd < 0) {
+		perror("open");
+		return 1;
+	}
+
+	if (ioctl(umn_fd, UMMUNOTIFY_EXCHANGE_FEATURES, &flags)) {
+		perror("exchange ioctl");
+		return 1;
+	}
+
+	printf("kernel feature flags: 0x%08x\n", flags);
+
+	umn_counter = mmap(NULL, sizeof *umn_counter, PROT_READ,
+			   MAP_SHARED, umn_fd, 0);
+	if (umn_counter == MAP_FAILED) {
+		perror("mmap");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int umn_register(void *buf, size_t size, __u64 cookie)
+{
+	struct ummunotify_register_ioctl r = {
+		.start		= (unsigned long) buf,
+		.end		= (unsigned long) buf + size,
+		.user_cookie	= cookie,
+	};
+
+	if (ioctl(umn_fd, UMMUNOTIFY_REGISTER_REGION, &r)) {
+		perror("register ioctl");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int umn_unregister(__u64 cookie)
+{
+	if (ioctl(umn_fd, UMMUNOTIFY_UNREGISTER_REGION, &cookie)) {
+		perror("unregister ioctl");
+		return 1;
+	}
+
+	return 0;
+}
+
+int main(int argc, char *argv[])
+{
+	int			page_size;
+	__u64			old_counter;
+	void		       *t;
+	int			got_it;
+
+	if (umn_init())
+		return 1;
+
+	printf("\n");
+
+	old_counter = *umn_counter;
+	if (old_counter != 0) {
+		fprintf(stderr, "counter = %lld (expected 0)\n", old_counter);
+		return 1;
+	}
+
+	page_size = sysconf(_SC_PAGESIZE);
+	t = mmap(NULL, 3 * page_size, PROT_READ,
+		 MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE, -1, 0);
+
+	if (umn_register(t, 3 * page_size, UMN_TEST_COOKIE))
+		return 1;
+
+	munmap(t + page_size, page_size);
+
+	old_counter = *umn_counter;
+	if (old_counter != 1) {
+		fprintf(stderr, "counter = %lld (expected 1)\n", old_counter);
+		return 1;
+	}
+
+	got_it = 0;
+	while (1) {
+		struct ummunotify_event	ev;
+		int			len;
+
+		len = read(umn_fd, &ev, sizeof ev);
+		if (len < 0) {
+			perror("read event");
+			return 1;
+		}
+		if (len != sizeof ev) {
+			fprintf(stderr, "Read gave %d bytes (!= event size %zd)\n",
+				len, sizeof ev);
+			return 1;
+		}
+
+		switch (ev.type) {
+		case UMMUNOTIFY_EVENT_TYPE_INVAL:
+			if (got_it) {
+				fprintf(stderr, "Extra invalidate event\n");
+				return 1;
+			}
+			if (ev.user_cookie_counter != UMN_TEST_COOKIE) {
+				fprintf(stderr, "Invalidate event for cookie %lld (expected %d)\n",
+					ev.user_cookie_counter,
+					UMN_TEST_COOKIE);
+				return 1;
+			}
+
+			printf("Invalidate event:\tcookie %lld\n",
+			       ev.user_cookie_counter);
+
+			if (!(ev.flags & UMMUNOTIFY_EVENT_FLAG_HINT)) {
+				fprintf(stderr, "Hint flag not set\n");
+				return 1;
+			}
+
+			if (ev.hint_start != (uintptr_t) t + page_size ||
+			    ev.hint_end != (uintptr_t) t + page_size * 2) {
+				fprintf(stderr, "Got hint %llx..%llx, expected %p..%p\n",
+					ev.hint_start, ev.hint_end,
+					t + page_size, t + page_size * 2);
+				return 1;
+			}
+
+			printf("\t\t\thint %llx...%llx\n",
+			       ev.hint_start, ev.hint_end);
+
+			got_it = 1;
+			break;
+
+		case UMMUNOTIFY_EVENT_TYPE_LAST:
+			if (!got_it) {
+				fprintf(stderr, "Last event without invalidate event\n");
+				return 1;
+			}
+
+			printf("Empty event:\t\tcounter %lld\n",
+			       ev.user_cookie_counter);
+			goto done;
+
+		default:
+			fprintf(stderr, "unknown event type %d\n",
+				ev.type);
+			return 1;
+		}
+	}
+
+done:
+	umn_unregister(123);
+	munmap(t, page_size);
+
+	old_counter = *umn_counter;
+	if (old_counter != 1) {
+		fprintf(stderr, "counter = %lld (expected 1)\n", old_counter);
+		return 1;
+	}
+
+	return 0;
+}
diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 3141dd3..cf26019 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -1111,6 +1111,18 @@ config DEVPORT
 	depends on ISA || PCI
 	default y
 
+config UMMUNOTIFY
+       tristate "Userspace MMU notifications"
+       select MMU_NOTIFIER
+       help
+         The ummunotify (userspace MMU notification) driver creates a
+         character device that can be used by userspace libraries to
+         get notifications when an application's memory mapping
+         changed.  This is used, for example, by RDMA libraries to
+         improve the reliability of memory registration caching, since
+         the kernel's MMU notifications can be used to know precisely
+         when to shoot down a cached registration.
+
 source "drivers/s390/char/Kconfig"
 
 endmenu
diff --git a/drivers/char/Makefile b/drivers/char/Makefile
index f957edf..521e5de 100644
--- a/drivers/char/Makefile
+++ b/drivers/char/Makefile
@@ -97,6 +97,7 @@ obj-$(CONFIG_NSC_GPIO)		+= nsc_gpio.o
 obj-$(CONFIG_CS5535_GPIO)	+= cs5535_gpio.o
 obj-$(CONFIG_GPIO_TB0219)	+= tb0219.o
 obj-$(CONFIG_TELCLOCK)		+= tlclk.o
+obj-$(CONFIG_UMMUNOTIFY)	+= ummunotify.o
 
 obj-$(CONFIG_MWAVE)		+= mwave/
 obj-$(CONFIG_AGP)		+= agp/
diff --git a/drivers/char/ummunotify.c b/drivers/char/ummunotify.c
new file mode 100644
index 0000000..c14df3f
--- /dev/null
+++ b/drivers/char/ummunotify.c
@@ -0,0 +1,567 @@
+/*
+ * Copyright (c) 2009 Cisco Systems.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/miscdevice.h>
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+#include <linux/poll.h>
+#include <linux/rbtree.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/uaccess.h>
+#include <linux/ummunotify.h>
+
+#include <asm/cacheflush.h>
+
+MODULE_AUTHOR("Roland Dreier");
+MODULE_DESCRIPTION("Userspace MMU notifiers");
+MODULE_LICENSE("GPL v2");
+
+/*
+ * Information about an address range userspace has asked us to watch.
+ *
+ * user_cookie: Opaque cookie given to us when userspace registers the
+ *   address range.
+ *
+ * start, end: Address range; start is inclusive, end is exclusive.
+ *
+ * hint_start, hint_end: If a single MMU notification event
+ *   invalidates the address range, we hold the actual range of
+ *   addresses that were invalidated (and set UMMUNOTIFY_FLAG_HINT).
+ *   If another event hits this range before userspace reads the
+ *   event, we give up and don't try to keep track of which subsets
+ *   got invalidated.
+ *
+ * flags: Holds the INVALID flag for ranges that are on the invalid
+ *   list and/or the HINT flag for ranges where the hint range holds
+ *   good information.
+ *
+ * node: Used to put the range into an rbtree we use to be able to
+ *   scan address ranges in order.
+ *
+ * list: Used to put the range on the invalid list when an MMU
+ *   notification event hits the range.
+ */
+enum {
+	UMMUNOTIFY_FLAG_INVALID	= 1,
+	UMMUNOTIFY_FLAG_HINT	= 2,
+};
+
+struct ummunotify_reg {
+	u64			user_cookie;
+	unsigned long		start;
+	unsigned long		end;
+	unsigned long		hint_start;
+	unsigned long		hint_end;
+	unsigned long		flags;
+	struct rb_node		node;
+	struct list_head	list;
+};
+
+/*
+ * Context attached to each file that userspace opens.
+ *
+ * mmu_notifier: MMU notifier registered for this context.
+ *
+ * mm: mm_struct for process that created the context; we use this to
+ *   hold a reference to the mm to make sure it doesn't go away until
+ *   we're done with it.
+ *
+ * reg_tree: RB tree of address ranges being watched, sorted by start
+ *   address.
+ *
+ * invalid_list: List of address ranges that have been invalidated by
+ *   MMU notification events; as userspace reads events, the address
+ *   range corresponding to the event is removed from the list.
+ *
+ * counter: Page that can be mapped read-only by userspace, which
+ *   holds a generation count that is incremented each time an event
+ *   occurs.
+ *
+ * lock: Spinlock used to protect all context.
+ *
+ * read_wait: Wait queue used to wait for data to become available in
+ *   blocking read()s.
+ *
+ * async_queue: Used to implement fasync().
+ *
+ * need_empty: Set when userspace reads an invalidation event, so that
+ *   read() knows it must generate an "empty" event when userspace
+ *   drains the invalid_list.
+ *
+ * used: Set after userspace does anything with the file, so that the
+ *   "exchange flags" ioctl() knows it's too late to change anything.
+ */
+struct ummunotify_file {
+	struct mmu_notifier	mmu_notifier;
+	struct mm_struct       *mm;
+	struct rb_root		reg_tree;
+	struct list_head	invalid_list;
+	u64		       *counter;
+	spinlock_t		lock;
+	wait_queue_head_t	read_wait;
+	struct fasync_struct   *async_queue;
+	int			need_empty;
+	int			used;
+};
+
+static void ummunotify_handle_notify(struct mmu_notifier *mn,
+				     unsigned long start, unsigned long end)
+{
+	struct ummunotify_file *priv =
+		container_of(mn, struct ummunotify_file, mmu_notifier);
+	struct rb_node *n;
+	struct ummunotify_reg *reg;
+	unsigned long flags;
+	int hit = 0;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	for (n = rb_first(&priv->reg_tree); n; n = rb_next(n)) {
+		reg = rb_entry(n, struct ummunotify_reg, node);
+
+		/*
+		 * Ranges overlap if they're not disjoint; and they're
+		 * disjoint if the end of one is before the start of
+		 * the other one.  So if both disjointness comparisons
+		 * fail then the ranges overlap.
+		 *
+		 * Since we keep the tree of regions we're watching
+		 * sorted by start address, we can end this loop as
+		 * soon as we hit a region that starts past the end of
+		 * the range for the event we're handling.
+		 */
+		if (reg->start >= end)
+			break;
+
+		/*
+		 * Just go to the next region if the start of the
+		 * range is after the end of the region -- there
+		 * might still be more overlapping ranges that have a
+		 * greater start.
+		 */
+		if (start >= reg->end)
+			continue;
+
+		hit = 1;
+
+		if (test_and_set_bit(UMMUNOTIFY_FLAG_INVALID, &reg->flags)) {
+			/* Already on invalid list */
+			clear_bit(UMMUNOTIFY_FLAG_HINT, &reg->flags);
+		} else {
+			list_add_tail(&reg->list, &priv->invalid_list);
+			set_bit(UMMUNOTIFY_FLAG_HINT, &reg->flags);
+			reg->hint_start = start;
+			reg->hint_end   = end;
+		}
+	}
+
+	if (hit) {
+		++(*priv->counter);
+		flush_dcache_page(virt_to_page(priv->counter));
+		wake_up_interruptible(&priv->read_wait);
+		kill_fasync(&priv->async_queue, SIGIO, POLL_IN);
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
+static void ummunotify_invalidate_page(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long addr)
+{
+	ummunotify_handle_notify(mn, addr, addr + PAGE_SIZE);
+}
+
+static void ummunotify_invalidate_range_start(struct mmu_notifier *mn,
+					      struct mm_struct *mm,
+					      unsigned long start,
+					      unsigned long end)
+{
+	ummunotify_handle_notify(mn, start, end);
+}
+
+static const struct mmu_notifier_ops ummunotify_mmu_notifier_ops = {
+	.invalidate_page	= ummunotify_invalidate_page,
+	.invalidate_range_start	= ummunotify_invalidate_range_start,
+};
+
+static int ummunotify_open(struct inode *inode, struct file *filp)
+{
+	struct ummunotify_file *priv;
+	int ret;
+
+	if (filp->f_mode & FMODE_WRITE)
+		return -EINVAL;
+
+	priv = kmalloc(sizeof *priv, GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->counter = (void *) get_zeroed_page(GFP_KERNEL);
+	if (!priv->counter) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	priv->reg_tree = RB_ROOT;
+	INIT_LIST_HEAD(&priv->invalid_list);
+	spin_lock_init(&priv->lock);
+	init_waitqueue_head(&priv->read_wait);
+	priv->async_queue = NULL;
+	priv->need_empty  = 0;
+	priv->used	  = 0;
+
+	priv->mmu_notifier.ops = &ummunotify_mmu_notifier_ops;
+	/*
+	 * Register notifier last, since notifications can occur as
+	 * soon as we register....
+	 */
+	ret = mmu_notifier_register(&priv->mmu_notifier, current->mm);
+	if (ret)
+		goto err_page;
+
+	priv->mm = current->mm;
+	atomic_inc(&priv->mm->mm_count);
+
+	filp->private_data = priv;
+
+	return 0;
+
+err_page:
+	free_page((unsigned long) priv->counter);
+
+err:
+	kfree(priv);
+	return ret;
+}
+
+static int ummunotify_close(struct inode *inode, struct file *filp)
+{
+	struct ummunotify_file *priv = filp->private_data;
+	struct rb_node *n;
+	struct ummunotify_reg *reg;
+
+	mmu_notifier_unregister(&priv->mmu_notifier, priv->mm);
+	mmdrop(priv->mm);
+	free_page((unsigned long) priv->counter);
+
+	for (n = rb_first(&priv->reg_tree); n; n = rb_next(n)) {
+		reg = rb_entry(n, struct ummunotify_reg, node);
+		kfree(reg);
+	}
+
+	kfree(priv);
+
+	return 0;
+}
+
+static bool ummunotify_readable(struct ummunotify_file *priv)
+{
+	return priv->need_empty || !list_empty(&priv->invalid_list);
+}
+
+static ssize_t ummunotify_read(struct file *filp, char __user *buf,
+			       size_t count, loff_t *pos)
+{
+	struct ummunotify_file *priv = filp->private_data;
+	struct ummunotify_reg *reg;
+	ssize_t ret;
+	struct ummunotify_event *events;
+	int max;
+	int n;
+
+	priv->used = 1;
+
+	events = (void *) get_zeroed_page(GFP_KERNEL);
+	if (!events) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock_irq(&priv->lock);
+
+	while (!ummunotify_readable(priv)) {
+		spin_unlock_irq(&priv->lock);
+
+		if (filp->f_flags & O_NONBLOCK) {
+			ret = -EAGAIN;
+			goto out;
+		}
+
+		if (wait_event_interruptible(priv->read_wait,
+					     ummunotify_readable(priv))) {
+			ret = -ERESTARTSYS;
+			goto out;
+		}
+
+		spin_lock_irq(&priv->lock);
+	}
+
+	max = min_t(size_t, PAGE_SIZE, count) / sizeof *events;
+
+	for (n = 0; n < max; ++n) {
+		if (list_empty(&priv->invalid_list)) {
+			events[n].type = UMMUNOTIFY_EVENT_TYPE_LAST;
+			events[n].user_cookie_counter = *priv->counter;
+			++n;
+			priv->need_empty = 0;
+			break;
+		}
+
+		reg = list_first_entry(&priv->invalid_list,
+				       struct ummunotify_reg, list);
+
+		events[n].type = UMMUNOTIFY_EVENT_TYPE_INVAL;
+		if (test_bit(UMMUNOTIFY_FLAG_HINT, &reg->flags)) {
+			events[n].flags	     = UMMUNOTIFY_EVENT_FLAG_HINT;
+			events[n].hint_start = max(reg->start, reg->hint_start);
+			events[n].hint_end   = min(reg->end, reg->hint_end);
+		} else {
+			events[n].hint_start = reg->start;
+			events[n].hint_end   = reg->end;
+		}
+		events[n].user_cookie_counter = reg->user_cookie;
+
+		list_del(&reg->list);
+		reg->flags = 0;
+		priv->need_empty = 1;
+	}
+
+	spin_unlock_irq(&priv->lock);
+
+	if (copy_to_user(buf, events, n * sizeof *events))
+		ret = -EFAULT;
+	else
+		ret = n * sizeof *events;
+
+out:
+	free_page((unsigned long) events);
+	return ret;
+}
+
+static unsigned int ummunotify_poll(struct file *filp,
+				    struct poll_table_struct *wait)
+{
+	struct ummunotify_file *priv = filp->private_data;
+
+	poll_wait(filp, &priv->read_wait, wait);
+
+	return ummunotify_readable(priv) ? (POLLIN | POLLRDNORM) : 0;
+}
+
+static long ummunotify_exchange_features(struct ummunotify_file *priv,
+					 __u32 __user *arg)
+{
+	u32 feature_mask;
+
+	if (priv->used)
+		return -EINVAL;
+
+	priv->used = 1;
+
+	if (copy_from_user(&feature_mask, arg, sizeof(feature_mask)))
+		return -EFAULT;
+
+	/* No extensions defined at present. */
+	feature_mask = 0;
+
+	if (copy_to_user(arg, &feature_mask, sizeof(feature_mask)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static long ummunotify_register_region(struct ummunotify_file *priv,
+				       void __user *arg)
+{
+	struct ummunotify_register_ioctl parm;
+	struct ummunotify_reg *reg, *treg;
+	struct rb_node **n = &priv->reg_tree.rb_node;
+	struct rb_node *pn;
+	int ret = 0;
+
+	if (copy_from_user(&parm, arg, sizeof parm))
+		return -EFAULT;
+
+	priv->used = 1;
+
+	reg = kmalloc(sizeof *reg, GFP_KERNEL);
+	if (!reg)
+		return -ENOMEM;
+
+	reg->user_cookie	= parm.user_cookie;
+	reg->start		= parm.start;
+	reg->end		= parm.end;
+	reg->flags		= 0;
+
+	spin_lock_irq(&priv->lock);
+
+	for (pn = rb_first(&priv->reg_tree); pn; pn = rb_next(pn)) {
+		treg = rb_entry(pn, struct ummunotify_reg, node);
+
+		if (treg->user_cookie == parm.user_cookie) {
+			kfree(reg);
+			ret = -EINVAL;
+			goto out;
+		}
+	}
+
+	pn = NULL;
+	while (*n) {
+		pn = *n;
+		treg = rb_entry(pn, struct ummunotify_reg, node);
+
+		if (reg->start <= treg->start)
+			n = &pn->rb_left;
+		else
+			n = &pn->rb_right;
+	}
+
+	rb_link_node(&reg->node, pn, n);
+	rb_insert_color(&reg->node, &priv->reg_tree);
+
+out:
+	spin_unlock_irq(&priv->lock);
+
+	return ret;
+}
+
+static long ummunotify_unregister_region(struct ummunotify_file *priv,
+					 __u64 __user *arg)
+{
+	u64 user_cookie;
+	struct rb_node *n;
+	struct ummunotify_reg *reg;
+	int ret = -EINVAL;
+
+	if (copy_from_user(&user_cookie, arg, sizeof(user_cookie)))
+		return -EFAULT;
+
+	spin_lock_irq(&priv->lock);
+
+	for (n = rb_first(&priv->reg_tree); n; n = rb_next(n)) {
+		reg = rb_entry(n, struct ummunotify_reg, node);
+
+		if (reg->user_cookie == user_cookie) {
+			rb_erase(n, &priv->reg_tree);
+			if (test_bit(UMMUNOTIFY_FLAG_INVALID, &reg->flags))
+				list_del(&reg->list);
+			kfree(reg);
+			ret = 0;
+			break;
+		}
+	}
+
+	spin_unlock_irq(&priv->lock);
+
+	return ret;
+}
+
+static long ummunotify_ioctl(struct file *filp, unsigned int cmd,
+			     unsigned long arg)
+{
+	struct ummunotify_file *priv = filp->private_data;
+	void __user *argp = (void __user *) arg;
+
+	switch (cmd) {
+	case UMMUNOTIFY_EXCHANGE_FEATURES:
+		return ummunotify_exchange_features(priv, argp);
+	case UMMUNOTIFY_REGISTER_REGION:
+		return ummunotify_register_region(priv, argp);
+	case UMMUNOTIFY_UNREGISTER_REGION:
+		return ummunotify_unregister_region(priv, argp);
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+
+static int ummunotify_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct ummunotify_file *priv = vma->vm_private_data;
+
+	if (vmf->pgoff != 0)
+		return VM_FAULT_SIGBUS;
+
+	vmf->page = virt_to_page(priv->counter);
+	get_page(vmf->page);
+
+	return 0;
+
+}
+
+static struct vm_operations_struct ummunotify_vm_ops = {
+	.fault		= ummunotify_fault,
+};
+
+static int ummunotify_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	struct ummunotify_file *priv = filp->private_data;
+
+	if (vma->vm_end - vma->vm_start != PAGE_SIZE || vma->vm_pgoff != 0)
+		return -EINVAL;
+
+	vma->vm_ops		= &ummunotify_vm_ops;
+	vma->vm_private_data	= priv;
+
+	return 0;
+}
+
+static int ummunotify_fasync(int fd, struct file *filp, int on)
+{
+	struct ummunotify_file *priv = filp->private_data;
+
+	return fasync_helper(fd, filp, on, &priv->async_queue);
+}
+
+static const struct file_operations ummunotify_fops = {
+	.owner		= THIS_MODULE,
+	.open		= ummunotify_open,
+	.release	= ummunotify_close,
+	.read		= ummunotify_read,
+	.poll		= ummunotify_poll,
+	.unlocked_ioctl	= ummunotify_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ummunotify_ioctl,
+#endif
+	.mmap		= ummunotify_mmap,
+	.fasync		= ummunotify_fasync,
+};
+
+static struct miscdevice ummunotify_misc = {
+	.minor	= MISC_DYNAMIC_MINOR,
+	.name	= "ummunotify",
+	.fops	= &ummunotify_fops,
+};
+
+static int __init ummunotify_init(void)
+{
+	return misc_register(&ummunotify_misc);
+}
+
+static void __exit ummunotify_cleanup(void)
+{
+	misc_deregister(&ummunotify_misc);
+}
+
+module_init(ummunotify_init);
+module_exit(ummunotify_cleanup);
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e2ea0b2..e086b39 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -163,6 +163,7 @@ header-y += tipc_config.h
 header-y += toshiba.h
 header-y += udf_fs_i.h
 header-y += ultrasound.h
+header-y += ummunotify.h
 header-y += un.h
 header-y += utime.h
 header-y += veth.h
diff --git a/include/linux/ummunotify.h b/include/linux/ummunotify.h
new file mode 100644
index 0000000..21b0d03
--- /dev/null
+++ b/include/linux/ummunotify.h
@@ -0,0 +1,121 @@
+/*
+ * Copyright (c) 2009 Cisco Systems.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _LINUX_UMMUNOTIFY_H
+#define _LINUX_UMMUNOTIFY_H
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+
+/*
+ * Ummunotify relays MMU notifier events to userspace.  A userspace
+ * process uses it by opening /dev/ummunotify, which returns a file
+ * descriptor.  Interest in address ranges is registered using ioctl()
+ * and MMU notifier events are retrieved using read(), as described in
+ * more detail below.
+ *
+ * Userspace can also mmap() a single read-only page at offset 0 on
+ * this file descriptor.  This page contains (at offest 0) a single
+ * 64-bit generation counter that the kernel increments each time an
+ * MMU notifier event occurs.  Userspace can use this to very quickly
+ * check if there are any events to retrieve without needing to do a
+ * system call.
+ */
+
+/*
+ * struct ummunotify_register_ioctl describes an address range from
+ * start to end (including start but not including end) to be
+ * monitored.  user_cookie is an opaque handle that userspace assigns,
+ * and which is used to unregister.  flags and reserved are currently
+ * unused and should be set to 0 for forward compatibility.
+ */
+struct ummunotify_register_ioctl {
+	__u64	start;
+	__u64	end;
+	__u64	user_cookie;
+	__u32	flags;
+	__u32	reserved;
+};
+
+#define UMMUNOTIFY_MAGIC		'U'
+
+/*
+ * Forward compatibility: Userspace passes in a 32-bit feature mask
+ * with feature flags set indicating which extensions it wishes to
+ * use.  The kernel will return a feature mask with the bits of
+ * userspace's mask that the kernel implements; from that point on
+ * both userspace and the kernel should behave as described by the
+ * kernel's feature mask.
+ *
+ * If userspace does not perform a UMMUNOTIFY_EXCHANGE_FEATURES ioctl,
+ * then the kernel will use a feature mask of 0.
+ *
+ * No feature flags are currently defined, so the kernel will always
+ * return a feature mask of 0 at present.
+ */
+#define UMMUNOTIFY_EXCHANGE_FEATURES	_IOWR(UMMUNOTIFY_MAGIC, 1, __u32)
+
+/*
+ * Register interest in an address range; userspace should pass in a
+ * struct ummunotify_register_ioctl describing the region.
+ */
+#define UMMUNOTIFY_REGISTER_REGION	_IOW(UMMUNOTIFY_MAGIC, 2, \
+					     struct ummunotify_register_ioctl)
+/*
+ * Unregister interest in an address range; userspace should pass in
+ * the user_cookie value that was used to register the address range.
+ * No events for the address range will be reported once it is
+ * unregistered.
+ */
+#define UMMUNOTIFY_UNREGISTER_REGION	_IOW(UMMUNOTIFY_MAGIC, 3, __u64)
+
+/*
+ * Invalidation events are returned whenever the kernel changes the
+ * mapping for a monitored address.  These events are retrieved by
+ * read() on the ummunotify file descriptor, which will fill the
+ * read() buffer with struct ummunotify_event.
+ *
+ * If type field is INVAL, then user_cookie_counter holds the
+ * user_cookie for the region being reported; if the HINT flag is set
+ * then hint_start/hint_end hold the start and end of the mapping that
+ * was invalidated.  (If HINT is not set, then multiple events
+ * invalidated parts of the registered range and hint_start/hint_end
+ * and set to the start/end of the whole registered range)
+ *
+ * If type is LAST, then the read operation has emptied the list of
+ * invalidated regions, and user_cookie_counter holds the value of the
+ * kernel's generation counter when the empty list occurred.  The
+ * other fields are not filled in for this event.
+ */
+enum {
+	UMMUNOTIFY_EVENT_TYPE_INVAL	= 0,
+	UMMUNOTIFY_EVENT_TYPE_LAST	= 1,
+};
+
+enum {
+	UMMUNOTIFY_EVENT_FLAG_HINT	= 1 << 0,
+};
+
+struct ummunotify_event {
+	__u32	type;
+	__u32	flags;
+	__u64	hint_start;
+	__u64	hint_end;
+	__u64	user_cookie_counter;
+};
+
+#endif /* _LINUX_UMMUNOTIFY_H */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
