Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF906B0039
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:16:20 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id 10so1154881lbg.1
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:19 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id vh6si1289243lac.128.2014.06.24.13.16.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 13:16:18 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so50020lab.9
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:17 -0700 (PDT)
Subject: [PATCH 3/3] mm: catch memory commitment underflow
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 25 Jun 2014 00:16:14 +0400
Message-ID: <20140624201614.18273.39034.stgit@zurg>
In-Reply-To: <20140624201606.18273.44270.stgit@zurg>
References: <20140624201606.18273.44270.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

This patch prints warning (if CONFIG_DEBUG_VM=y) when
memory commitment becomes too negative.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/mmap.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 129b847..d3decd9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -134,6 +134,12 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed, reserve;
 
+#ifdef CONFIG_DEBUG_VM
+	WARN_ONCE(percpu_counter_read(&vm_committed_as) <
+			-(s64)vm_committed_as_batch * num_online_cpus(),
+			"memory commitment underflow");
+#endif
+
 	vm_acct_memory(pages);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
