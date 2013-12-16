Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0E24A6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 06:16:41 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so1825985ead.31
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 03:16:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si13066675eew.118.2013.12.16.03.16.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 03:16:41 -0800 (PST)
Date: Mon, 16 Dec 2013 11:16:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131216111637.GR11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <CA+55aFz5ZTEiEELhPaQd97TorAKjqrKCmJc9O0NE1Nyri65Pzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFz5ZTEiEELhPaQd97TorAKjqrKCmJc9O0NE1Nyri65Pzw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 15, 2013 at 10:34:25AM -0800, Linus Torvalds wrote:
> On Sun, Dec 15, 2013 at 7:55 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > Short answer -- There appears to be a second bug where 3.13-rc3 is less
> > fair to threads getting time on the CPU.
> 
> Hmm.  Can you point me at the (fixed) microbenchmark you mention?
> 

ebizzy is what I was using to see the per-thread performance. It's at
http://sourceforge.net/projects/ebizzy/. It's patched with the patch below
to give per-thread stats.

You probably want to run it manually but FWIW, the results I posted were
using mmtests (https://github.com/gormanm/mmtests) to build, patch,
run ebizzy and generate the report. The configuration file I used was
configs/config-global-dhp__tlbflush-performance. I have not tried a manual
performance analysis yet as an automated bisection is in progress to see
can the thread spread problem be found the easy way.

diff --git a/ebizzy.c b/ebizzy.c
index 76c7492..3e7644f 100644
--- a/ebizzy.c
+++ b/ebizzy.c
@@ -83,7 +83,7 @@ static char **hole_mem;
 static unsigned int page_size;
 static time_t start_time;
 static volatile int threads_go;
-static unsigned int records_read;
+static unsigned int *thread_records_read;
 
 static void
 usage(void)
@@ -436,6 +436,7 @@ search_mem(void)
 static void *
 thread_run(void *arg)
 {
+	unsigned int *records = (unsigned int *)arg;
 
 	if (verbose > 1)
 		printf("Thread started\n");
@@ -444,7 +445,7 @@ thread_run(void *arg)
 
 	while (threads_go == 0);
 
-	records_read += search_mem();
+	*records = search_mem();
 
 	if (verbose > 1)
 		printf("Thread finished, %f seconds\n",
@@ -471,12 +472,19 @@ start_threads(void)
 	struct rusage start_ru, end_ru;
 	struct timeval usr_time, sys_time;
 	int err;
+	unsigned int total_records = 0;
 
 	if (verbose)
 		printf("Threads starting\n");
 
+	thread_records_read = calloc(threads, sizeof(unsigned int));
+	if (!thread_records_read) {
+		fprintf(stderr, "Error allocating thread_records_read\n");
+		exit(1);
+	}
+
 	for (i = 0; i < threads; i++) {
-		err = pthread_create(&thread_array[i], NULL, thread_run, NULL);
+		err = pthread_create(&thread_array[i], NULL, thread_run, &thread_records_read[i]);
 		if (err) {
 			fprintf(stderr, "Error creating thread %d\n", i);
 			exit(1);
@@ -505,13 +513,21 @@ start_threads(void)
 			fprintf(stderr, "Error joining thread %d\n", i);
 			exit(1);
 		}
+		total_records += thread_records_read[i];
 	}
 
 	if (verbose)
 		printf("Threads finished\n");
 
-	printf("%u records/s\n",
-	       (unsigned int) (((double) records_read)/elapsed));
+	printf("%u records/s",
+	       (unsigned int) (((double) total_records)/elapsed));
+
+	for (i = 0; i < threads; i++) {
+		printf(" %u", (unsigned int) (((double) thread_records_read[i])/elapsed));
+	}
+	printf("\n");
+
+	free(thread_records_read);
 
 	usr_time = difftimeval(&end_ru.ru_utime, &start_ru.ru_utime);
 	sys_time = difftimeval(&end_ru.ru_stime, &start_ru.ru_stime);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
