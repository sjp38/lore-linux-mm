Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4C89003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 21:54:02 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so111011789qkb.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:54:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h107si3913342qgd.120.2015.07.22.18.54.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 18:54:01 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:53:54 +0800
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 2/3] percpu: Add WARN_ON into percpu_init_late
Message-ID: <20150723015354.GB1844@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437404130-5188-2-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In pcpu_setup_first_chunk() pcpu_reserved_chunk is assigned to point to
static chunk. While pcpu_first_chunk is got from below code:

	pcpu_first_chunk = dchunk ?: schunk;

pcpu_first_chunk might point to static chunk too with possibility. Add a
WARN_ON here to yell out if that happened.*/

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/percpu.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index 8cf18dc..974600b 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2275,6 +2275,13 @@ void __init percpu_init_late(void)
 	unsigned long flags;
 	int i;
 
+	/* In pcpu_setup_first_chunk() pcpu_reserved_chunk is assigned to point to
+	 * static chunk. While pcpu_first_chunk is got from below code:
+	 * 		pcpu_first_chunk = dchunk ?: schunk;
+	 * pcpu_first_chunk might point to static chunk too with possibility. Add a
+	 * WARN_ON here to yell out if that happened.*/
+	WARN_ON(pcpu_first_chunk == pcpu_reserved_chunk);
+
 	for (i = 0; (chunk = target_chunks[i]); i++) {
 		int *map;
 		const size_t size = PERCPU_DYNAMIC_EARLY_SLOTS * sizeof(map[0]);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
