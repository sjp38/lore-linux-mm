Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA186B0010
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 23:02:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o61-v6so4449386pld.5
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 20:02:46 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id l77si4151430pfk.210.2018.03.01.20.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 20:02:45 -0800 (PST)
Subject: [PATCH v5 01/12] dax: fix vma_is_fsdax() helper
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:53:38 -0800
Message-ID: <151996281881.28483.2616406435517031167.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: stable@vger.kernel.org, Gerd Rausch <gerd.rausch@oracle.com>, Jane Chu <jane.chu@oracle.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Jan Kara <jack@suse.cz>, linux-xfs@vger.kernel.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Gerd reports that ->i_mode may contain other bits besides S_IFCHR. Use
S_ISCHR() instead. Otherwise, get_user_pages_longterm() may fail on
device-dax instances when those are meant to be explicitly allowed.

Fixes: 2bb6d2837083 ("mm: introduce get_user_pages_longterm")
Cc: <stable@vger.kernel.org>
Reported-by: Gerd Rausch <gerd.rausch@oracle.com>
Acked-by: Jane Chu <jane.chu@oracle.com>
Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2a815560fda0..79c413985305 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3198,7 +3198,7 @@ static inline bool vma_is_fsdax(struct vm_area_struct *vma)
 	if (!vma_is_dax(vma))
 		return false;
 	inode = file_inode(vma->vm_file);
-	if (inode->i_mode == S_IFCHR)
+	if (S_ISCHR(inode->i_mode))
 		return false; /* device-dax */
 	return true;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
