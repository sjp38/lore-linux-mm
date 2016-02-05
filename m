Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E45A24403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 08:33:29 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so27268092wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 05:33:29 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id o11si24225526wjw.191.2016.02.05.05.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 05:33:28 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id p63so26754651wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 05:33:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160122230823.GI17997@ZenIV.linux.org.uk>
References: <CACT4Y+YQBU5X2KVKmjR8F3YW2mY1aX6Y_yDzUamQgd2rAP2_AQ@mail.gmail.com>
 <20160122230823.GI17997@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 5 Feb 2016 14:33:08 +0100
Message-ID: <CACT4Y+Y4e2gLbJAnNtaid3R_j_vM_e_1e6YuW0gRWPG2zA+w3Q@mail.gmail.com>
Subject: Re: fs: use-after-free in link_path_walk
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>

On Sat, Jan 23, 2016 at 12:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Jan 22, 2016 at 11:33:09PM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program triggers a use-after-free in link_path_walk:
>> https://gist.githubusercontent.com/dvyukov/fc0da4b914d607ba8129/raw/b761243c44106d74f2173745132c82d179cbdc58/gistfile1.txt
>
> Hmm...  Actually, I wonder if that had been triggerable since May.  What
> happens is that unlike struct inode itself, shmem info->symlink is
> freed immediately, without an RCU delay.  Easy to fix, fortunately...
>
> Could you check if the patch below fixes that for you?

Yes, it fixes the crash for me.
Thanks

> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index a43f41c..4d4780c 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -15,10 +15,7 @@ struct shmem_inode_info {
>         unsigned int            seals;          /* shmem seals */
>         unsigned long           flags;
>         unsigned long           alloced;        /* data pages alloced to file */
> -       union {
> -               unsigned long   swapped;        /* subtotal assigned to swap */
> -               char            *symlink;       /* unswappable short symlink */
> -       };
> +       unsigned long           swapped;        /* subtotal assigned to swap */
>         struct shared_policy    policy;         /* NUMA memory alloc policy */
>         struct list_head        swaplist;       /* chain of maybes on swap */
>         struct simple_xattrs    xattrs;         /* list of xattrs */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 38c5e72..440e2a7 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -701,8 +701,7 @@ static void shmem_evict_inode(struct inode *inode)
>                         list_del_init(&info->swaplist);
>                         mutex_unlock(&shmem_swaplist_mutex);
>                 }
> -       } else
> -               kfree(info->symlink);
> +       }
>
>         simple_xattrs_free(&info->xattrs);
>         WARN_ON(inode->i_blocks);
> @@ -2549,13 +2548,12 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
>         info = SHMEM_I(inode);
>         inode->i_size = len-1;
>         if (len <= SHORT_SYMLINK_LEN) {
> -               info->symlink = kmemdup(symname, len, GFP_KERNEL);
> -               if (!info->symlink) {
> +               inode->i_link = kmemdup(symname, len, GFP_KERNEL);
> +               if (!inode->i_link) {
>                         iput(inode);
>                         return -ENOMEM;
>                 }
>                 inode->i_op = &shmem_short_symlink_operations;
> -               inode->i_link = info->symlink;
>         } else {
>                 inode_nohighmem(inode);
>                 error = shmem_getpage(inode, 0, &page, SGP_WRITE, NULL);
> @@ -3132,6 +3130,7 @@ static struct inode *shmem_alloc_inode(struct super_block *sb)
>  static void shmem_destroy_callback(struct rcu_head *head)
>  {
>         struct inode *inode = container_of(head, struct inode, i_rcu);
> +       kfree(inode->i_link);
>         kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
