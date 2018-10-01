Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3402C6B0007
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 10:31:56 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id h81-v6so3725963vke.13
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 07:31:56 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j126-v6sor276438vkf.17.2018.10.01.07.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 07:31:54 -0700 (PDT)
Date: Mon,  1 Oct 2018 16:31:38 +0200
In-Reply-To: <20181001143138.95119-1-jannh@google.com>
Message-Id: <20181001143138.95119-3-jannh@google.com>
Mime-Version: 1.0
References: <20181001143138.95119-1-jannh@google.com>
Subject: [PATCH v2 3/3] mm/vmstat: assert that vmstat_text is in sync with stat_items_size
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jannh@google.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

As evidenced by the previous two patches, having two gigantic arrays that
must manually be kept in sync, including ifdefs, isn't exactly robust.
To make it easier to catch such issues in the future, add a BUILD_BUG_ON().

Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/vmstat.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da76abf2..b678c607e490 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1663,6 +1663,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	stat_items_size += sizeof(struct vm_event_state);
 #endif
 
+	BUILD_BUG_ON(stat_items_size !=
+		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
 	v = kmalloc(stat_items_size, GFP_KERNEL);
 	m->private = v;
 	if (!v)
-- 
2.19.0.605.g01d371f741-goog
