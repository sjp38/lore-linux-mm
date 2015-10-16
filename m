From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] zsmalloc: reduce size_class memory usage
Date: Fri, 16 Oct 2015 13:01:30 +0900
Message-ID: <1444968090-7066-1-git-send-email-sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
List-Id: linux-mm.kvack.org

Each `struct size_class' contains `struct zs_size_stat':
an array of NR_ZS_STAT_TYPE `unsigned long'. For zsmalloc
built with no CONFIG_ZSMALLOC_STAT this results in a waste
of `2 * sizeof(unsigned long)' per-class.

The patch removes unneeded `struct zs_size_stat' members
by redefining NR_ZS_STAT_TYPE (max stat idx in array).

Since both NR_ZS_STAT_TYPE and zs_stat_type are compile time
constants, GCC can eliminate zs_stat_inc()/zs_stat_dec() calls
that use zs_stat_type larger than NR_ZS_STAT_TYPE:
CLASS_ALMOST_EMPTY and CLASS_ALMOST_FULL at the moment.

./scripts/bloat-o-meter mm/zsmalloc.o.old mm/zsmalloc.o.new
add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-39 (-39)
function                                     old     new   delta
fix_fullness_group                            97      94      -3
insert_zspage                                100      86     -14
remove_zspage                                141     119     -22

To summarize:
a) each class now uses less memory
b) we avoid a number of dec/inc stats (a minor optimization,
   but still).

The gain will increase once we introduce additional stats.

A simple IO test.

iozone -t 4 -R -r 32K -s 60M -I +Z
                        patched                 base
"  Initial write "       4145599.06              4127509.75
"        Rewrite "       4146225.94              4223618.50
"           Read "      17157606.00             17211329.50
"        Re-read "      17380428.00             17267650.50
"   Reverse Read "      16742768.00             16162732.75
"    Stride read "      16586245.75             16073934.25
"    Random read "      16349587.50             15799401.75
" Mixed workload "      10344230.62              9775551.50
"   Random write "       4277700.62              4260019.69
"         Pwrite "       4302049.12              4313703.88
"          Pread "       6164463.16              6126536.72
"         Fwrite "       7131195.00              6952586.00
"          Fread "      12682602.25             12619207.50

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2500ee8..0331c9a9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -166,9 +166,14 @@ enum zs_stat_type {
 	OBJ_USED,
 	CLASS_ALMOST_FULL,
 	CLASS_ALMOST_EMPTY,
-	NR_ZS_STAT_TYPE,
 };
 
+#ifdef CONFIG_ZSMALLOC_STAT
+#define NR_ZS_STAT_TYPE	(CLASS_ALMOST_EMPTY + 1)
+#else
+#define NR_ZS_STAT_TYPE	(OBJ_USED + 1)
+#endif
+
 struct zs_size_stat {
 	unsigned long objs[NR_ZS_STAT_TYPE];
 };
@@ -447,19 +452,23 @@ static int get_size_class_index(int size)
 static inline void zs_stat_inc(struct size_class *class,
 				enum zs_stat_type type, unsigned long cnt)
 {
-	class->stats.objs[type] += cnt;
+	if (type < NR_ZS_STAT_TYPE)
+		class->stats.objs[type] += cnt;
 }
 
 static inline void zs_stat_dec(struct size_class *class,
 				enum zs_stat_type type, unsigned long cnt)
 {
-	class->stats.objs[type] -= cnt;
+	if (type < NR_ZS_STAT_TYPE)
+		class->stats.objs[type] -= cnt;
 }
 
 static inline unsigned long zs_stat_get(struct size_class *class,
 				enum zs_stat_type type)
 {
-	return class->stats.objs[type];
+	if (type < NR_ZS_STAT_TYPE)
+		return class->stats.objs[type];
+	return 0;
 }
 
 #ifdef CONFIG_ZSMALLOC_STAT
-- 
2.6.1.134.g4b1fd35
