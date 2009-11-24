Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EEE96B007D
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 00:26:29 -0500 (EST)
Message-ID: <4B0B6E5C.4080900@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 13:25:48 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] perf kmem: Add new option to show raw ip
References: <4B0B6E44.6090106@cn.fujitsu.com>
In-Reply-To: <4B0B6E44.6090106@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add option "--raw-ip" to show raw ip instead of symbols:

 # ./perf kmem --stat caller --raw-ip
 ------------------------------------------------------------------------------
 Callsite                    |Total_alloc/Per | Total_req/Per | Hit  | Frag
 ------------------------------------------------------------------------------
 0xc05301aa                  |  733184/4096   |  733184/4096  |   179|   0.000%
 0xc0542ba0                  |  483328/4096   |  483328/4096  |   118|   0.000%
 ...

Also show symbols with format sym+offset instead of sym/offset.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 tools/perf/builtin-kmem.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 256d18f..1ef43c2 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -32,15 +32,14 @@ sort_fn_t			caller_sort_fn;
 static int			alloc_lines = -1;
 static int			caller_lines = -1;
 
+static bool			raw_ip;
+
 static char			*cwd;
 static int			cwdlen;
 
 struct alloc_stat {
 	union {
-		struct {
-			char	*name;
-			u64	call_site;
-		};
+		u64	call_site;
 		u64	ptr;
 	};
 	u64	bytes_req;
@@ -323,12 +322,14 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 
 		if (is_caller) {
 			addr = data->call_site;
-			sym = kernel_maps__find_symbol(addr, NULL, NULL);
+			if (!raw_ip)
+				sym = kernel_maps__find_symbol(addr,
+							       NULL, NULL);
 		} else
 			addr = data->ptr;
 
 		if (sym != NULL)
-			snprintf(bf, sizeof(bf), "%s/%Lx", sym->name,
+			snprintf(bf, sizeof(bf), "%s+%Lx", sym->name,
 				 addr - sym->start);
 		else
 			snprintf(bf, sizeof(bf), "%#Lx", addr);
@@ -345,9 +346,9 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 	}
 
 	if (n_lines == -1)
-		printf(" ...               | ...             | ...             | ...    | ...   \n");
+		printf(" ...                        | ...            | ...           | ...    | ...   \n");
 
-	printf(" ------------------------------------------------------------------------------\n");
+	printf("%.78s\n", graph_dotted_line);
 }
 
 static void print_summary(void)
@@ -558,6 +559,7 @@ static const struct option kmem_options[] = {
 	OPT_CALLBACK('l', "line", NULL, "num",
 		     "show n lins",
 		     parse_line_opt),
+	OPT_BOOLEAN(0, "raw-ip", &raw_ip, "show raw ip instead of symbol"),
 	OPT_END()
 };
 
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
