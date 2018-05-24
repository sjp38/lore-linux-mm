Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A70A6B0275
	for <linux-mm@kvack.org>; Thu, 24 May 2018 19:00:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so1826135plb.20
        for <linux-mm@kvack.org>; Thu, 24 May 2018 16:00:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r39-v6sor10343706pld.66.2018.05.24.16.00.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 16:00:35 -0700 (PDT)
Date: Thu, 24 May 2018 16:00:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] proc: fix smaps and meminfo alignment
Message-ID: <alpine.LSU.2.11.1805241554210.1326@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrei Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The 4.17-rc /proc/meminfo and /proc/<pid>/smaps look ugly: single-digit
numbers (commonly 0) are misaligned. Remove seq_put_decimal_ull_width()'s
leftover optimization for single digits: it's wrong now that num_to_str()
takes care of the width.

Fixes: d1be35cb6f96 ("proc: add seq_put_decimal_ull_width to speed up /proc/pid/smaps")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/seq_file.c |    5 -----
 1 file changed, 5 deletions(-)

--- 4.17-rc6/fs/seq_file.c	2018-04-15 21:45:06.740885410 -0700
+++ linux/fs/seq_file.c	2018-05-24 14:41:21.508491794 -0700
@@ -709,11 +709,6 @@ void seq_put_decimal_ull_width(struct se
 	if (m->count + width >= m->size)
 		goto overflow;
 
-	if (num < 10) {
-		m->buf[m->count++] = num + '0';
-		return;
-	}
-
 	len = num_to_str(m->buf + m->count, m->size - m->count, num, width);
 	if (!len)
 		goto overflow;
