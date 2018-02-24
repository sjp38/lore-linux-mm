Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3241B6B000E
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 19:52:45 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id a61so4578250pla.22
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 16:52:45 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id z2si2182516pgn.768.2018.02.23.16.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 16:52:44 -0800 (PST)
Subject: [PATCH v3 5/6] dax: short circuit vma_is_fsdax() in the
 CONFIG_FS_DAX=n case
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 23 Feb 2018 16:43:37 -0800
Message-ID: <151943301788.29249.13371602951635567379.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>

Do not bother looking up the file type in the case when Filesystem-DAX
is disabled at build time.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7418341578a3..c97fc4dbaae1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3197,6 +3197,8 @@ static inline bool vma_is_fsdax(struct vm_area_struct *vma)
 
 	if (!vma->vm_file)
 		return false;
+	if (!IS_ENABLED(CONFIG_FS_DAX))
+		return false;
 	if (!vma_is_dax(vma))
 		return false;
 	inode = file_inode(vma->vm_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
