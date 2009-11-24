Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C00A6B007D
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:55:44 -0500 (EST)
Date: Tue, 24 Nov 2009 16:54:52 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        fweisbec@gmail.com, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi,
        peterz@infradead.org, eduard.munteanu@linux360.ro, tglx@linutronix.de,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <4B0B6E5C.4080900@cn.fujitsu.com>
References: <4B0B6E5C.4080900@cn.fujitsu.com>
Subject: [tip:perf/core] perf kmem: Add new option to show raw ip
Message-ID: <tip-7707b6b6f8d9188b612f9fc88c65411264b1ed57@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  7707b6b6f8d9188b612f9fc88c65411264b1ed57
Gitweb:     http://git.kernel.org/tip/7707b6b6f8d9188b612f9fc88c65411264b1ed57
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Tue, 24 Nov 2009 13:25:48 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 24 Nov 2009 08:49:49 +0100

perf kmem: Add new option to show raw ip

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
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <4B0B6E5C.4080900@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
