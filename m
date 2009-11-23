Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A6E146B007B
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 16:22:45 -0500 (EST)
Date: Mon, 23 Nov 2009 21:22:05 GMT
From: tip-bot for Arnaldo Carvalho de Melo <acme@redhat.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, acme@redhat.com, paulus@samba.org,
        linux-kernel@vger.kernel.org, penberg@cs.helsinki.fi,
        lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl, efault@gmx.de,
        eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org,
        tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <1259005869-13487-2-git-send-email-acme@infradead.org>
References: <1259005869-13487-2-git-send-email-acme@infradead.org>
Subject: [tip:perf/core] perf kmem: Resolve symbols
Message-ID: <tip-1b145ae58035f30353d78d25bea665091df9b438@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, paulus@samba.org, acme@redhat.com, hpa@zytor.com, mingo@redhat.com, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi, efault@gmx.de, eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  1b145ae58035f30353d78d25bea665091df9b438
Gitweb:     http://git.kernel.org/tip/1b145ae58035f30353d78d25bea665091df9b438
Author:     Arnaldo Carvalho de Melo <acme@redhat.com>
AuthorDate: Mon, 23 Nov 2009 17:51:09 -0200
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Mon, 23 Nov 2009 21:55:20 +0100

perf kmem: Resolve symbols

E.g.:

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

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: FrA(C)dA(C)ric Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Steven Rostedt <rostedt@goodmis.org>
LKML-Reference: <1259005869-13487-2-git-send-email-acme@infradead.org>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
