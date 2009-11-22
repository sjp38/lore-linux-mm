Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2536B004D
	for <linux-mm@kvack.org>; Sun, 22 Nov 2009 05:25:41 -0500 (EST)
Date: Sun, 22 Nov 2009 10:25:05 GMT
From: tip-bot for Pekka Enberg <penberg@cs.helsinki.fi>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org,
        eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org,
        tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <1258883880-7149-1-git-send-email-penberg@cs.helsinki.fi>
References: <1258883880-7149-1-git-send-email-penberg@cs.helsinki.fi>
Subject: [tip:perf/core] perf kmem: Add --sort hit and --sort frag
Message-ID: <tip-f3ced7cdb24e7968a353d828955fa2daf4167e72@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  f3ced7cdb24e7968a353d828955fa2daf4167e72
Gitweb:     http://git.kernel.org/tip/f3ced7cdb24e7968a353d828955fa2daf4167e72
Author:     Pekka Enberg <penberg@cs.helsinki.fi>
AuthorDate: Sun, 22 Nov 2009 11:58:00 +0200
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Sun, 22 Nov 2009 11:21:37 +0100

perf kmem: Add --sort hit and --sort frag

This patch adds support for "--sort hit" and "--sort frag" to
the "perf kmem" tool. The former was already mentioned in the
help text and the latter is useful for finding call-sites that
exhibit worst case behavior for SLAB allocators.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <1258883880-7149-1-git-send-email-penberg@cs.helsinki.fi>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 tools/perf/builtin-kmem.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index f315b05..4145049 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -443,6 +443,15 @@ static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static int hit_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	if (l->hit < r->hit)
+		return -1;
+	else if (l->hit > r->hit)
+		return 1;
+	return 0;
+}
+
 static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	if (l->bytes_alloc < r->bytes_alloc)
@@ -452,6 +461,20 @@ static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static int frag_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	double x, y;
+
+	x = fragmentation(l->bytes_req, l->bytes_alloc);
+	y = fragmentation(r->bytes_req, r->bytes_alloc);
+
+	if (x < y)
+		return -1;
+	else if (x > y)
+		return 1;
+	return 0;
+}
+
 static int parse_sort_opt(const struct option *opt __used,
 			  const char *arg, int unset __used)
 {
@@ -464,8 +487,12 @@ static int parse_sort_opt(const struct option *opt __used,
 		sort_fn = ptr_cmp;
 	else if (strcmp(arg, "call_site") == 0)
 		sort_fn = callsite_cmp;
+	else if (strcmp(arg, "hit") == 0)
+		sort_fn = hit_cmp;
 	else if (strcmp(arg, "bytes") == 0)
 		sort_fn = bytes_cmp;
+	else if (strcmp(arg, "frag") == 0)
+		sort_fn = frag_cmp;
 	else
 		return -1;
 
@@ -517,7 +544,7 @@ static const struct option kmem_options[] = {
 		     "stat selector, Pass 'alloc' or 'caller'.",
 		     parse_stat_opt),
 	OPT_CALLBACK('s', "sort", NULL, "key",
-		     "sort by key: ptr, call_site, hit, bytes",
+		     "sort by key: ptr, call_site, hit, bytes, frag",
 		     parse_sort_opt),
 	OPT_CALLBACK('l', "line", NULL, "num",
 		     "show n lins",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
