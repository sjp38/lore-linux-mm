Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD9C6B007D
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 14:51:30 -0500 (EST)
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: [PATCH 2/2] perf kmem: resolve symbols
Date: Mon, 23 Nov 2009 17:51:09 -0200
Message-Id: <1259005869-13487-2-git-send-email-acme@infradead.org>
In-Reply-To: <1259005869-13487-1-git-send-email-acme@infradead.org>
References: <1259005869-13487-1-git-send-email-acme@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, =?utf-8?q?Fr=C3=A9d=C3=A9ric=20Weisbecker?= <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Paul Mackerras <paulus@samba.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

E.g.

[root@doppio linux-2.6-tip]# perf kmem record sleep 3s
[ perf record: Woken up 2 times to write data ]
[ perf record: Captured and wrote 0.804 MB perf.data (~35105 samples) ]
[root@doppio linux-2.6-tip]# perf kmem --stat caller | head -10
------------------------------------------------------------------------------
Callsite                    |Total_alloc/Per | Total_req/Per | Hit  | Frag
------------------------------------------------------------------------------
getname/40                  | 1519616/4096   | 1519616/4096  |   371|   0.000%
seq_read/a2                 |  987136/4096   |  987136/4096  |   241|   0.000%
__netdev_alloc_skb/43       |  260368/1049   |  259968/1048  |   248|   0.154%
__alloc_skb/5a              |   77312/256    |   77312/256   |   302|   0.000%
proc_alloc_inode/33         |   76480/632    |   76472/632   |   121|   0.010%
get_empty_filp/8d           |   70272/192    |   70272/192   |   366|   0.000%
split_vma/8e                |   42064/176    |   42064/176   |   239|   0.000%
[root@doppio linux-2.6-tip]#

Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: FrA(C)dA(C)ric Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/builtin-kmem.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 5d8aeae..256d18f 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -307,25 +307,34 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 {
 	struct rb_node *next;
 
-	printf("\n ------------------------------------------------------------------------------\n");
-	if (is_caller)
-		printf(" Callsite          |");
-	else
-		printf(" Alloc Ptr         |");
-	printf(" Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation\n");
-	printf(" ------------------------------------------------------------------------------\n");
+	printf("%.78s\n", graph_dotted_line);
+	printf("%-28s|",  is_caller ? "Callsite": "Alloc Ptr");
+	printf("Total_alloc/Per | Total_req/Per | Hit  | Frag\n");
+	printf("%.78s\n", graph_dotted_line);
 
 	next = rb_first(root);
 
 	while (next && n_lines--) {
-		struct alloc_stat *data;
-
-		data = rb_entry(next, struct alloc_stat, node);
+		struct alloc_stat *data = rb_entry(next, struct alloc_stat,
+						   node);
+		struct symbol *sym = NULL;
+		char bf[BUFSIZ];
+		u64 addr;
+
+		if (is_caller) {
+			addr = data->call_site;
+			sym = kernel_maps__find_symbol(addr, NULL, NULL);
+		} else
+			addr = data->ptr;
+
+		if (sym != NULL)
+			snprintf(bf, sizeof(bf), "%s/%Lx", sym->name,
+				 addr - sym->start);
+		else
+			snprintf(bf, sizeof(bf), "%#Lx", addr);
 
-		printf(" %-16p  | %8llu/%-6lu | %8llu/%-6lu | %6lu | %8.3f%%\n",
-		       is_caller ? (void *)(unsigned long)data->call_site :
-				   (void *)(unsigned long)data->ptr,
-		       (unsigned long long)data->bytes_alloc,
+		printf("%-28s|%8llu/%-6lu |%8llu/%-6lu|%6lu|%8.3f%%\n",
+		       bf, (unsigned long long)data->bytes_alloc,
 		       (unsigned long)data->bytes_alloc / data->hit,
 		       (unsigned long long)data->bytes_req,
 		       (unsigned long)data->bytes_req / data->hit,
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
