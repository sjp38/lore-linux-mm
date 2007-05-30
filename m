Date: Wed, 30 May 2007 16:09:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Change error reporting format to follow lockdep loosely
Message-ID: <Pine.LNX.4.64.0705301605590.3232@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Changes the error reporting format to loosely follow lockdep.

If data corruption is detected then we generate the following lines:

============================================
BUG <slab-cache>: <problem>
--------------------------------------------

INFO: <more information> [possibly multiple times]

<object dump>

FIX <slab-cache>: <remedial action>

This also adds some more intelligence to the data corruption detection. Its
now capable of figuring out the start and end.

Add a comment on how to configure SLUB so that a production system may
continue to operate even though occasional slab corruption occur through
a misbehaving kernel component. See "Emergency operations" in
Documentation/vm/slub.txt.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slub.txt |  139 ++++++++++++++---------
 mm/slub.c                 |  277 +++++++++++++++++++++++++---------------------
 2 files changed, 244 insertions(+), 172 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-30 12:27:04.000000000 -0700
+++ slub/mm/slub.c	2007-05-30 13:43:54.000000000 -0700
@@ -347,7 +347,7 @@ static void print_section(char *text, u8
 
 	for (i = 0; i < length; i++) {
 		if (newline) {
-			printk(KERN_ERR "%10s 0x%p: ", text, addr + i);
+			printk(KERN_ERR "%8s 0x%p: ", text, addr + i);
 			newline = 0;
 		}
 		printk(" %02x", addr[i]);
@@ -404,10 +404,11 @@ static void set_track(struct kmem_cache 
 
 static void init_tracking(struct kmem_cache *s, void *object)
 {
-	if (s->flags & SLAB_STORE_USER) {
-		set_track(s, object, TRACK_FREE, NULL);
-		set_track(s, object, TRACK_ALLOC, NULL);
-	}
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	set_track(s, object, TRACK_FREE, NULL);
+	set_track(s, object, TRACK_ALLOC, NULL);
 }
 
 static void print_track(const char *s, struct track *t)
@@ -415,65 +416,106 @@ static void print_track(const char *s, s
 	if (!t->addr)
 		return;
 
-	printk(KERN_ERR "%s: ", s);
+	printk(KERN_ERR "INFO: %s in ", s);
 	__print_symbol("%s", (unsigned long)t->addr);
-	printk(" jiffies_ago=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
+	printk(" age=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
+}
+
+static void print_tracking(struct kmem_cache *s, void *object)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	print_track("Allocated", get_track(s, object, TRACK_ALLOC));
+	print_track("Freed", get_track(s, object, TRACK_FREE));
 }
 
-static void print_trailer(struct kmem_cache *s, u8 *p)
+static void print_page_info(struct page *page)
+{
+	printk(KERN_ERR "INFO: Slab 0x%p used=%u fp=0x%p flags=0x%04lx\n",
+		page, page->inuse, page->freelist, page->flags);
+
+}
+
+static void slab_bug(struct kmem_cache *s, char *fmt, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	printk(KERN_ERR "========================================"
+			"=====================================\n");
+	printk(KERN_ERR "BUG %s: %s\n", s->name, buf);
+	printk(KERN_ERR "----------------------------------------"
+			"-------------------------------------\n\n");
+}
+
+static void slab_fix(struct kmem_cache *s, char *fmt, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	printk(KERN_ERR "FIX %s: %s\n", s->name, buf);
+}
+
+static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 {
 	unsigned int off;	/* Offset of last byte */
+	u8 *addr = page_address(page);
+
+	print_tracking(s, p);
+
+	print_page_info(page);
+
+	printk(KERN_ERR "INFO: Object 0x%p @offset=%lu fp=0x%p\n\n",
+			p, p - addr, get_freepointer(s, p));
+
+	if (p > addr + 16)
+		print_section("Bytes b4", p - 16, 16);
+
+	print_section("Object", p, min(s->objsize, 128));
 
 	if (s->flags & SLAB_RED_ZONE)
 		print_section("Redzone", p + s->objsize,
 			s->inuse - s->objsize);
 
-	printk(KERN_ERR "FreePointer 0x%p -> 0x%p\n",
-			p + s->offset,
-			get_freepointer(s, p));
-
 	if (s->offset)
 		off = s->offset + sizeof(void *);
 	else
 		off = s->inuse;
 
-	if (s->flags & SLAB_STORE_USER) {
-		print_track("Last alloc", get_track(s, p, TRACK_ALLOC));
-		print_track("Last free ", get_track(s, p, TRACK_FREE));
+	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
-	}
 
 	if (off != s->size)
 		/* Beginning of the filler is the free pointer */
-		print_section("Filler", p + off, s->size - off);
+		print_section("Padding", p + off, s->size - off);
+
+	dump_stack();
 }
 
 static void object_err(struct kmem_cache *s, struct page *page,
 			u8 *object, char *reason)
 {
-	u8 *addr = page_address(page);
-
-	printk(KERN_ERR "*** SLUB %s: %s@0x%p slab 0x%p\n",
-			s->name, reason, object, page);
-	printk(KERN_ERR "    offset=%tu flags=0x%04lx inuse=%u freelist=0x%p\n",
-		object - addr, page->flags, page->inuse, page->freelist);
-	if (object > addr + 16)
-		print_section("Bytes b4", object - 16, 16);
-	print_section("Object", object, min(s->objsize, 128));
-	print_trailer(s, object);
-	dump_stack();
+	slab_bug(s, reason);
+	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page, char *reason, ...)
+static void slab_err(struct kmem_cache *s, struct page *page, char *fmt, ...)
 {
 	va_list args;
 	char buf[100];
 
-	va_start(args, reason);
-	vsnprintf(buf, sizeof(buf), reason, args);
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
-	printk(KERN_ERR "*** SLUB %s: %s in slab @0x%p\n", s->name, buf,
-		page);
+	slab_bug(s, fmt);
+	print_page_info(page);
 	dump_stack();
 }
 
@@ -492,15 +534,46 @@ static void init_object(struct kmem_cach
 			s->inuse - s->objsize);
 }
 
-static int check_bytes(u8 *start, unsigned int value, unsigned int bytes)
+static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
 {
 	while (bytes) {
 		if (*start != (u8)value)
-			return 0;
+			return start;
 		start++;
 		bytes--;
 	}
-	return 1;
+	return NULL;
+}
+
+static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
+						void *from, void *to)
+{
+	slab_fix(s, "Restoring 0x%p-0x%p=0x%x\n", from, to - 1, data);
+	memset(from, data, to - from);
+}
+
+static int check_bytes_and_report(struct kmem_cache *s, struct page *page,
+			u8 *object, char *what,
+			u8* start, unsigned int value, unsigned int bytes)
+{
+	u8 *fault;
+	u8 *end;
+
+	fault = check_bytes(start, value, bytes);
+	if (!fault)
+		return 1;
+
+	end = start + bytes;
+	while (end > fault && end[-1] == value)
+		end--;
+
+	slab_bug(s, "%s overwritten", what);
+	printk(KERN_ERR "INFO: 0x%p-0x%p. First byte 0x%x instead of 0x%x\n",
+					fault, end - 1, fault[0], value);
+	print_trailer(s, page, object);
+
+	restore_bytes(s, what, value, fault, end);
+	return 0;
 }
 
 /*
@@ -541,14 +614,6 @@ static int check_bytes(u8 *start, unsign
  * may be used with merged slabcaches.
  */
 
-static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
-						void *from, void *to)
-{
-	printk(KERN_ERR "@@@ SLUB %s: Restoring %s (0x%x) from 0x%p-0x%p\n",
-		s->name, message, data, from, to - 1);
-	memset(from, data, to - from);
-}
-
 static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
 {
 	unsigned long off = s->inuse;	/* The end of info */
@@ -564,39 +629,39 @@ static int check_pad_bytes(struct kmem_c
 	if (s->size == off)
 		return 1;
 
-	if (check_bytes(p + off, POISON_INUSE, s->size - off))
-		return 1;
-
-	object_err(s, page, p, "Object padding check fails");
-
-	/*
-	 * Restore padding
-	 */
-	restore_bytes(s, "object padding", POISON_INUSE, p + off, p + s->size);
-	return 0;
+	return check_bytes_and_report(s, page, p, "Object padding",
+				p + off, POISON_INUSE, s->size - off);
 }
 
 static int slab_pad_check(struct kmem_cache *s, struct page *page)
 {
-	u8 *p;
-	int length, remainder;
+	u8 *start;
+	u8 *fault;
+	u8 *end;
+	int length;
+	int remainder;
 
 	if (!(s->flags & SLAB_POISON))
 		return 1;
 
-	p = page_address(page);
+	start = page_address(page);
+	end = start + (PAGE_SIZE << s->order);
 	length = s->objects * s->size;
-	remainder = (PAGE_SIZE << s->order) - length;
+	remainder = end - (start + length);
 	if (!remainder)
 		return 1;
 
-	if (!check_bytes(p + length, POISON_INUSE, remainder)) {
-		slab_err(s, page, "Padding check failed");
-		restore_bytes(s, "slab padding", POISON_INUSE, p + length,
-			p + length + remainder);
-		return 0;
-	}
-	return 1;
+	fault = check_bytes(start + length, POISON_INUSE, remainder);
+	if (!fault)
+		return 1;
+	while (end > fault && end[-1] == POISON_INUSE)
+		end--;
+
+	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
+	print_section("Padding", start, length);
+
+	restore_bytes(s, "slab padding", POISON_INUSE, start, end);
+	return 0;
 }
 
 static int check_object(struct kmem_cache *s, struct page *page,
@@ -609,41 +674,22 @@ static int check_object(struct kmem_cach
 		unsigned int red =
 			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE;
 
-		if (!check_bytes(endobject, red, s->inuse - s->objsize)) {
-			object_err(s, page, object,
-			active ? "Redzone Active" : "Redzone Inactive");
-			restore_bytes(s, "redzone", red,
-				endobject, object + s->inuse);
+		if (!check_bytes_and_report(s, page, object, "Redzone",
+			endobject, red, s->inuse - s->objsize))
 			return 0;
-		}
 	} else {
-		if ((s->flags & SLAB_POISON) && s->objsize < s->inuse &&
-			!check_bytes(endobject, POISON_INUSE,
-					s->inuse - s->objsize)) {
-		object_err(s, page, p, "Alignment padding check fails");
-		/*
-		 * Fix it so that there will not be another report.
-		 *
-		 * Hmmm... We may be corrupting an object that now expects
-		 * to be longer than allowed.
-		 */
-		restore_bytes(s, "alignment padding", POISON_INUSE,
-			endobject, object + s->inuse);
-		}
+		if ((s->flags & SLAB_POISON) && s->objsize < s->inuse)
+			check_bytes_and_report(s, page, p, "Alignment padding", endobject,
+				POISON_INUSE, s->inuse - s->objsize);
 	}
 
 	if (s->flags & SLAB_POISON) {
 		if (!active && (s->flags & __OBJECT_POISON) &&
-			(!check_bytes(p, POISON_FREE, s->objsize - 1) ||
-				p[s->objsize - 1] != POISON_END)) {
-
-			object_err(s, page, p, "Poison check failed");
-			restore_bytes(s, "Poison", POISON_FREE,
-						p, p + s->objsize -1);
-			restore_bytes(s, "Poison", POISON_END,
-					p + s->objsize - 1, p + s->objsize);
+			(!check_bytes_and_report(s, page, p, "Poison", p,
+					POISON_FREE, s->objsize - 1) ||
+			 !check_bytes_and_report(s, page, p, "Poison",
+			 	p + s->objsize -1, POISON_END, 1)))
 			return 0;
-		}
 		/*
 		 * check_pad_bytes cleans up on its own.
 		 */
@@ -676,25 +722,17 @@ static int check_slab(struct kmem_cache 
 	VM_BUG_ON(!irqs_disabled());
 
 	if (!PageSlab(page)) {
-		slab_err(s, page, "Not a valid slab page flags=%lx "
-			"mapping=0x%p count=%d", page->flags, page->mapping,
-			page_count(page));
+		slab_err(s, page, "Not a valid slab page");
 		return 0;
 	}
 	if (page->offset * sizeof(void *) != s->offset) {
-		slab_err(s, page, "Corrupted offset %lu flags=0x%lx "
-			"mapping=0x%p count=%d",
-			(unsigned long)(page->offset * sizeof(void *)),
-			page->flags,
-			page->mapping,
-			page_count(page));
+		slab_err(s, page, "Corrupted offset %lu",
+			(unsigned long)(page->offset * sizeof(void *)));
 		return 0;
 	}
 	if (page->inuse > s->objects) {
-		slab_err(s, page, "inuse %u > max %u @0x%p flags=%lx "
-			"mapping=0x%p count=%d",
-			s->name, page->inuse, s->objects, page->flags,
-			page->mapping, page_count(page));
+		slab_err(s, page, "inuse %u > max %u",
+			s->name, page->inuse, s->objects);
 		return 0;
 	}
 	/* Slab_pad_check fixes things up after itself */
@@ -722,13 +760,10 @@ static int on_freelist(struct kmem_cache
 				set_freepointer(s, object, NULL);
 				break;
 			} else {
-				slab_err(s, page, "Freepointer 0x%p corrupt",
-									fp);
+				slab_err(s, page, "Freepointer corrupt");
 				page->freelist = NULL;
 				page->inuse = s->objects;
-				printk(KERN_ERR "@@@ SLUB %s: Freelist "
-					"cleared. Slab 0x%p\n",
-					s->name, page);
+				slab_fix(s, "Freelist cleared");
 				return 0;
 			}
 			break;
@@ -740,11 +775,9 @@ static int on_freelist(struct kmem_cache
 
 	if (page->inuse != s->objects - nr) {
 		slab_err(s, page, "Wrong object count. Counter is %d but "
-			"counted were %d", s, page, page->inuse,
-							s->objects - nr);
+			"counted were %d", page->inuse, s->objects - nr);
 		page->inuse = s->objects - nr;
-		printk(KERN_ERR "@@@ SLUB %s: Object count adjusted. "
-			"Slab @0x%p\n", s->name, page);
+		slab_fix(s, "Object count adjusted.");
 	}
 	return search == NULL;
 }
@@ -806,7 +839,7 @@ static int alloc_debug_processing(struct
 		goto bad;
 
 	if (object && !on_freelist(s, page, object)) {
-		slab_err(s, page, "Object 0x%p already allocated", object);
+		object_err(s, page, object, "Object already allocated");
 		goto bad;
 	}
 
@@ -832,8 +865,7 @@ bad:
 		 * to avoid issues in the future. Marking all objects
 		 * as used avoids touching the remaining objects.
 		 */
-		printk(KERN_ERR "@@@ SLUB: %s slab 0x%p. Marking all objects used.\n",
-			s->name, page);
+		slab_fix(s, "Marking all objects used");
 		page->inuse = s->objects;
 		page->freelist = NULL;
 		/* Fix up fields that may be corrupted */
@@ -854,7 +886,7 @@ static int free_debug_processing(struct 
 	}
 
 	if (on_freelist(s, page, object)) {
-		slab_err(s, page, "Object 0x%p already free", object);
+		object_err(s, page, object, "Object already free");
 		goto fail;
 	}
 
@@ -873,8 +905,8 @@ static int free_debug_processing(struct 
 			dump_stack();
 		}
 		else
-			slab_err(s, page, "object at 0x%p belongs "
-				"to slab %s", object, page->slab->name);
+			object_err(s, page, object,
+					"page slab pointer corrupt.");
 		goto fail;
 	}
 
@@ -888,8 +920,7 @@ static int free_debug_processing(struct 
 	return 1;
 
 fail:
-	printk(KERN_ERR "@@@ SLUB: %s slab 0x%p object at 0x%p not freed.\n",
-		s->name, page, object);
+	slab_fix(s, "Object at 0x%p not freed", object);
 	return 0;
 }
 
Index: slub/Documentation/vm/slub.txt
===================================================================
--- slub.orig/Documentation/vm/slub.txt	2007-05-30 12:27:00.000000000 -0700
+++ slub/Documentation/vm/slub.txt	2007-05-30 14:03:06.000000000 -0700
@@ -125,13 +125,20 @@ SLUB Debug output
 
 Here is a sample of slub debug output:
 
-*** SLUB kmalloc-8: Redzone Active@0xc90f6d20 slab 0xc528c530 offset=3360 flags=0x400000c3 inuse=61 freelist=0xc90f6d58
-  Bytes b4 0xc90f6d10:  00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
-    Object 0xc90f6d20:  31 30 31 39 2e 30 30 35                         1019.005
-   Redzone 0xc90f6d28:  00 cc cc cc                                     .
-FreePointer 0xc90f6d2c -> 0xc90f6d58
-Last alloc: get_modalias+0x61/0xf5 jiffies_ago=53 cpu=1 pid=554
-Filler 0xc90f6d50:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
+====================================================================
+BUG kmalloc-8: Redzone overwritten
+--------------------------------------------------------------------
+
+INFO: 0xc90f6d28-0xc90f6d2b. First byte 0x00 instead of 0xcc
+INFO: Slab 0xc528c530 flags=0x400000c3 inuse=61 fp=0xc90f6d58
+INFO: Object 0xc90f6d20 @offset=3360 fp=0xc90f6d58
+INFO: Allocated in get_modalias+0x61/0xf5 age=53 cpu=1 pid=554
+
+Bytes b4 0xc90f6d10:  00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
+  Object 0xc90f6d20:  31 30 31 39 2e 30 30 35                         1019.005
+ Redzone 0xc90f6d28:  00 cc cc cc                                     .
+ Padding 0xc90f6d50:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
+
   [<c010523d>] dump_trace+0x63/0x1eb
   [<c01053df>] show_trace_log_lvl+0x1a/0x2f
   [<c010601d>] show_trace+0x12/0x14
@@ -153,74 +160,108 @@ Filler 0xc90f6d50:  5a 5a 5a 5a 5a 5a 5a
   [<c0104112>] sysenter_past_esp+0x5f/0x99
   [<b7f7b410>] 0xb7f7b410
   =======================
-@@@ SLUB kmalloc-8: Restoring redzone (0xcc) from 0xc90f6d28-0xc90f6d2b
-
 
+FIX kmalloc-8: Restoring Redzone 0xc90f6d28-0xc90f6d2b=0xcc
 
-If SLUB encounters a corrupted object then it will perform the following
-actions:
+If SLUB encounters a corrupted object (full detection requires the kernel
+to be booted with slub_debug) then the following output will be dumped
+into the syslog:
 
-1. Isolation and report of the issue
+1. Description of the problem encountered
 
 This will be a message in the system log starting with
 
-*** SLUB <slab cache affected>: <What went wrong>@<object address>
-offset=<offset of object into slab> flags=<slabflags>
-inuse=<objects in use in this slab> freelist=<first free object in slab>
+===============================================
+BUG <slab cache affected>: <What went wrong>
+-----------------------------------------------
+
+INFO: <corruption start>-<corruption_end> <more info>
+INFO: Slab <address> <slab information>
+INFO: Object <address> <object information>
+INFO: Allocated in <kernel function> age=<jiffies since alloc> cpu=<allocated by
+	cpu> pid=<pid of the process>
+INFO: Freed in <kernel function> age=<jiffies since free> cpu=<freed by cpu>
+	 pid=<pid of the process>
 
-2. Report on how the problem was dealt with in order to ensure the continued
-operation of the system.
-
-These are messages in the system log beginning with
+(Object allocation / free information is only available if SLAB_STORE_USER is
+set for the slab. slub_debug sets that option)
 
-@@@ SLUB <slab cache affected>: <corrective action taken>
+2. The object contents if an object was involved.
 
-
-In the above sample SLUB found that the Redzone of an active object has
-been overwritten. Here a string of 8 characters was written into a slab that
-has the length of 8 characters. However, a 8 character string needs a
-terminating 0. That zero has overwritten the first byte of the Redzone field.
-After reporting the details of the issue encountered the @@@ SLUB message
-tell us that SLUB has restored the redzone to its proper value and then
-system operations continue.
-
-Various types of lines can follow the @@@ SLUB line:
+Various types of lines can follow the BUG SLUB line:
 
 Bytes b4 <address> : <bytes>
-	Show a few bytes before the object where the problem was detected.
+	Shows a few bytes before the object where the problem was detected.
 	Can be useful if the corruption does not stop with the start of the
 	object.
 
 Object <address> : <bytes>
 	The bytes of the object. If the object is inactive then the bytes
-	typically contain poisoning values. Any non-poison value shows a
+	typically contain poison values. Any non-poison value shows a
 	corruption by a write after free.
 
 Redzone <address> : <bytes>
-	The redzone following the object. The redzone is used to detect
+	The Redzone following the object. The Redzone is used to detect
 	writes after the object. All bytes should always have the same
 	value. If there is any deviation then it is due to a write after
 	the object boundary.
 
-Freepointer
-	The pointer to the next free object in the slab. May become
-	corrupted if overwriting continues after the red zone.
-
-Last alloc:
-Last free:
-	Shows the address from which the object was allocated/freed last.
-	We note the pid, the time and the CPU that did so. This is usually
-	the most useful information to figure out where things went wrong.
-	Here get_modalias() did an kmalloc(8) instead of a kmalloc(9).
+	(Redzone information is only available if SLAB_RED_ZONE is set.
+	slub_debug sets that option)
 
-Filler <address> : <bytes>
+Padding <address> : <bytes>
 	Unused data to fill up the space in order to get the next object
 	properly aligned. In the debug case we make sure that there are
-	at least 4 bytes of filler. This allow for the detection of writes
+	at least 4 bytes of padding. This allows the detection of writes
 	before the object.
 
-Following the filler will be a stackdump. That stackdump describes the
-location where the error was detected. The cause of the corruption is more
-likely to be found by looking at the information about the last alloc / free.
+3. A stackdump
+
+The stackdump describes the location where the error was detected. The cause
+of the corruption is may be more likely found by looking at the function that
+allocated or freed the object.
+
+4. Report on how the problem was dealt with in order to ensure the continued
+operation of the system.
+
+These are messages in the system log beginning with
+
+FIX <slab cache affected>: <corrective action taken>
+
+In the above sample SLUB found that the Redzone of an active object has
+been overwritten. Here a string of 8 characters was written into a slab that
+has the length of 8 characters. However, a 8 character string needs a
+terminating 0. That zero has overwritten the first byte of the Redzone field.
+After reporting the details of the issue encountered the FIX SLUB message
+tell us that SLUB has restored the Redzone to its proper value and then
+system operations continue.
+
+Emergency operations:
+---------------------
+
+Minimal debugging (sanity checks alone) can be enabled by booting with
+
+	slub_debug=F
+
+This will be generally be enough to enable the resiliency features of slub
+which will keep the system running even if a bad kernel component will
+keep corrupting objects. This may be important for production systems.
+Performance will be impacted by the sanity checks and there will be a
+continual stream of error messages to the syslog but no additional memory
+will be used (unlike full debugging).
+
+No guarantees. The kernel component still needs to be fixed. Performance
+may be optimized further by locating the slab that experiences corruption
+and enabling debugging only for that cache
+
+I.e.
+
+	slub_debug=F,dentry
+
+If the corruption occurs by writing after the end of the object then it
+may be advisable to enable a Redzone to avoid corrupting the beginning
+of other objects.
+
+	slub_debug=FZ,dentry
 
-Christoph Lameter, <clameter@sgi.com>, May 23, 2007
+Christoph Lameter, <clameter@sgi.com>, May 30, 2007

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
