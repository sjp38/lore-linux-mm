Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D2DA96B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 05:35:08 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8211952dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 02:35:08 -0700 (PDT)
Message-ID: <4FB0D1C6.7090801@gmail.com>
Date: Mon, 14 May 2012 17:35:02 +0800
From: Cong Wang <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/10] tmpfs: enable NOSEC optimization
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120500040.28861@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205120500040.28861@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/12/2012 08:02 PM, Hugh Dickins wrote:
> Let tmpfs into the NOSEC optimization (avoiding file_remove_suid()
> overhead on most common writes): set MS_NOSEC on its superblocks.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   mm/shmem.c |    1 +
>   1 file changed, 1 insertion(+)
>
> --- 3045N.orig/mm/shmem.c	2012-05-05 10:45:17.888060878 -0700
> +++ 3045N/mm/shmem.c	2012-05-05 10:46:05.732062006 -0700
> @@ -2361,6 +2361,7 @@ int shmem_fill_super(struct super_block
>   		}
>   	}
>   	sb->s_export_op =&shmem_export_ops;
> +	sb->s_flags |= MS_NOSEC;

Isn't setting the flag on inode better? Something like:

diff --git a/mm/shmem.c b/mm/shmem.c
index f99ff3e..7d98fb5 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2325,6 +2325,7 @@ static void shmem_init_inode(void *foo)
  {
         struct shmem_inode_info *info = foo;
         inode_init_once(&info->vfs_inode);
+       info->vfs_inode.i_flags |= S_NOSEC;
  }

  static int shmem_init_inodecache(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
