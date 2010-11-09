Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2D5A6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:03:03 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: 2.6.36 io bring the system to its knees
In-reply-to: <20101105014334.GF13830@dastard>
References: <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com> <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com> <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com> <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com> <20101028090002.GA12446@elte.hu> <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com> <20101028133036.GA30565@elte.hu> <20101028170132.GY27796@think> <alpine.LNX.2.00.1011050032440.16015@swampdragon.chaosbits.net> <alpine.LNX.2.00.1011050047220.16015@swampdragon.chaosbits.net> <20101105014334.GF13830@dastard>
Date: Tue, 09 Nov 2010 16:00:37 -0500
Message-Id: <1289336160-sup-3372@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jesper Juhl <jj@chaosbits.net>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Dave Chinner's message of 2010-11-04 21:43:34 -0400:
> On Fri, Nov 05, 2010 at 12:48:17AM +0100, Jesper Juhl wrote:
>
> [ the disks are slow for me too!!!!!!!!!!!!!! ]
>
> > Forgot to mention the kernel I currently experience this with : 
> > 
> > [jj@dragon ~]$ uname -a
> > Linux dragon 2.6.35-ARCH #1 SMP PREEMPT Sat Oct 30 21:22:26 CEST 2010 x86_64 Intel(R) Core(TM)2 Duo CPU T7250 @ 2.00GHz GenuineIntel GNU/Linux
> 
> I think anyone reporting a interactivity problem also needs to
> indicate what their filesystem is, what mount paramters they are
> using, what their storage config is, whether barriers are active or
> not, what elevator they are using, whether one or more of the
> applications are issuing fsync() or sync() calls, and so on.
> 
> Basically, what we need to know is whether these problems are
> isolated to a particular filesystem or storage type because
> they may simply be known problems (e.g. the ext3 fsync-the-world
> problem).

latencytop does help quite a lot in nailing down why we're waiting on
the disk, but the interface doesn't lend itself very well to remote
debugging.  We end up asking for screen shots that may or may not really
nail down what is going on.

I've got a patch that adds latencytop -c, which you use like this:

latencytop -c >& out

It spits out latency info for all the procs every 10 seconds or so,
along with a short stack trace that often helps figure things out.

The patch is below and works properly with the current latencytop
git.  If some of the people hitting bad latencies could try it, it might
help narrow things down.

From: Chris Mason <chris.mason@oracle.com>
Subject: [PATCH] Add latencytop -c to dump process information to the console

This adds something similar to vmstat 1 to latencytop, where
it simply does a text dump of all the process latency information
to the console every 10 seconds.  Back traces are included in the
dump.

Signed-off-by: Chris Mason <chris.mason@oracle.com>
---
 src/Makefile     |    2 +-
 src/latencytop.c |   38 +++++++---
 src/latencytop.h |    1 +
 src/text_dump.c  |  199 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 227 insertions(+), 13 deletions(-)
 create mode 100644 src/text_dump.c

diff --git a/src/Makefile b/src/Makefile
index de24551..1ff9740 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -6,7 +6,7 @@ SBINDIR = /usr/sbin
 XCFLAGS = -W  -g `pkg-config --cflags glib-2.0` -D_FORTIFY_SOURCE=2 -Wno-sign-compare
 LDF = -Wl,--as-needed `pkg-config --libs glib-2.0`   -lncursesw 
 
-OBJS= latencytop.o text_display.o translate.o fsync.o
+OBJS= latencytop.o text_display.o text_dump.o translate.o fsync.o
 
 ifdef HAS_GTK_GUI
   XCFLAGS += `pkg-config --cflags gtk+-2.0` -DHAS_GTK_GUI
diff --git a/src/latencytop.c b/src/latencytop.c
index f516f53..fe252d0 100644
--- a/src/latencytop.c
+++ b/src/latencytop.c
@@ -111,6 +111,10 @@ static void fixup_reason(struct latency_line *line, char *c)
 		*(c2++) = 0;
 	} else
 		strncpy(line->reason, c2, 1024);
+
+	c2 = strchr(line->reason, '\n');
+	if (c2)
+		*c2=0;
 }
 
 void parse_global_list(void)
@@ -538,19 +542,13 @@ static void cleanup_sysctl(void)
 int main(int argc, char **argv)
 {
 	int i, use_gtk = 0;
+	int console_dump = 0;
 
 	enable_sysctl();
 	enable_fsync_tracer();
 	atexit(cleanup_sysctl);
 
-#ifdef HAS_GTK_GUI
-	if (preinitialize_gtk_ui(&argc, &argv))
-		use_gtk = 1;
-#endif
-	if (!use_gtk)
-		preinitialize_text_ui(&argc, &argv);
-
-	for (i = 1; i < argc; i++)		
+	for (i = 1; i < argc; i++) {
 		if (strcmp(argv[i],"-d") == 0) {
 			init_translations("latencytop.trans");
 			parse_global_list();
@@ -558,6 +556,17 @@ int main(int argc, char **argv)
 			dump_global_to_console();
 			return EXIT_SUCCESS;
 		}
+		if (strcmp(argv[i],"-c") == 0)
+			console_dump = 1;
+	}
+
+#ifdef HAS_GTK_GUI
+	if (!console_dump && preinitialize_gtk_ui(&argc, &argv))
+		use_gtk = 1;
+#endif
+	if (!console_dump && !use_gtk)
+		preinitialize_text_ui(&argc, &argv);
+
 	for (i = 1; i < argc; i++)
 		if (strcmp(argv[i], "--unknown") == 0) {
 			noui = 1;
@@ -579,12 +588,17 @@ int main(int argc, char **argv)
 		sleep(5);
 		fprintf(stderr, ".");
 	}
+
+	if (console_dump) {
+		start_text_dump();
+	} else {
 #ifdef HAS_GTK_GUI
-	if (use_gtk)
-		start_gtk_ui();
-	else
+		if (use_gtk)
+			start_gtk_ui();
+		else
 #endif
-		start_text_ui();
+			start_text_ui();
+	}
 
 	prune_unused_procs();
 	delete_list();
diff --git a/src/latencytop.h b/src/latencytop.h
index 79775ac..f3e0934 100644
--- a/src/latencytop.h
+++ b/src/latencytop.h
@@ -50,6 +50,7 @@ extern void start_gtk_ui(void);
 
 extern void preinitialize_text_ui(int *argc, char ***argv);
 extern void start_text_ui(void);
+extern void start_text_dump(void);
 
 extern char *translate(char *line);
 extern void init_translations(char *filename);
diff --git a/src/text_dump.c b/src/text_dump.c
new file mode 100644
index 0000000..76fc7b1
--- /dev/null
+++ b/src/text_dump.c
@@ -0,0 +1,199 @@
+/*
+ * Copyright 2008, Intel Corporation
+ *
+ * This file is part of LatencyTOP
+ *
+ * This program file is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program in a file named COPYING; if not, write to the
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301 USA
+ *
+ * Authors:
+ * 	Arjan van de Ven <arjan@linux.intel.com>
+ *	Chris Mason <chris.mason@oracle.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/time.h>
+#include <dirent.h>
+#include <time.h>
+#include <wchar.h>
+#include <ctype.h>
+
+#include <glib.h>
+
+#include "latencytop.h"
+
+static GList *cursor_e = NULL;
+static int done = 0;
+
+static void print_global_list(void)
+{
+	GList *item;
+	struct latency_line *line;
+	int i = 1;
+
+	printf("Globals: Cause Maximum Percentage\n");
+	item = g_list_first(lines);
+	while (item && i < 10) {
+		line = item->data;
+		item = g_list_next(item);
+
+		if (line->max*0.001 < 0.1)
+			continue;
+		printf("%s", line->reason);
+		printf("\t%5.1f msec        %5.1f %%\n",
+				line->max * 0.001,
+				(line->time * 100 +0.0001) / total_time);
+		i++;
+	}
+}
+
+static void print_one_backtrace(char *trace)
+{
+	char *p;
+	int pos;
+	int after;
+	int tabs = 0;
+
+	if (!trace || !trace[0])
+		return;
+	pos = 16;
+	while(*trace && *trace == ' ')
+		trace++;
+
+	if (!trace[0])
+		return;
+
+	while(*trace) {
+		p = strchr(trace, ' ');
+		if (p) {
+			pos += p - trace + 1;
+			*p = '\0';
+		}
+		if (!tabs) {
+			/* we haven't printed anything yet */
+			printf("\t\t");
+			tabs = 1;
+		} else if (pos > 79) {
+			/*
+			 * we have printed something our line is going to be
+			 * long
+			 */
+			printf("\n\t\t");
+			pos = 16 + p - trace + 1;
+		}
+		printf("%s ", trace);
+		if (!p)
+			break;
+
+		trace = p + 1;
+		if (trace && pos > 70) {
+			printf("\n");
+			tabs = 0;
+			pos = 16;
+		}
+	}
+	printf("\n");
+}
+
+static void print_procs()
+{
+	struct process *proc;
+	GList *item;
+	double total;
+
+	printf("Process details:\n");
+	item = g_list_first(procs);
+	while (item) {
+		int printit = 0;
+		GList *item2;
+		struct latency_line *line;
+		proc = item->data;
+		item = g_list_next(item);
+
+		total = 0.0;
+
+		item2 = g_list_first(proc->latencies);
+		while (item2) {
+			line = item2->data;
+			item2 = g_list_next(item2);
+			total = total + line->time;
+		}
+		item2 = g_list_first(proc->latencies);
+		while (item2) {
+			char *p;
+			char *backtrace;
+			line = item2->data;
+			item2 = g_list_next(item2);
+			if (line->max*0.001 < 0.1)
+				continue;
+			if (!printit) {
+				printf("Process %s (%i) ", proc->name, proc->pid);
+				printf("Total: %5.1f msec\n", total*0.001);
+				printit = 1;
+			}
+			printf("\t%s", line->reason);
+			printf("\t%5.1f msec        %5.1f %%\n",
+				line->max * 0.001,
+				(line->time * 100 +0.0001) / total
+				);
+			print_one_backtrace(line->backtrace);
+		}
+
+	}
+}
+
+static int done_yet(int time, struct timeval *p1)
+{
+	int seconds;
+	int usecs;
+	struct timeval p2;
+	gettimeofday(&p2, NULL);
+	seconds = p2.tv_sec - p1->tv_sec;
+	usecs = p2.tv_usec - p1->tv_usec;
+
+	usecs += seconds * 1000000;
+	if (usecs > time * 1000000)
+		return 1;
+	return 0;
+}
+
+void signal_func(int foobie)
+{
+	done = 1;
+}
+
+void start_text_dump(void)
+{
+	struct timeval now;
+	struct tm *tm;
+	signal(SIGINT, signal_func);
+	signal(SIGTERM, signal_func);
+
+	while (!done) {
+		gettimeofday(&now, NULL);
+		printf("=============== %s", asctime(localtime(&now.tv_sec)));
+		update_list();
+		print_global_list();
+		print_procs();
+		if (done)
+			break;
+		sleep(10);
+	}
+}
+
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
