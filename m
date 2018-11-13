Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06C0B6B0298
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:53:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so7362940pgv.8
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:53:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d12-v6si19483428plr.92.2018.11.12.21.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:53:03 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 3.18 8/9] mm/vmstat.c: assert that vmstat_text is in sync with stat_items_size
Date: Tue, 13 Nov 2018 00:52:51 -0500
Message-Id: <20181113055252.79406-8-sashal@kernel.org>
In-Reply-To: <20181113055252.79406-1-sashal@kernel.org>
References: <20181113055252.79406-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Jann Horn <jannh@google.com>

[ Upstream commit f0ecf25a093fc0589f0a6bc4c1ea068bbb67d220 ]

Having two gigantic arrays that must manually be kept in sync, including
ifdefs, isn't exactly robust.  To make it easier to catch such issues in
the future, add a BUILD_BUG_ON().

Link: http://lkml.kernel.org/r/20181001143138.95119-3-jannh@google.com
Signed-off-by: Jann Horn <jannh@google.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Kemi Wang <kemi.wang@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmstat.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4590aa42b6cd..792374f7088f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1189,6 +1189,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	stat_items_size += sizeof(struct vm_event_state);
 #endif
 
+	BUILD_BUG_ON(stat_items_size !=
+		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
 	v = kmalloc(stat_items_size, GFP_KERNEL);
 	m->private = v;
 	if (!v)
-- 
2.17.1
