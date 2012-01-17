Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 070276B006C
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 03:14:28 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id fa15so1866150vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 00:14:28 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/3] test program
Date: Tue, 17 Jan 2012 17:13:58 +0900
Message-Id: <1326788038-29141-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1326788038-29141-1-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, Minchan Kim <minchan@kernel.org>

This test program allocates 10M per second and when
memory pressure notify happens, it releases 20M.

I tested this patch on 512M qemu machine with 3 test program.
I saw some swapout but not too many and even didn't see OOM.
It obviously reduces swap out.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 poll.c |  121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 121 insertions(+), 0 deletions(-)
 create mode 100644 poll.c

diff --git a/poll.c b/poll.c
new file mode 100644
index 0000000..3215f8b
--- /dev/null
+++ b/poll.c
@@ -0,0 +1,121 @@
+#include <poll.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <pthread.h>
+#include <stdbool.h>
+#include <stdlib.h>
+#include <string.h>
+
+#define ALLOC_UNIT	10 /* MB */
+#define FREE_UNIT	20 /* MB */
+
+void alloc_memory();
+void free_memory();
+
+unsigned int total_memory = 0; /* MB */
+
+pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; 
+
+/*
+ * If total memory is higher than 200M
+ */
+bool memory_full()
+{
+	return total_memory >= 400 ? true : false;
+}
+
+struct alloc_chunk {
+	void *ptr;
+	struct alloc_chunk *next;
+};
+
+struct alloc_chunk head_chunk;
+
+void init_alloc_chunk(void)
+{
+	head_chunk.ptr = NULL;
+	head_chunk.next = NULL;
+}
+
+void add_memory(void *ptr)
+{
+	struct alloc_chunk *new_chunk = malloc(sizeof(struct alloc_chunk));
+	new_chunk->ptr = ptr;
+
+	pthread_mutex_lock(&mutex);
+	new_chunk->next = head_chunk.next;
+	head_chunk.next = new_chunk;
+	total_memory += ALLOC_UNIT;
+	pthread_mutex_unlock(&mutex);
+
+	printf("[%d] Add total memory %d(MB)\n", getpid(), total_memory);
+}
+
+void alloc_memory(void)
+{
+	while(1) {
+		if (memory_full()) {
+			sleep(10);
+			continue;
+		}
+
+		void *new = malloc(ALLOC_UNIT*1024*1024);
+		memset(new, 0, ALLOC_UNIT*1024*1024);
+		add_memory(new);
+		sleep(1);
+	}
+}
+
+void free_memory(void)
+{
+	int count = FREE_UNIT / ALLOC_UNIT;
+	while(count--) {
+		struct alloc_chunk *chunk = head_chunk.next;
+		if (chunk == NULL)
+			break;
+
+		pthread_mutex_lock(&mutex);
+		head_chunk.next = chunk->next;
+		total_memory -= ALLOC_UNIT;
+		pthread_mutex_unlock(&mutex);
+
+		free(chunk->ptr);
+		free(chunk);
+
+		printf("[%d] Free total memory %d(MB)\n", getpid(), total_memory);
+	}
+}
+
+void *poll_thread(void *dummy)
+{
+	struct pollfd pfd;	
+	int fd = open("/dev/low_mem_notify", O_RDONLY); 
+	if (fd == -1) {
+		fprintf(stderr, "Fail to open\n");
+		return;
+	}
+
+	pfd.fd = fd;
+	pfd.events = POLLIN;
+
+	while(1) {
+		poll(&pfd, 1, -1);
+		free_memory();
+	}
+}
+
+int main()
+{
+	pthread_t threadid;
+	init_alloc_chunk();
+
+	if (pthread_create(&threadid, NULL, poll_thread, NULL)) {
+		fprintf(stderr, "pthread create fail\n");
+		return 1;
+	}
+
+	alloc_memory();
+	return 0;
+}
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
