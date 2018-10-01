Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 884336B0006
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 10:31:51 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id e9-v6so11262900itf.2
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 07:31:51 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n67-v6sor2823144ith.51.2018.10.01.07.31.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 07:31:50 -0700 (PDT)
Date: Mon,  1 Oct 2018 16:31:37 +0200
In-Reply-To: <20181001143138.95119-1-jannh@google.com>
Message-Id: <20181001143138.95119-2-jannh@google.com>
Mime-Version: 1.0
References: <20181001143138.95119-1-jannh@google.com>
Subject: [PATCH v2 2/3] mm/vmstat: skip NR_TLB_REMOTE_FLUSH* properly
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jannh@google.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

commit 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED
available even on UP") made the availability of the NR_TLB_REMOTE_FLUSH*
counters inside the kernel unconditional to reduce #ifdef soup, but
(either to avoid showing dummy zero counters to userspace, or because that
code was missed) didn't update the vmstat_array, meaning that all following
counters would be shown with incorrect values.

This only affects kernel builds with
CONFIG_VM_EVENT_COUNTERS=y && CONFIG_DEBUG_TLBFLUSH=y && CONFIG_SMP=n.

Fixes: 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED available even on UP")
Cc: stable@vger.kernel.org
Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/vmstat.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4cea7b8f519d..7878da76abf2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1275,6 +1275,9 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
 	"nr_tlb_remote_flush_received",
+#else
+	"", /* nr_tlb_remote_flush */
+	"", /* nr_tlb_remote_flush_received */
 #endif /* CONFIG_SMP */
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
-- 
2.19.0.605.g01d371f741-goog
