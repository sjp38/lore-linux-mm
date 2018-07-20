Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB4B6B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:22:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b9-v6so4733712edn.18
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 09:22:41 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id e21-v6si2661183edj.214.2018.07.20.09.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 09:22:40 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in all page-tables
Date: Fri, 20 Jul 2018 18:22:22 +0200
Message-Id: <1532103744-31902-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1532103744-31902-1-git-send-email-joro@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The ring-buffer is accessed in the NMI handler, so we better
avoid faulting on it. Sync the vmalloc range with all
page-tables in system to make sure everyone has it mapped.

This fixes a WARN_ON_ONCE() that can be triggered with PTI
enabled on x86-32:

	WARNING: CPU: 4 PID: 0 at arch/x86/mm/fault.c:320 vmalloc_fault+0x220/0x230

This triggers because with PTI enabled on an PAE kernel the
PMDs are no longer shared between the page-tables, so the
vmalloc changes do not propagate automatically.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 kernel/events/ring_buffer.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index 5d3cf40..7b0e9aa 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -814,6 +814,9 @@ static void rb_free_work(struct work_struct *work)
 
 	vfree(base);
 	kfree(rb);
+
+	/* Make sure buffer is unmapped in all page-tables */
+	vmalloc_sync_all();
 }
 
 void rb_free(struct ring_buffer *rb)
@@ -840,6 +843,13 @@ struct ring_buffer *rb_alloc(int nr_pages, long watermark, int cpu, int flags)
 	if (!all_buf)
 		goto fail_all_buf;
 
+	/*
+	 * The buffer is accessed in NMI handlers, make sure it is
+	 * mapped in all page-tables in the system so that we don't
+	 * fault on the range in an NMI handler.
+	 */
+	vmalloc_sync_all();
+
 	rb->user_page = all_buf;
 	rb->data_pages[0] = all_buf + PAGE_SIZE;
 	if (nr_pages) {
-- 
2.7.4
