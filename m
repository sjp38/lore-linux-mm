Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9286B02F3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:28:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f185so125726458pgc.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:28:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u133si9168651pgb.573.2017.06.19.16.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:28:46 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 1/4] percpu: add missing lockdep_assert_held to func pcpu_free_area
Date: Mon, 19 Jun 2017 19:28:29 -0400
Message-ID: <20170619232832.27116-2-dennisz@fb.com>
In-Reply-To: <20170619232832.27116-1-dennisz@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Dennis Zhou <dennisz@fb.com>

Add a missing lockdep_assert_held for pcpu_lock to improve consistency
and safety throughout mm/percpu.c.

Signed-off-by: Dennis Zhou <dennisz@fb.com>
---
 mm/percpu.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index e0aa8ae..f94a5eb 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -672,6 +672,8 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	int to_free = 0;
 	int *p;
 
+	lockdep_assert_held(&pcpu_lock);
+
 	freeme |= 1;	/* we are searching for <given offset, in use> pair */
 
 	i = 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
