Date: Sat, 18 Oct 2003 10:50:54 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test7-mm1
Message-Id: <20031018105054.1f9a7f3e.akpm@osdl.org>
In-Reply-To: <200310181943.39148.schlicht@uni-mannheim.de>
References: <20031015013649.4aebc910.akpm@osdl.org>
	<200310181943.39148.schlicht@uni-mannheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Schlichter <schlicht@uni-mannheim.de> wrote:
>
> >  Scale min_free_kbytes according to machine size.
> 
>  This patch actually doesn't work, as is uses nr_free_buffer_pages() before the 
>  zonelists are set up. So min_free_kbytes is always set to 128.

Yup.  I turned it into an initcall.

 include/linux/mmzone.h |    2 --
 init/main.c            |    1 -
 mm/page_alloc.c        |   41 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 40 insertions(+), 4 deletions(-)

diff -puN include/linux/mmzone.h~scale-min_free_kbytes include/linux/mmzone.h
--- 25/include/linux/mmzone.h~scale-min_free_kbytes	2003-10-17 17:52:50.000000000 -0700
+++ 25-akpm/include/linux/mmzone.h	2003-10-17 21:46:55.000000000 -0700
@@ -284,8 +284,6 @@ struct ctl_table;
 struct file;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int, struct file *, 
 					  void *, size_t *);
-extern void setup_per_zone_pages_min(void);
-
 
 #ifdef CONFIG_NUMA
 #define MAX_NR_MEMBLKS	BITS_PER_LONG /* Max number of Memory Blocks */
diff -puN init/main.c~scale-min_free_kbytes init/main.c
--- 25/init/main.c~scale-min_free_kbytes	2003-10-17 17:52:50.000000000 -0700
+++ 25-akpm/init/main.c	2003-10-17 21:47:04.000000000 -0700
@@ -396,7 +396,6 @@ asmlinkage void __init start_kernel(void
 	lock_kernel();
 	printk(linux_banner);
 	setup_arch(&command_line);
-	setup_per_zone_pages_min();
 	setup_per_cpu_areas();
 
 	/*
diff -puN mm/page_alloc.c~scale-min_free_kbytes mm/page_alloc.c
--- 25/mm/page_alloc.c~scale-min_free_kbytes	2003-10-17 17:52:50.000000000 -0700
+++ 25-akpm/mm/page_alloc.c	2003-10-17 21:48:31.000000000 -0700
@@ -1589,7 +1589,7 @@ void __init page_alloc_init(void)
  *	that the pages_{min,low,high} values for each zone are set correctly 
  *	with respect to min_free_kbytes.
  */
-void setup_per_zone_pages_min(void)
+static void setup_per_zone_pages_min(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -1633,6 +1633,45 @@ void setup_per_zone_pages_min(void)
 }
 
 /*
+ * Initialise min_free_kbytes.
+ *
+ * For small machines we want it small (128k min).  For large machines
+ * we want it large (16MB max).  But it is not linear, because network
+ * bandwidth does not increase linearly with machine size.  We use
+ *
+ *	min_free_kbytes = sqrt(lowmem_kbytes)
+ *
+ * which yields
+ *
+ * 16MB:	128k
+ * 32MB:	181k
+ * 64MB:	256k
+ * 128MB:	362k
+ * 256MB:	512k
+ * 512MB:	724k
+ * 1024MB:	1024k
+ * 2048MB:	1448k
+ * 4096MB:	2048k
+ * 8192MB:	2896k
+ * 16384MB:	4096k
+ */
+static int __init init_per_zone_pages_min(void)
+{
+	unsigned long lowmem_kbytes;
+
+	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
+
+	min_free_kbytes = int_sqrt(lowmem_kbytes);
+	if (min_free_kbytes < 128)
+		min_free_kbytes = 128;
+	if (min_free_kbytes > 16384)
+		min_free_kbytes = 16384;
+	setup_per_zone_pages_min();
+	return 0;
+}
+module_init(init_per_zone_pages_min)
+
+/*
  * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
  *	that we can call setup_per_zone_pages_min() whenever min_free_kbytes 
  *	changes.

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
