Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B8E536B02BE
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 21:25:15 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id bx7so5590874pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 18:25:15 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id p28si682829pfi.167.2016.04.05.18.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 18:25:15 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id zm5so21794505pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 18:25:15 -0700 (PDT)
Date: Tue, 5 Apr 2016 18:25:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb_cgroup: round limit_in_bytes down to hugepage
 size
Message-ID: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The page_counter rounds limits down to page size values.  This makes
sense, except in the case of hugetlb_cgroup where it's not possible to
charge partial hugepages.

Round the hugetlb_cgroup limit down to hugepage size.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -288,6 +288,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
+		nr_pages &= ~((1 << huge_page_order(&hstates[idx])) - 1);
 		mutex_lock(&hugetlb_limit_mutex);
 		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
 		mutex_unlock(&hugetlb_limit_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
