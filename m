Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8F36D6B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 13:33:53 -0400 (EDT)
Date: Sun, 28 Jun 2009 20:36:32 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemleak hexdump proposal
Message-ID: <20090628173632.GA3890@localdomain.by>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.
What do you think about ability to 'watch' leaked region? (hex + ascii).
(done via lib/hexdump.c)

To turn on hex dump:
echo "hexdump=on" > /sys/kernel/debug/kmemleak

/**
Or (as alternative):
echo "hexdump=f6aac7f8" > /sys/kernel/debug/kmemleak
where f6aac7f8 - object's pointer.
**/

cat /sys/kernel/debug/kmemleak

unreferenced object 0xf6aac7f8 (size 32):
  comm "swapper", pid 1, jiffies 4294877610
HEX dump:
70 6e 70 20 30 30 3a 30 61 00 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  pnp 00:0a.ZZZZZZZZZZZZZZZZZZZZZ.

  backtrace:
    [<c10e92eb>] kmemleak_alloc+0x11b/0x2b0
    [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
    [<c12c424e>] reserve_range+0x3e/0x1b0
    [<c12c4454>] system_pnp_probe+0x94/0x140
    [<c12baf84>] pnp_device_probe+0x84/0x100
    [<c12f1919>] driver_probe_device+0x89/0x170
    [<c12f1a99>] __driver_attach+0x99/0xa0
    [<c12f1028>] bus_for_each_dev+0x58/0x90
    [<c12f1764>] driver_attach+0x24/0x40
    [<c12f0804>] bus_add_driver+0xc4/0x290
    [<c12f1e10>] driver_register+0x70/0x130
    [<c12bacd6>] pnp_register_driver+0x26/0x40
    [<c15d4620>] pnp_system_init+0x1b/0x2e
    [<c100115f>] do_one_initcall+0x3f/0x1a0
    [<c15aa4af>] kernel_init+0x13e/0x1a6
    [<c1003e07>] kernel_thread_helper+0x7/0x10
unreferenced object 0xf63f4d18 (size 192):
  comm "swapper", pid 1, jiffies 4294878292
HEX dump:
3c 06 00 00 00 00 00 00 78 69 00 00 00 00 00 00 0a 00 00 00 00 00 00 00 0a 00 00 00 00 00 00 00  <.......xi......................
25 0c 00 00 00 00 00 00 25 0c 00 00 00 00 00 00 32 05 00 00 00 00 00 00 60 54 00 00 00 00 00 00  %.......%.......2.......`T......
0a 00 00 00 00 00 00 00 0a 00 00 00 00 00 00 00 1f 0a 00 00 00 00 00 00 1f 0a 00 00 00 00 00 00  ................................
28 04 00 00 00 00 00 00 48 3f 00 00 00 00 00 00 0a 00 00 00 00 00 00 00 0a 00 00 00 00 00 00 00  (.......H?......................
19 08 00 00 00 00 00 00 19 08 00 00 00 00 00 00 1e 03 00 00 00 00 00 00 30 2a 00 00 00 00 00 00  ........................0*......
0a 00 00 00 00 00 00 00 0a 00 00 00 00 00 00 00 13 06 00 00 00 00 00 00 13 06 00 00 00 00 00 00  ................................

  backtrace:
    [<c10e92eb>] kmemleak_alloc+0x11b/0x2b0
    [<c10e584d>] __kmalloc+0x16d/0x210
    [<c12b5757>] acpi_processor_register_performance+0x28e/0x468
    [<c1016797>] acpi_cpufreq_cpu_init+0x97/0x560
    [<c134d802>] cpufreq_add_dev+0x122/0x580
    [<c12efd47>] sysdev_driver_register+0xa7/0x140
    [<c134ca4e>] cpufreq_register_driver+0x9e/0x170
    [<c15b4e0f>] acpi_cpufreq_init+0x8b/0xcd
    [<c100115f>] do_one_initcall+0x3f/0x1a0
    [<c15aa4af>] kernel_init+0x13e/0x1a6
    [<c1003e07>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

To disable hex dump:
echo "hexdump=off" > /sys/kernel/debug/kmemleak

I guess it could safe someone's time.
(May be, showed examples aren't so good. Just to demonstrate the idea.)

(concept. feel free to ask for comments.)

diff -u -p

--- kmemleak.c	2009-06-28 20:18:59.000000000 +0300
+++ linux-2.6-sergey/mm/kmemleak.c	2009-06-28 20:21:29.000000000 +0300
@@ -160,6 +160,13 @@ struct kmemleak_object {
 /* flag set to not scan the object */
 #define OBJECT_NO_SCAN		(1 << 2)
 
+/* number of bytes to print per line; must be 16 or 32 */
+#define HEX_ROW_SIZE 32
+/* number of bytes to print at a time (1, 2, 4, 8) */
+#define HEX_GROUP_SIZE 1
+/* include ASCII after the hex output */ 
+#define HEX_ASCII 1
+
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
@@ -182,6 +189,9 @@ static atomic_t kmemleak_early_log = ATO
 /* set if a fata kmemleak error has occurred */
 static atomic_t kmemleak_error = ATOMIC_INIT(0);
 
+/* set if HEX dump should be printed */
+static atomic_t kmemleak_hex_dump = ATOMIC_INIT(0);
+
 /* minimum and maximum address that may be valid pointers */
 static unsigned long min_addr = ULONG_MAX;
 static unsigned long max_addr;
@@ -290,6 +300,29 @@ static int unreferenced_object(struct km
 			       jiffies_last_scan);
 }
 
+
+static void object_hex_dump(struct seq_file *seq, struct kmemleak_object *object)
+{
+	const u8 *ptr = (const u8*)object->pointer;
+	int len = object->size;
+	int i, linelen, remaining = object->size;
+	unsigned char linebuf[200];
+	
+	seq_printf(seq, "HEX dump:\n");
+	
+	for (i = 0; i < len; i += HEX_ROW_SIZE) {
+		linelen = min(remaining, HEX_ROW_SIZE);
+		remaining -= HEX_ROW_SIZE;
+		hex_dump_to_buffer(ptr + i, linelen, HEX_ROW_SIZE, HEX_GROUP_SIZE,
+				linebuf, sizeof(linebuf), HEX_ASCII);
+
+		seq_printf(seq, "%s\n", linebuf);	
+	}
+	
+	seq_printf(seq, "\n");
+}
+
+
 /*
  * Printing of the unreferenced objects information to the seq file. The
  * print_unreferenced function must be called with the object->lock held.
@@ -301,10 +334,17 @@ static void print_unreferenced(struct se
 
 	seq_printf(seq, "unreferenced object 0x%08lx (size %zu):\n",
 		   object->pointer, object->size);
+
 	seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
 		   object->comm, object->pid, object->jiffies);
-	seq_printf(seq, "  backtrace:\n");
 
+	/* check whether hex dump should be printed*/
+	if (atomic_read(&kmemleak_hex_dump))
+		object_hex_dump(seq, object);
+	
+	
+	seq_printf(seq, "  backtrace:\n");
+	
 	for (i = 0; i < object->trace_len; i++) {
 		void *ptr = (void *)object->trace[i];
 		seq_printf(seq, "    [<%p>] %pS\n", ptr, ptr);
@@ -1269,6 +1309,12 @@ static ssize_t kmemleak_write(struct fil
 		start_scan_thread();
 	else if (strncmp(buf, "scan=off", 8) == 0)
 		stop_scan_thread();
+	else if (strncmp(buf, "hexdump=on", 10) == 0) {
+		atomic_set(&kmemleak_hex_dump, 1);
+	}
+	else if (strncmp(buf, "hexdump=off", 11) == 0) {
+		atomic_set(&kmemleak_hex_dump, 0);
+	}
 	else if (strncmp(buf, "scan=", 5) == 0) {
 		unsigned long secs;
 		int err;


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
