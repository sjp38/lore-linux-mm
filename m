Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EB54A6B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 17:08:39 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id w10so461352pde.22
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 14:08:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r15si24996295pdj.62.2014.09.29.14.08.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 14:08:37 -0700 (PDT)
Date: Mon, 29 Sep 2014 14:08:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [kbuild] [mmotm:master 57/427] fs/ocfs2/journal.c:2204:9:
 sparse: context imbalance in 'ocfs2_recover_orphans' - different lock
 contexts for basic block
Message-Id: <20140929140834.99ceb99a2bb2e0503e750ea7@linux-foundation.org>
In-Reply-To: <20140926143636.GA3414@mwanda>
References: <20140926143636.GA3414@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kbuild@01.org, WeiWei Wang <wangww631@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 26 Sep 2014 17:36:37 +0300 Dan Carpenter <dan.carpenter@oracle.com> wrote:

> commit: 8a09937cacc099da21313223443237cbc84d5876 [57/427] ocfs2: add orphan recovery types in ocfs2_recover_orphans
>
> ...
>
> >> fs/ocfs2/journal.c:2204:9: sparse: context imbalance in 'ocfs2_recover_orphans' - different lock contexts for basic block
> 

this?

--- a/fs/ocfs2/journal.c~ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans-fix
+++ a/fs/ocfs2/journal.c
@@ -2160,8 +2160,7 @@ static int ocfs2_recover_orphans(struct
 			ret = ocfs2_inode_lock(inode, &di_bh, 1);
 			if (ret) {
 				mlog_errno(ret);
-				spin_unlock(&oi->ip_lock);
-				goto out;
+				goto out_unlock;
 			}
 			ocfs2_truncate_file(inode, di_bh, i_size_read(inode));
 			ocfs2_inode_unlock(inode, 1);
@@ -2173,14 +2172,13 @@ static int ocfs2_recover_orphans(struct
 					OCFS2_INODE_DEL_FROM_ORPHAN_CREDITS);
 			if (IS_ERR(handle)) {
 				ret = PTR_ERR(handle);
-				goto out;
+				goto out_unlock;
 			}
 			ret = ocfs2_del_inode_from_orphan(osb, handle, inode);
 			if (ret) {
 				mlog_errno(ret);
 				ocfs2_commit_trans(osb, handle);
-				spin_unlock(&oi->ip_lock);
-				goto out;
+				goto out_unlock;
 			}
 			ocfs2_commit_trans(osb, handle);
 		}
@@ -2200,7 +2198,10 @@ static int ocfs2_recover_orphans(struct
 		inode = iter;
 	}
 
-out:
+	return ret;
+
+out_unlock:
+	spin_unlock(&oi->ip_lock);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
