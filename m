Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C27BD6B0293
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:28 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so59152665wjc.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:28 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r37si15154238wrb.159.2017.01.29.21.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:27 -0800 (PST)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U5kQ8V030758
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 288r09d6by-5
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 21be68ece6b011e6ac470002c99293a0-721f6a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:23 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 6/6] mm: enable MADV_FREE for swapless system
Date: Sun, 29 Jan 2017 21:51:23 -0800
Message-ID: <50b078171991f3ffdbdc34b6e0d7b3a146b7c859.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

Now MADV_FREE pages can be easily reclaimed even for swapless system. We
can safely enable MADV_FREE for all systems.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/madvise.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 78b4b02..047cfd4 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -579,13 +579,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
-		/*
-		 * XXX: In this implementation, MADV_FREE works like
-		 * MADV_DONTNEED on swapless system or full swap.
-		 */
-		if (get_nr_swap_pages() > 0)
-			return madvise_free(vma, prev, start, end);
-		/* passthrough */
+		return madvise_free(vma, prev, start, end);
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
