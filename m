Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBA566B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 19:54:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so284626373pfy.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 16:54:57 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id ya3si755054pab.2.2016.04.25.16.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 16:54:57 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id y69so53065825pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 16:54:56 -0700 (PDT)
Date: Mon, 25 Apr 2016 16:54:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3] mm, hugetlb_cgroup: round limit_in_bytes down to hugepage
 size
In-Reply-To: <20160425145223.22617d4c1f12b0f7f4702988@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1604251654380.31930@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com> <5704BA37.2080508@kyup.com> <5704BBBF.8040302@kyup.com> <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com> <20160407125145.GD32755@dhcp22.suse.cz>
 <alpine.DEB.2.10.1604141321350.6593@chino.kir.corp.google.com> <20160415132451.GL32377@dhcp22.suse.cz> <alpine.DEB.2.10.1604181422220.23710@chino.kir.corp.google.com> <20160425145223.22617d4c1f12b0f7f4702988@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The page_counter rounds limits down to page size values.  This makes
sense, except in the case of hugetlb_cgroup where it's not possible to
charge partial hugepages.  If the hugetlb_cgroup margin is less than the
hugepage size being charged, it will fail as expected.

Round the hugetlb_cgroup limit down to hugepage size, since it is the
effective limit of the cgroup.

For consistency, round down PAGE_COUNTER_MAX as well when a
hugetlb_cgroup is created: this prevents error reports when a user cannot
restore the value to the kernel default.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v3: update changelog per akpm
     no stable backport needed

 mm/hugetlb_cgroup.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -67,26 +67,42 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 	return false;
 }
 
+static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
+				struct hugetlb_cgroup *parent_h_cgroup)
+{
+	int idx;
+
+	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
+		struct page_counter *counter = &h_cgroup->hugepage[idx];
+		struct page_counter *parent = NULL;
+		unsigned long limit;
+		int ret;
+
+		if (parent_h_cgroup)
+			parent = &parent_h_cgroup->hugepage[idx];
+		page_counter_init(counter, parent);
+
+		limit = round_down(PAGE_COUNTER_MAX,
+				   1 << huge_page_order(&hstates[idx]));
+		ret = page_counter_limit(counter, limit);
+		VM_BUG_ON(ret);
+	}
+}
+
 static struct cgroup_subsys_state *
 hugetlb_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct hugetlb_cgroup *parent_h_cgroup = hugetlb_cgroup_from_css(parent_css);
 	struct hugetlb_cgroup *h_cgroup;
-	int idx;
 
 	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
 	if (!h_cgroup)
 		return ERR_PTR(-ENOMEM);
 
-	if (parent_h_cgroup) {
-		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			page_counter_init(&h_cgroup->hugepage[idx],
-					  &parent_h_cgroup->hugepage[idx]);
-	} else {
+	if (!parent_h_cgroup)
 		root_h_cgroup = h_cgroup;
-		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			page_counter_init(&h_cgroup->hugepage[idx], NULL);
-	}
+
+	hugetlb_cgroup_init(h_cgroup, parent_h_cgroup);
 	return &h_cgroup->css;
 }
 
@@ -285,6 +301,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		return ret;
 
 	idx = MEMFILE_IDX(of_cft(of)->private);
+	nr_pages = round_down(nr_pages, 1 << huge_page_order(&hstates[idx]));
 
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
