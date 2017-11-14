Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8F746B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 15:04:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t10so21298369pgo.20
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:04:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a61si10876592plc.309.2017.11.14.12.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 12:04:54 -0800 (PST)
Subject: [PATCH v2 2/4] mm: fail get_vaddr_frames() for filesystem-dax
 mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 14 Nov 2017 11:56:39 -0800
Message-ID: <151068939985.7446.15684639617389154187.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Joonyoung Shim <jy0922.shim@samsung.com>, linux-nvdimm@lists.01.org, Seung-Woo Kim <sw0312.kim@samsung.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Inki Dae <inki.dae@samsung.com>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-media@vger.kernel.org

Until there is a solution to the dma-to-dax vs truncate problem it is
not safe to allow V4L2, Exynos, and other frame vector users to create
long standing / irrevocable memory registrations against filesytem-dax
vmas.

Cc: Inki Dae <inki.dae@samsung.com>
Cc: Seung-Woo Kim <sw0312.kim@samsung.com>
Cc: Joonyoung Shim <jy0922.shim@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: linux-media@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/frame_vector.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 72ebec18629c..d2fdbeaadc8b 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -52,6 +52,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		ret = -EFAULT;
 		goto out;
 	}
+
+	if (vma_is_fsdax(vma))
+		return -EOPNOTSUPP;
+
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
 		vec->is_pfns = false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
