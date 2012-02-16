Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 545566B00E8
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:52 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/11] cifs: Push file_update_time() into cifs_page_mkwrite()
Date: Thu, 16 Feb 2012 14:46:13 +0100
Message-Id: <1329399979-3647-6-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org

CC: Steve French <sfrench@samba.org>
CC: linux-cifs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/cifs/file.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

  BTW: How does cifs_page_mkwrite() protect against races with truncate?
See e.g. checks in __block_page_mkwrite()...

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 4dd9283..8e3b23b 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2425,6 +2425,9 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 
+	/* Update file times before taking page lock */
+	file_update_time(vma->vm_file);
+
 	lock_page(page);
 	return VM_FAULT_LOCKED;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
