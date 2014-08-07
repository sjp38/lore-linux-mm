Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9E66B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 16:34:15 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so6017500pac.31
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 13:34:15 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id xq1si4308899pbb.128.2014.08.07.13.34.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 13:34:14 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so5781661pdj.36
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 13:34:14 -0700 (PDT)
Date: Thu, 7 Aug 2014 13:34:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb_cgroup: align hugetlb cgroup limit to hugepage
 size
Message-ID: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memcg aligns memory.limit_in_bytes to PAGE_SIZE as part of the resource counter
since it makes no sense to allow a partial page to be charged.

As a result of the hugetlb cgroup using the resource counter, it is also aligned
to PAGE_SIZE but makes no sense unless aligned to the size of the hugepage being
limited.

Align hugetlb cgroup limit to hugepage size.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb_cgroup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -275,6 +275,8 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		ret = res_counter_memparse_write_strategy(buf, &val);
 		if (ret)
 			break;
+		val = ALIGN(val, 1 << (huge_page_order(&hstates[idx]) +
+				       PAGE_SHIFT));
 		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
 		break;
 	default:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
