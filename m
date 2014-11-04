Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B19216B0085
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 20:30:44 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so13355875pab.38
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 17:30:44 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id b10si10280988pdm.209.2014.11.03.17.30.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 17:30:43 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so13385870pad.1
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 17:30:42 -0800 (PST)
Date: Mon, 3 Nov 2014 17:30:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: truncate prealloc blocks past i_size
In-Reply-To: <1414602608-1416-1-git-send-email-jbacik@fb.com>
Message-ID: <alpine.LSU.2.11.1411031710500.13943@eggly.anvils>
References: <1414602608-1416-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, 29 Oct 2014, Josef Bacik wrote:

> One of the rocksdb people noticed that when you do something like this
> 
> fallocate(fd, FALLOC_FL_KEEP_SIZE, 0, 10M)
> pwrite(fd, buf, 5M, 0)
> ftruncate(5M)
> 
> on tmpfs the file would still take up 10M, which lead to super fun issues
> because we were getting ENOSPC before we thought we should be getting ENOSPC.
> This patch fixes the problem, and mirrors what all the other fs'es do.  I tested
> it locally to make sure it worked properly with the following
> 
> xfs_io -f -c "falloc -k 0 10M" -c "pwrite 0 5M" -c "truncate 5M" file
> 
> Without the patch we have "Blocks: 20480", with the patch we have the correct
> value of "Blocks: 10240".  Thanks,
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

That is a very good catch, and thank you for the patch.  But I am not
convinced that the patch is correct - even if it does happen to end
up doing what other filesystems do here (I haven't checked).

Your patch makes it look like a fix to an off-by-one, but that is
not really the case.  What if you change your final ftruncate(5M)
to ftruncate(6M): what should happen then?

My intuition says that what should happen is that i_size is set to 6M,
and the fallocated excess blocks beyond 6M be trimmed off: so that
it's both an extending and a shrinking truncate at the same time.
And I think that behavior would be served by removing the
"if (newsize < oldsize)" condition completely.

But perhaps I'm wrong: can you or anyone shed more light on this,
or point to documentation of what should happen in these cases?

Thanks,
Hugh

> ---
>  mm/shmem.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 185836b..79b7fb5 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -574,7 +574,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
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
