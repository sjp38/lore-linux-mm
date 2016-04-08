Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3F39D6B0253
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 14:04:31 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fe3so78747908pab.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 11:04:31 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id 5si1957959pfq.158.2016.04.08.11.04.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 11:04:29 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id td3so78753375pab.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 11:04:29 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v2] mm: SLAB freelist randomization
Date: Fri,  8 Apr 2016 11:03:22 -0700
Message-Id: <1460138602-85386-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: gthelen@google.com, keescook@chromium.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@fedoraproject.org, Thomas Garnier <thgarnie@google.com>

Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
SLAB freelist. The list is randomized during initialization of a new set
of pages. The order on different freelist sizes is pre-computed at boot
for performance. This security feature reduces the predictability of the
kernel SLAB allocator against heap overflows rendering attacks much less
stable.

For example this attack against SLUB (also applicable against SLAB)
would be affected:
https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/

The config option name is not specific to the SLAB as this approach will
be extended to other allocators like SLUB.

Performance results highlighted no major changes:

Netperf average on 10 runs:

threads,base,change
16,576943.10,585905.90 (101.55%)
32,564082.00,569741.20 (101.00%)
48,558334.30,561851.20 (100.63%)
64,552025.20,556448.30 (100.80%)
80,552294.40,551743.10 (99.90%)
96,552435.30,547529.20 (99.11%)
112,551320.60,550183.20 (99.79%)
128,549138.30,550542.70 (100.26%)
144,549344.50,544529.10 (99.12%)
160,550360.80,539929.30 (98.10%)

slab_test 1 run on boot. After is faster except for odd result on size
2048.

Before:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 137 cycles kfree -> 126 cycles
10000 times kmalloc(16) -> 118 cycles kfree -> 119 cycles
10000 times kmalloc(32) -> 112 cycles kfree -> 119 cycles
10000 times kmalloc(64) -> 126 cycles kfree -> 123 cycles
10000 times kmalloc(128) -> 135 cycles kfree -> 131 cycles
10000 times kmalloc(256) -> 165 cycles kfree -> 104 cycles
10000 times kmalloc(512) -> 174 cycles kfree -> 126 cycles
10000 times kmalloc(1024) -> 242 cycles kfree -> 160 cycles
10000 times kmalloc(2048) -> 478 cycles kfree -> 239 cycles
10000 times kmalloc(4096) -> 747 cycles kfree -> 364 cycles
10000 times kmalloc(8192) -> 774 cycles kfree -> 404 cycles
10000 times kmalloc(16384) -> 849 cycles kfree -> 430 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 118 cycles
10000 times kmalloc(16)/kfree -> 118 cycles
10000 times kmalloc(32)/kfree -> 118 cycles
10000 times kmalloc(64)/kfree -> 121 cycles
10000 times kmalloc(128)/kfree -> 118 cycles
10000 times kmalloc(256)/kfree -> 115 cycles
10000 times kmalloc(512)/kfree -> 115 cycles
10000 times kmalloc(1024)/kfree -> 115 cycles
10000 times kmalloc(2048)/kfree -> 115 cycles
10000 times kmalloc(4096)/kfree -> 115 cycles
10000 times kmalloc(8192)/kfree -> 115 cycles
10000 times kmalloc(16384)/kfree -> 115 cycles

After:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 99 cycles kfree -> 84 cycles
10000 times kmalloc(16) -> 88 cycles kfree -> 83 cycles
10000 times kmalloc(32) -> 90 cycles kfree -> 81 cycles
10000 times kmalloc(64) -> 107 cycles kfree -> 97 cycles
10000 times kmalloc(128) -> 134 cycles kfree -> 89 cycles
10000 times kmalloc(256) -> 145 cycles kfree -> 97 cycles
10000 times kmalloc(512) -> 177 cycles kfree -> 116 cycles
10000 times kmalloc(1024) -> 223 cycles kfree -> 151 cycles
10000 times kmalloc(2048) -> 1429 cycles kfree -> 221 cycles
10000 times kmalloc(4096) -> 720 cycles kfree -> 348 cycles
10000 times kmalloc(8192) -> 788 cycles kfree -> 393 cycles
10000 times kmalloc(16384) -> 867 cycles kfree -> 433 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 115 cycles
10000 times kmalloc(16)/kfree -> 115 cycles
10000 times kmalloc(32)/kfree -> 115 cycles
10000 times kmalloc(64)/kfree -> 120 cycles
10000 times kmalloc(128)/kfree -> 127 cycles
10000 times kmalloc(256)/kfree -> 119 cycles
10000 times kmalloc(512)/kfree -> 112 cycles
10000 times kmalloc(1024)/kfree -> 112 cycles
10000 times kmalloc(2048)/kfree -> 112 cycles
10000 times kmalloc(4096)/kfree -> 112 cycles
10000 times kmalloc(8192)/kfree -> 112 cycles
10000 times kmalloc(16384)/kfree -> 112 cycles

slab_bulk results (look about the same)

Before:

DEBUG: cpu:10
Type:for_loop Per elem: 1 cycles(tsc) 0.318 ns (step:0) - (measurement
period time:0.031823553 sec time_interval:31823553) - (invoke
count:100000000 tsc_interval:111112332)
Type:kmem fastpath reuse Per elem: 104 cycles(tsc) 29.808 ns (step:0)
- (measurement period time:0.298081100 sec time_interval:298081100)
- (invoke count:10000000 tsc_interval:1040760500)
Type:kmem bulk_fallback Per elem: 125 cycles(tsc) 35.872 ns (step:1)
- (measurement period time:0.358726418 sec time_interval:358726418)
- (invoke count:10000000 tsc_interval:1252505764)
Type:kmem bulk_quick_reuse Per elem: 55 cycles(tsc) 15.850 ns (step:1)
- (measurement period time:0.158508913 sec time_interval:158508913)
- (invoke count:10000000 tsc_interval:553439128)
Type:kmem bulk_fallback Per elem: 112 cycles(tsc) 32.326 ns (step:2)
- (measurement period time:0.323265281 sec time_interval:323265281)
- (invoke count:10000000 tsc_interval:1128692072)
Type:kmem bulk_quick_reuse Per elem: 34 cycles(tsc) 9.867 ns (step:2)
- (measurement period time:0.098670493 sec time_interval:98670493)
- (invoke count:10000000 tsc_interval:344510914)
Type:kmem bulk_fallback Per elem: 107 cycles(tsc) 30.907 ns (step:3)
- (measurement period time:0.309076362 sec time_interval:309076362)
- (invoke count:9999999 tsc_interval:1079150859)
Type:kmem bulk_quick_reuse Per elem: 28 cycles(tsc) 8.045 ns (step:3)
- (measurement period time:0.080459150 sec time_interval:80459150)
- (invoke count:9999999 tsc_interval:280925570)
Type:kmem bulk_fallback Per elem: 105 cycles(tsc) 30.156 ns (step:4)
- (measurement period time:0.301569211 sec time_interval:301569211)
- (invoke count:10000000 tsc_interval:1052939565)
Type:kmem bulk_quick_reuse Per elem: 25 cycles(tsc) 7.368 ns (step:4)
- (measurement period time:0.073680499 sec time_interval:73680499)
- (invoke count:10000000 tsc_interval:257257775)
Type:kmem bulk_fallback Per elem: 103 cycles(tsc) 29.717 ns (step:8)
- (measurement period time:0.297170419 sec time_interval:297170419)
- (invoke count:10000000 tsc_interval:1037580931)
Type:kmem bulk_quick_reuse Per elem: 22 cycles(tsc) 6.446 ns (step:8)
- (measurement period time:0.064465569 sec time_interval:64465569)
- (invoke count:10000000 tsc_interval:225083219)
Type:kmem bulk_fallback Per elem: 102 cycles(tsc) 29.435 ns (step:16)
- (measurement period time:0.294353584 sec time_interval:294353584)
- (invoke count:10000000 tsc_interval:1027745957)
Type:kmem bulk_quick_reuse Per elem: 21 cycles(tsc) 6.052 ns (step:16)
- (measurement period time:0.060526862 sec time_interval:60526862)
- (invoke count:10000000 tsc_interval:211331314)
Type:kmem bulk_fallback Per elem: 127 cycles(tsc) 36.440 ns (step:30)
- (measurement period time:0.364403518 sec time_interval:364403518)
- (invoke count:9999990 tsc_interval:1272325901)
Type:kmem bulk_quick_reuse Per elem: 32 cycles(tsc) 9.213 ns (step:30)
- (measurement period time:0.092130623 sec time_interval:92130623)
- (invoke count:9999990 tsc_interval:321676961)
Type:kmem bulk_fallback Per elem: 129 cycles(tsc) 36.985 ns (step:32)
- (measurement period time:0.369859273 sec time_interval:369859273)
- (invoke count:10000000 tsc_interval:1291376818)
Type:kmem bulk_quick_reuse Per elem: 31 cycles(tsc) 9.083 ns (step:32)
- (measurement period time:0.090834101 sec time_interval:90834101)
- (invoke count:10000000 tsc_interval:317150093)
Type:kmem bulk_fallback Per elem: 129 cycles(tsc) 37.057 ns (step:34)
- (measurement period time:0.370577150 sec time_interval:370577150)
- (invoke count:9999978 tsc_interval:1293883110)
Type:kmem bulk_quick_reuse Per elem: 32 cycles(tsc) 9.182 ns (step:34)
- (measurement period time:0.091828683 sec time_interval:91828683)
- (invoke count:9999978 tsc_interval:320622702)
Type:kmem bulk_fallback Per elem: 126 cycles(tsc) 36.244 ns (step:48)
- (measurement period time:0.362448363 sec time_interval:362448363)
- (invoke count:9999984 tsc_interval:1265501472)
Type:kmem bulk_quick_reuse Per elem: 20 cycles(tsc) 6.012 ns (step:48)
- (measurement period time:0.060121234 sec time_interval:60121234)
- (invoke count:9999984 tsc_interval:209914922)
Type:kmem bulk_fallback Per elem: 108 cycles(tsc) 31.123 ns (step:64)
- (measurement period time:0.311231972 sec time_interval:311231972)
- (invoke count:10000000 tsc_interval:1086677115)
Type:kmem bulk_quick_reuse Per elem: 20 cycles(tsc) 6.014 ns (step:64)
- (measurement period time:0.060142595 sec time_interval:60142595)
- (invoke count:10000000 tsc_interval:209989505)
Type:kmem bulk_fallback Per elem: 107 cycles(tsc) 30.676 ns (step:128)
- (measurement period time:0.306766510 sec time_interval:306766510)
- (invoke count:10000000 tsc_interval:1071085978)
Type:kmem bulk_quick_reuse Per elem: 23 cycles(tsc) 6.696 ns (step:128)
- (measurement period time:0.066960903 sec time_interval:66960903)
- (invoke count:10000000 tsc_interval:233795952)
Type:kmem bulk_fallback Per elem: 106 cycles(tsc) 30.614 ns (step:158)
- (measurement period time:0.306148249 sec time_interval:306148249)
- (invoke count:9999978 tsc_interval:1068927458)
Type:kmem bulk_quick_reuse Per elem: 24 cycles(tsc) 7.077 ns (step:158)
- (measurement period time:0.070774353 sec time_interval:70774353)
- (invoke count:9999978 tsc_interval:247110695)
Type:kmem bulk_fallback Per elem: 107 cycles(tsc) 30.914 ns (step:250)
- (measurement period time:0.309144377 sec time_interval:309144377)
- (invoke count:10000000 tsc_interval:1079388538)
Type:kmem bulk_quick_reuse Per elem: 25 cycles(tsc) 7.283 ns (step:250)
- (measurement period time:0.072836404 sec time_interval:72836404)
- (invoke count:10000000 tsc_interval:254309986)

After:

DEBUG: cpu:1
Type:for_loop Per elem: 1 cycles(tsc) 0.289 ns (step:0) - (measurement
period time:0.028953054 sec time_interval:28953054) - (invoke
count:100000000 tsc_interval:101090400)
Type:kmem fastpath reuse Per elem: 104 cycles(tsc) 29.800 ns (step:0)
- (measurement period time:0.298003253 sec time_interval:298003253)
- (invoke count:10000000 tsc_interval:1040491972)
Type:kmem bulk_fallback Per elem: 125 cycles(tsc) 35.892 ns (step:1)
- (measurement period time:0.358924780 sec time_interval:358924780)
- (invoke count:10000000 tsc_interval:1253202488)
Type:kmem bulk_quick_reuse Per elem: 55 cycles(tsc) 15.780 ns (step:1)
- (measurement period time:0.157804420 sec time_interval:157804420)
- (invoke count:10000000 tsc_interval:550981196)
Type:kmem bulk_fallback Per elem: 112 cycles(tsc) 32.220 ns (step:2)
- (measurement period time:0.322202576 sec time_interval:322202576)
- (invoke count:10000000 tsc_interval:1124985278)
Type:kmem bulk_quick_reuse Per elem: 34 cycles(tsc) 9.834 ns (step:2)
- (measurement period time:0.098344277 sec time_interval:98344277)
- (invoke count:10000000 tsc_interval:343373130)
Type:kmem bulk_fallback Per elem: 108 cycles(tsc) 30.946 ns (step:3)
- (measurement period time:0.309467507 sec time_interval:309467507)
- (invoke count:9999999 tsc_interval:1080519939)
Type:kmem bulk_quick_reuse Per elem: 28 cycles(tsc) 8.183 ns (step:3)
- (measurement period time:0.081831772 sec time_interval:81831772)
- (invoke count:9999999 tsc_interval:285718619)
Type:kmem bulk_fallback Per elem: 107 cycles(tsc) 30.832 ns (step:4)
- (measurement period time:0.308327840 sec time_interval:308327840)
- (invoke count:10000000 tsc_interval:1076540739)
Type:kmem bulk_quick_reuse Per elem: 26 cycles(tsc) 7.512 ns (step:4)
- (measurement period time:0.075123119 sec time_interval:75123119)
- (invoke count:10000000 tsc_interval:262295498)
Type:kmem bulk_fallback Per elem: 105 cycles(tsc) 30.291 ns (step:8)
- (measurement period time:0.302919692 sec time_interval:302919692)
- (invoke count:10000000 tsc_interval:1057657960)
Type:kmem bulk_quick_reuse Per elem: 22 cycles(tsc) 6.578 ns (step:8)
- (measurement period time:0.065788230 sec time_interval:65788230)
- (invoke count:10000000 tsc_interval:229700901)
Type:kmem bulk_fallback Per elem: 104 cycles(tsc) 29.805 ns (step:16)
- (measurement period time:0.298055380 sec time_interval:298055380)
- (invoke count:10000000 tsc_interval:1040674120)
Type:kmem bulk_quick_reuse Per elem: 21 cycles(tsc) 6.144 ns (step:16)
- (measurement period time:0.061447185 sec time_interval:61447185)
- (invoke count:10000000 tsc_interval:214545335)
Type:kmem bulk_fallback Per elem: 104 cycles(tsc) 29.837 ns (step:30)
- (measurement period time:0.298372940 sec time_interval:298372940)
- (invoke count:9999990 tsc_interval:1041782971)
Type:kmem bulk_quick_reuse Per elem: 21 cycles(tsc) 6.031 ns (step:30)
- (measurement period time:0.060319478 sec time_interval:60319478)
- (invoke count:9999990 tsc_interval:210607930)
Type:kmem bulk_fallback Per elem: 104 cycles(tsc) 29.967 ns (step:32)
- (measurement period time:0.299670182 sec time_interval:299670182)
- (invoke count:10000000 tsc_interval:1046312308)
Type:kmem bulk_quick_reuse Per elem: 21 cycles(tsc) 6.027 ns (step:32)
- (measurement period time:0.060277128 sec time_interval:60277128)
- (invoke count:10000000 tsc_interval:210460013)
Type:kmem bulk_fallback Per elem: 104 cycles(tsc) 29.989 ns (step:34)
- (measurement period time:0.299891491 sec time_interval:299891491)
- (invoke count:9999978 tsc_interval:1047083288)
Type:kmem bulk_quick_reuse Per elem: 20 cycles(tsc) 5.954 ns (step:34)
- (measurement period time:0.059547431 sec time_interval:59547431)
- (invoke count:9999978 tsc_interval:207912186)
Type:kmem bulk_fallback Per elem: 103 cycles(tsc) 29.767 ns (step:48)
- (measurement period time:0.297677464 sec time_interval:297677464)
- (invoke count:9999984 tsc_interval:1039354626)
Type:kmem bulk_quick_reuse Per elem: 20 cycles(tsc) 6.001 ns (step:48)
- (measurement period time:0.060014156 sec time_interval:60014156)
- (invoke count:9999984 tsc_interval:209541572)
Type:kmem bulk_fallback Per elem: 104 cycles(tsc) 29.879 ns (step:64)
- (measurement period time:0.298799724 sec time_interval:298799724)
- (invoke count:10000000 tsc_interval:1043273056)
Type:kmem bulk_quick_reuse Per elem: 20 cycles(tsc) 5.917 ns (step:64)
- (measurement period time:0.059172278 sec time_interval:59172278)
- (invoke count:10000000 tsc_interval:206602418)
Type:kmem bulk_fallback Per elem: 105 cycles(tsc) 30.261 ns (step:128)
- (measurement period time:0.302610710 sec time_interval:302610710)
- (invoke count:10000000 tsc_interval:1056579291)
Type:kmem bulk_quick_reuse Per elem: 22 cycles(tsc) 6.431 ns (step:128)
- (measurement period time:0.064314751 sec time_interval:64314751)
- (invoke count:10000000 tsc_interval:224557590)
Type:kmem bulk_fallback Per elem: 108 cycles(tsc) 31.027 ns (step:158)
- (measurement period time:0.310276416 sec time_interval:310276416)
- (invoke count:9999978 tsc_interval:1083341310)
Type:kmem bulk_quick_reuse Per elem: 24 cycles(tsc) 6.989 ns (step:158)
- (measurement period time:0.069891439 sec time_interval:69891439)
- (invoke count:9999978 tsc_interval:244028721)
Type:kmem bulk_fallback Per elem: 107 cycles(tsc) 30.833 ns (step:250)
- (measurement period time:0.308335100 sec time_interval:308335100)
- (invoke count:10000000 tsc_interval:1076566255)
Type:kmem bulk_quick_reuse Per elem: 24 cycles(tsc) 6.947 ns (step:250)
- (measurement period time:0.069477012 sec time_interval:69477012)
- (invoke count:10000000 tsc_interval:242581824)

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20160405
---
 init/Kconfig |   9 ++++
 mm/slab.c    | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 166 insertions(+), 1 deletion(-)

diff --git a/init/Kconfig b/init/Kconfig
index 0dfd09d..ee35418 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1742,6 +1742,15 @@ config SLOB
 
 endchoice
 
+config FREELIST_RANDOM
+	default n
+	depends on SLAB
+	bool "SLAB freelist randomization"
+	help
+	  Randomizes the freelist order used on creating new SLABs. This
+	  security feature reduces the predictability of the kernel slab
+	  allocator against heap overflows.
+
 config SLUB_CPU_PARTIAL
 	default y
 	depends on SLUB && SMP
diff --git a/mm/slab.c b/mm/slab.c
index b70aabf..5d8bde2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1229,6 +1229,61 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
 	}
 }
 
+#ifdef CONFIG_FREELIST_RANDOM
+/*
+ * Master lists are pre-computed random lists
+ * Lists of different sizes are used to optimize performance on different
+ * SLAB object sizes per pages.
+ */
+static freelist_idx_t master_list_2[2];
+static freelist_idx_t master_list_4[4];
+static freelist_idx_t master_list_8[8];
+static freelist_idx_t master_list_16[16];
+static freelist_idx_t master_list_32[32];
+static freelist_idx_t master_list_64[64];
+static freelist_idx_t master_list_128[128];
+static freelist_idx_t master_list_256[256];
+static struct m_list {
+	size_t count;
+	freelist_idx_t *list;
+} master_lists[] = {
+	{ ARRAY_SIZE(master_list_2), master_list_2 },
+	{ ARRAY_SIZE(master_list_4), master_list_4 },
+	{ ARRAY_SIZE(master_list_8), master_list_8 },
+	{ ARRAY_SIZE(master_list_16), master_list_16 },
+	{ ARRAY_SIZE(master_list_32), master_list_32 },
+	{ ARRAY_SIZE(master_list_64), master_list_64 },
+	{ ARRAY_SIZE(master_list_128), master_list_128 },
+	{ ARRAY_SIZE(master_list_256), master_list_256 },
+};
+
+static void __init freelist_random_init(void)
+{
+	unsigned int seed;
+	size_t z, i, rand;
+	struct rnd_state slab_rand;
+
+	get_random_bytes_arch(&seed, sizeof(seed));
+	prandom_seed_state(&slab_rand, seed);
+
+	for (z = 0; z < ARRAY_SIZE(master_lists); z++) {
+		for (i = 0; i < master_lists[z].count; i++)
+			master_lists[z].list[i] = i;
+
+		/* Fisher-Yates shuffle */
+		for (i = master_lists[z].count - 1; i > 0; i--) {
+			rand = prandom_u32_state(&slab_rand);
+			rand %= (i + 1);
+			swap(master_lists[z].list[i],
+				master_lists[z].list[rand]);
+		}
+	}
+}
+#else
+static inline void __init freelist_random_init(void) { }
+#endif /* CONFIG_FREELIST_RANDOM */
+
+
 /*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
@@ -1255,6 +1310,8 @@ void __init kmem_cache_init(void)
 	if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
 		slab_max_order = SLAB_MAX_ORDER_HI;
 
+	freelist_random_init();
+
 	/* Bootstrap is tricky, because several objects are allocated
 	 * from caches that do not exist yet:
 	 * 1) initialize the kmem_cache cache: it contains the struct
@@ -2442,6 +2499,101 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 #endif
 }
 
+#ifdef CONFIG_FREELIST_RANDOM
+enum master_type {
+	match,
+	less,
+	more
+};
+
+struct random_mng {
+	unsigned int padding;
+	unsigned int pos;
+	unsigned int count;
+	struct m_list master_list;
+	unsigned int master_count;
+	enum master_type type;
+};
+
+static void random_mng_initialize(struct random_mng *mng, unsigned int count)
+{
+	unsigned int idx;
+	const unsigned int last_idx = ARRAY_SIZE(master_lists) - 1;
+
+	memset(mng, 0, sizeof(*mng));
+	mng->count = count;
+	mng->pos = 0;
+	/* count is >= 2 */
+	idx = ilog2(count) - 1;
+	if (idx >= last_idx)
+		idx = last_idx;
+	else if (roundup_pow_of_two(idx + 1) != count)
+		idx++;
+	mng->master_list = master_lists[idx];
+	if (mng->master_list.count == mng->count)
+		mng->type = match;
+	else if (mng->master_list.count > mng->count)
+		mng->type = more;
+	else
+		mng->type = less;
+}
+
+static freelist_idx_t get_next_entry(struct random_mng *mng)
+{
+	if (mng->type == less && mng->pos == mng->master_list.count) {
+		mng->padding += mng->pos;
+		mng->pos = 0;
+	}
+	BUG_ON(mng->pos >= mng->master_list.count);
+	return mng->master_list.list[mng->pos++];
+}
+
+static freelist_idx_t next_random_slot(struct random_mng *mng)
+{
+	freelist_idx_t cur, entry;
+
+	entry = get_next_entry(mng);
+
+	if (mng->type != match) {
+		while ((entry + mng->padding) >= mng->count)
+			entry = get_next_entry(mng);
+		cur = entry + mng->padding;
+		BUG_ON(cur >= mng->count);
+	} else {
+		cur = entry;
+	}
+
+	return cur;
+}
+
+static void shuffle_freelist(struct kmem_cache *cachep, struct page *page,
+			     unsigned int count)
+{
+	unsigned int i;
+	struct random_mng mng;
+
+	if (count < 2) {
+		for (i = 0; i < count; i++)
+			set_free_obj(page, i, i);
+		return;
+	}
+
+	/* Last chunk is used already in this case */
+	if (OBJFREELIST_SLAB(cachep))
+		count--;
+
+	random_mng_initialize(&mng, count);
+	for (i = 0; i < count; i++)
+		set_free_obj(page, i, next_random_slot(&mng));
+
+	if (OBJFREELIST_SLAB(cachep))
+		set_free_obj(page, i, i);
+}
+#else
+static inline void shuffle_freelist(struct kmem_cache *cachep,
+				    struct page *page, unsigned int count) { }
+#endif /* CONFIG_FREELIST_RANDOM */
+
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct page *page)
 {
@@ -2464,8 +2616,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			kasan_poison_object_data(cachep, objp);
 		}
 
-		set_free_obj(page, i, i);
+		/* If enabled, initialization is done in shuffle_freelist */
+		if (!config_enabled(CONFIG_FREELIST_RANDOM))
+			set_free_obj(page, i, i);
 	}
+
+	shuffle_freelist(cachep, page, cachep->num);
 }
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
