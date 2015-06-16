Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 86B076B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 16:02:42 -0400 (EDT)
Received: by wiga1 with SMTP id a1so118959321wig.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:02:41 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id b4si557349wic.47.2015.06.16.13.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 13:02:41 -0700 (PDT)
Received: by wicnd19 with SMTP id nd19so8368143wic.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:02:40 -0700 (PDT)
Date: Tue, 16 Jun 2015 13:02:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: truncate at i_size
In-Reply-To: <1432049251-3298-1-git-send-email-jbacik@fb.com>
Message-ID: <alpine.LSU.2.11.1506161256490.1050@eggly.anvils>
References: <1432049251-3298-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 19 May 2015, Josef Bacik wrote:

> If we fallocate past i_size with KEEP_SIZE, extend the file to use some but not
> all of this space, and then truncate(i_size) we won't trim the excess
> preallocated space.  We decided at LSF that we want to truncate the fallocated
> bit past i_size when we truncate to i_size, which is what this patch does.
> Thanks,
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Sorry for the delay, it's been on my mind but only now I get to it.
Yes, that was agreed at LSF, and I've checked that indeed tmpfs is
out of line here: thank you for fixing it.  But I do prefer your
original more explicit description, so I'll send the patch to akpm
now for v4.2, with that description instead (plus a reference to LSF).

Thanks,
Hugh

> ---
>  mm/shmem.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index de98137..089afde 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -569,7 +569,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
>  			i_size_write(inode, newsize);
>  			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
>  		}
> -		if (newsize < oldsize) {
> +		if (newsize <= oldsize) {
>  			loff_t holebegin = round_up(newsize, PAGE_SIZE);
>  			unmap_mapping_range(inode->i_mapping, holebegin, 0, 1);
>  			shmem_truncate_range(inode, newsize, (loff_t)-1);
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
