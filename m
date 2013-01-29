Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id AA26E6B0005
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 17:14:47 -0500 (EST)
Message-ID: <1359497685.16868.11.camel@joe-AO722>
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
From: Joe Perches <joe@perches.com>
Date: Tue, 29 Jan 2013 14:14:45 -0800
In-Reply-To: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
> The code required for the flushing is in a separate patch now
> as requested.

What tree does this apply to?
Both -next and linus fail to compile.

There's a whitespace error applying 3/7 (line 543 in zswap.c)
and on 3.8-rc5 (allyesconfig x86-32):

  CC      mm/zswap.o
mm/zswap.c:407:15: error: variable a??zswap_zs_opsa?? has initializer but incomplete type
mm/zswap.c:408:2: error: unknown field a??alloca?? specified in initializer
mm/zswap.c:408:2: warning: excess elements in struct initializer [enabled by default]
mm/zswap.c:408:2: warning: (near initialization for a??zswap_zs_opsa??) [enabled by default]
mm/zswap.c:409:2: error: unknown field a??freea?? specified in initializer
mm/zswap.c:410:1: warning: excess elements in struct initializer [enabled by default]
mm/zswap.c:410:1: warning: (near initialization for a??zswap_zs_opsa??) [enabled by default]
mm/zswap.c: In function a??zswap_frontswap_storea??:
mm/zswap.c:723:4: error: too many arguments to function a??zs_malloca??
In file included from mm/zswap.c:35:0:
include/linux/zsmalloc.h:34:15: note: declared here
mm/zswap.c:748:5: error: too many arguments to function a??zs_malloca??
In file included from mm/zswap.c:35:0:
include/linux/zsmalloc.h:34:15: note: declared here
mm/zswap.c: In function a??zswap_frontswap_inita??:
mm/zswap.c:940:2: warning: passing argument 2 of a??zs_create_poola?? makes integer from pointer without a cast [enabled by default]
In file included from mm/zswap.c:35:0:
include/linux/zsmalloc.h:31:17: note: expected a??gfp_ta?? but argument is of type a??struct zs_ops *a??
make[1]: *** [mm/zswap.o] Error 1
make: *** [mm/zswap.o] Error 2

I also suggest this patch to use a more
current logging style via pr_fmt and
removing embedded "zswap: " prefixes from
logging output formats.

---
 mm/zswap.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index b8e5673..1e21f46 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1,5 +1,5 @@
 /*
- * zswap-drv.c - zswap driver file
+ * zswap.c - zswap driver file
  *
  * zswap is a backend for frontswap that takes pages that are in the
  * process of being swapped out and attempts to compress them and store
@@ -20,6 +20,8 @@
  * GNU General Public License for more details.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/cpu.h>
 #include <linux/highmem.h>
@@ -137,15 +139,14 @@ static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int slen,
 static int __init zswap_comp_init(void)
 {
 	if (!crypto_has_comp(zswap_compressor, 0, 0)) {
-		pr_info("zswap: %s compressor not available\n",
-			zswap_compressor);
+		pr_info("%s compressor not available\n", zswap_compressor);
 		/* fall back to default compressor */
 		zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
 		if (!crypto_has_comp(zswap_compressor, 0, 0))
 			/* can't even load the default compressor */
 			return -ENODEV;
 	}
-	pr_info("zswap: using %s compressor\n", zswap_compressor);
+	pr_info("using %s compressor\n", zswap_compressor);
 
 	/* alloc percpu transforms */
 	zswap_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
@@ -296,13 +297,13 @@ static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
 	case CPU_UP_PREPARE:
 		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
 		if (IS_ERR(tfm)) {
-			pr_err("zswap: can't allocate compressor transform\n");
+			pr_err("can't allocate compressor transform\n");
 			return NOTIFY_BAD;
 		}
 		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
 		dst = (u8 *)__get_free_pages(GFP_KERNEL, 1);
 		if (!dst) {
-			pr_err("zswap: can't allocate compressor buffer\n");
+			pr_err("can't allocate compressor buffer\n");
 			crypto_free_comp(tfm);
 			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
 			return NOTIFY_BAD;
@@ -949,7 +950,7 @@ static void zswap_frontswap_init(unsigned type)
 freetree:
 	kfree(tree);
 err:
-	pr_err("zswap: alloc failed, zswap disabled for swap type %d\n", type);
+	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
 }
 
 static struct frontswap_ops zswap_frontswap_ops = {
@@ -1031,28 +1032,28 @@ static int __init init_zswap(void)
 
 	pr_info("loading zswap\n");
 	if (zswap_entry_cache_create()) {
-		pr_err("zswap: entry cache creation failed\n");
+		pr_err("entry cache creation failed\n");
 		goto error;
 	}
 	if (zswap_page_pool_create()) {
-		pr_err("zswap: page pool initialization failed\n");
+		pr_err("page pool initialization failed\n");
 		goto pagepoolfail;
 	}
 	if (zswap_tmppage_pool_create()) {
-		pr_err("zswap: workmem pool initialization failed\n");
+		pr_err("workmem pool initialization failed\n");
 		goto tmppoolfail;
 	}
 	if (zswap_comp_init()) {
-		pr_err("zswap: compressor initialization failed\n");
+		pr_err("compressor initialization failed\n");
 		goto compfail;
 	}
 	if (zswap_cpu_init()) {
-		pr_err("zswap: per-cpu initialization failed\n");
+		pr_err("per-cpu initialization failed\n");
 		goto pcpufail;
 	}
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
-		pr_warn("zswap: debugfs initialization failed\n");
+		pr_warn("debugfs initialization failed\n");
 	return 0;
 pcpufail:
 	zswap_comp_exit();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
