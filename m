Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D1C686B0039
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:07:56 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so7690888pdj.15
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:07:56 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id yj4si7048553pac.95.2014.08.08.15.07.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 15:07:56 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so7723765pde.9
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:07:55 -0700 (PDT)
Date: Fri, 8 Aug 2014 15:07:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, hugetlb_cgroup: align hugetlb cgroup limit to hugepage
 size
In-Reply-To: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1408081507180.15603@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memcg aligns memory.limit_in_bytes to PAGE_SIZE as part of the resource counter
since it makes no sense to allow a partial page to be charged.

As a result of the hugetlb cgroup using the resource counter, it is also aligned
to PAGE_SIZE but makes no sense unless aligned to the size of the hugepage being
limited.

Align hugetlb cgroup limit to hugepage size.

Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: use huge_page_order() per Aneesh
     Sorry for not cc'ing you initially, get_maintainer.pl failed me

 mm/hugetlb_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -275,6 +275,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		ret = res_counter_memparse_write_strategy(buf, &val);
 		if (ret)
 			break;
+		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
 		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
 		break;
 	default:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
