Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC1E600363
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:16:53 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2I08wGE008915
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:08:58 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2I0Go5D069580
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:16:51 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2I0GnIt015576
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:16:50 -0600
Date: Wed, 17 Mar 2010 16:37:53 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [C/R v20][PATCH 46/96] c/r: add checkpoint operation for
 opened files of generic filesystems
Message-ID: <20100317233753.GJ3037@count0.beaverton.ibm.com>
References: <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6@sun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6@sun.com>
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <adilger@sun.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 03:09:00PM -0600, Andreas Dilger wrote:

<snip> (already responded to the first part)

> >static const struct vm_operations_struct nfs_file_vm_ops = {
> >	.fault = filemap_fault,
> >	.page_mkwrite = nfs_vm_page_mkwrite,
> >+#ifdef CONFIG_CHECKPOINT
> >+	.checkpoint = filemap_checkpoint,
> >+#endif
> >};
> 
> Why is this one conditional, but the others are not?

Something like this perhaps (untested, but it should work).

    Move empty filemap_checkpoint definition
    
    This makes the operation usable in the nfs vm operation structure
    and avoids the extra #ifdef.
    
    Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
    Cc: Andreas Dilger <adilger@sun.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4437ef9..c6f9090 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -578,9 +578,7 @@ out_unlock:
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = nfs_vm_page_mkwrite,
-#ifdef CONFIG_CHECKPOINT
 	.checkpoint = filemap_checkpoint,
-#endif
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 210d8e3..e9d9605 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1206,6 +1206,8 @@ extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
 #ifdef CONFIG_CHECKPOINT
 /* generic vm_area_ops exported for mapped files checkpoint */
 extern int filemap_checkpoint(struct ckpt_ctx *, struct vm_area_struct *);
+#else /* !CONFIG_CHECKPOINT */
+#define filemap_checkpoint NULL
 #endif
 
 /* mm/page-writeback.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 4ea28e6..bc98a15 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1678,8 +1678,6 @@ int filemap_restore(struct ckpt_ctx *ctx,
 	}
 	return ret;
 }
-#else /* !CONFIG_CHECKPOINT */
-#define filemap_checkpoint NULL
 #endif
 
 const struct vm_operations_struct generic_file_vm_ops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
