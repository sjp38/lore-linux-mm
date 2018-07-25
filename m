Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 127766B0008
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:48:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t10-v6so3253612eds.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:48:22 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id j18-v6si8553819edf.210.2018.07.25.08.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 08:48:20 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 2/3] Revert "perf/core: Make sure the ring-buffer is mapped in all page-tables"
Date: Wed, 25 Jul 2018 17:48:02 +0200
Message-Id: <1532533683-5988-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1532533683-5988-1-git-send-email-joro@8bytes.org>
References: <1532533683-5988-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

This reverts commit 77754cfa09a6c528c38cbca9ee4cc4f7cf6ad6f2.

The patch was necessary to silence a WARN_ON_ONCE(in_nmi())
that triggered in the vmalloc_fault() function when PTI was
enabled on x86-32.

Faulting in an NMI handler turned out to be safe and the
warning in vmalloc_fault() is gone now. So the above patch
can be reverted.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 kernel/events/ring_buffer.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index df2d8cf..5d3cf40 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -814,13 +814,6 @@ static void rb_free_work(struct work_struct *work)
 
 	vfree(base);
 	kfree(rb);
-
-	/*
-	 * FIXME: PAE workaround for vmalloc_fault(): Make sure buffer is
-	 * unmapped in all page-tables.
-	 */
-	if (IS_ENABLED(CONFIG_X86_PAE))
-		vmalloc_sync_all();
 }
 
 void rb_free(struct ring_buffer *rb)
@@ -847,15 +840,6 @@ struct ring_buffer *rb_alloc(int nr_pages, long watermark, int cpu, int flags)
 	if (!all_buf)
 		goto fail_all_buf;
 
-	/*
-	 * FIXME: PAE workaround for vmalloc_fault(): The buffer is
-	 * accessed in NMI handlers, make sure it is mapped in all
-	 * page-tables in the system so that we don't fault on the range in
-	 * an NMI handler.
-	 */
-	if (IS_ENABLED(CONFIG_X86_PAE))
-		vmalloc_sync_all();
-
 	rb->user_page = all_buf;
 	rb->data_pages[0] = all_buf + PAGE_SIZE;
 	if (nr_pages) {
-- 
2.7.4
