Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 404246B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 18:08:29 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id r129so2525647wmr.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 15:08:29 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id o123si7048567wmd.53.2016.01.22.15.08.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 15:08:28 -0800 (PST)
Date: Fri, 22 Jan 2016 23:08:23 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs: use-after-free in link_path_walk
Message-ID: <20160122230823.GI17997@ZenIV.linux.org.uk>
References: <CACT4Y+YQBU5X2KVKmjR8F3YW2mY1aX6Y_yDzUamQgd2rAP2_AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YQBU5X2KVKmjR8F3YW2mY1aX6Y_yDzUamQgd2rAP2_AQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>

On Fri, Jan 22, 2016 at 11:33:09PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program triggers a use-after-free in link_path_walk:
> https://gist.githubusercontent.com/dvyukov/fc0da4b914d607ba8129/raw/b761243c44106d74f2173745132c82d179cbdc58/gistfile1.txt

Hmm...  Actually, I wonder if that had been triggerable since May.  What
happens is that unlike struct inode itself, shmem info->symlink is
freed immediately, without an RCU delay.  Easy to fix, fortunately...

Could you check if the patch below fixes that for you?

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index a43f41c..4d4780c 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -15,10 +15,7 @@ struct shmem_inode_info {
 	unsigned int		seals;		/* shmem seals */
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
-	union {
-		unsigned long	swapped;	/* subtotal assigned to swap */
-		char		*symlink;	/* unswappable short symlink */
-	};
+	unsigned long		swapped;	/* subtotal assigned to swap */
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
diff --git a/mm/shmem.c b/mm/shmem.c
index 38c5e72..440e2a7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -701,8 +701,7 @@ static void shmem_evict_inode(struct inode *inode)
 			list_del_init(&info->swaplist);
 			mutex_unlock(&shmem_swaplist_mutex);
 		}
-	} else
-		kfree(info->symlink);
+	}
 
 	simple_xattrs_free(&info->xattrs);
 	WARN_ON(inode->i_blocks);
@@ -2549,13 +2548,12 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	info = SHMEM_I(inode);
 	inode->i_size = len-1;
 	if (len <= SHORT_SYMLINK_LEN) {
-		info->symlink = kmemdup(symname, len, GFP_KERNEL);
-		if (!info->symlink) {
+		inode->i_link = kmemdup(symname, len, GFP_KERNEL);
+		if (!inode->i_link) {
 			iput(inode);
 			return -ENOMEM;
 		}
 		inode->i_op = &shmem_short_symlink_operations;
-		inode->i_link = info->symlink;
 	} else {
 		inode_nohighmem(inode);
 		error = shmem_getpage(inode, 0, &page, SGP_WRITE, NULL);
@@ -3132,6 +3130,7 @@ static struct inode *shmem_alloc_inode(struct super_block *sb)
 static void shmem_destroy_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
+	kfree(inode->i_link);
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
