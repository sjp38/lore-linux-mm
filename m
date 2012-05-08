Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F22EA6B0083
	for <linux-mm@kvack.org>; Tue,  8 May 2012 00:07:50 -0400 (EDT)
Date: Mon, 7 May 2012 21:07:06 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-3a6b76661da8e92124a813b43607f5bec1a618de@git.kernel.org>
Reply-To: mingo@kernel.org, torvalds@linux-foundation.org,
        peterz@infradead.org, anton@redhat.com, jkenisto@linux.vnet.ibm.com,
        rostedt@goodmis.org, oleg@redhat.com, tglx@linutronix.de,
        linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org,
        andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com,
        masami.hiramatsu.pt@hitachi.com, acme@infradead.org,
        srikar@linux.vnet.ibm.com
In-Reply-To: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] tracing: Modify is_delete,
  is_return from int to bool
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, torvalds@linux-foundation.org, peterz@infradead.org, anton@redhat.com, jkenisto@linux.vnet.ibm.com, rostedt@goodmis.org, oleg@redhat.com, tglx@linutronix.de, linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com

Commit-ID:  3a6b76661da8e92124a813b43607f5bec1a618de
Gitweb:     http://git.kernel.org/tip/3a6b76661da8e92124a813b43607f5bec1a618de
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Mon, 9 Apr 2012 14:41:33 +0530
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Mon, 7 May 2012 14:29:35 +0200

tracing: Modify is_delete, is_return from int to bool

is_delete and is_return can take utmost 2 values and are better
of being a boolean than a int. There are no functional changes.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Acked-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Cc: Linux-mm <linux-mm@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Anton Arapov <anton@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/trace/trace_kprobe.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 580a05e..4f935f8 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -651,7 +651,7 @@ static struct trace_probe *alloc_trace_probe(const char *group,
 					     void *addr,
 					     const char *symbol,
 					     unsigned long offs,
-					     int nargs, int is_return)
+					     int nargs, bool is_return)
 {
 	struct trace_probe *tp;
 	int ret = -ENOMEM;
@@ -944,7 +944,7 @@ static int split_symbol_offset(char *symbol, unsigned long *offset)
 #define PARAM_MAX_STACK (THREAD_SIZE / sizeof(unsigned long))
 
 static int parse_probe_vars(char *arg, const struct fetch_type *t,
-			    struct fetch_param *f, int is_return)
+			    struct fetch_param *f, bool is_return)
 {
 	int ret = 0;
 	unsigned long param;
@@ -977,7 +977,7 @@ static int parse_probe_vars(char *arg, const struct fetch_type *t,
 
 /* Recursive argument parser */
 static int __parse_probe_arg(char *arg, const struct fetch_type *t,
-			     struct fetch_param *f, int is_return)
+			     struct fetch_param *f, bool is_return)
 {
 	int ret = 0;
 	unsigned long param;
@@ -1089,7 +1089,7 @@ static int __parse_bitfield_probe_arg(const char *bf,
 
 /* String length checking wrapper */
 static int parse_probe_arg(char *arg, struct trace_probe *tp,
-			   struct probe_arg *parg, int is_return)
+			   struct probe_arg *parg, bool is_return)
 {
 	const char *t;
 	int ret;
@@ -1162,7 +1162,7 @@ static int create_trace_probe(int argc, char **argv)
 	 */
 	struct trace_probe *tp;
 	int i, ret = 0;
-	int is_return = 0, is_delete = 0;
+	bool is_return = false, is_delete = false;
 	char *symbol = NULL, *event = NULL, *group = NULL;
 	char *arg;
 	unsigned long offset = 0;
@@ -1171,11 +1171,11 @@ static int create_trace_probe(int argc, char **argv)
 
 	/* argc must be >= 1 */
 	if (argv[0][0] == 'p')
-		is_return = 0;
+		is_return = false;
 	else if (argv[0][0] == 'r')
-		is_return = 1;
+		is_return = true;
 	else if (argv[0][0] == '-')
-		is_delete = 1;
+		is_delete = true;
 	else {
 		pr_info("Probe definition must be started with 'p', 'r' or"
 			" '-'.\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
