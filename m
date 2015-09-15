Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE056B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 20:01:40 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so65470661qkd.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:01:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k62si14546796qgk.50.2015.09.14.17.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 17:01:39 -0700 (PDT)
Date: Tue, 15 Sep 2015 02:01:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: add missing mmput() in error path
Message-ID: <20150915000136.GD2191@redhat.com>
References: <1442188647-4233-1-git-send-email-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442188647-4233-1-git-send-email-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Eric,

On Sun, Sep 13, 2015 at 06:57:27PM -0500, Eric Biggers wrote:
> Signed-off-by: Eric Biggers <ebiggers3@gmail.com>
> ---
>  fs/userfaultfd.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 634e676..f9aeb40 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1287,8 +1287,10 @@ static struct file *userfaultfd_file_create(int flags)
>  
>  	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
>  				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
> -	if (IS_ERR(file))
> +	if (IS_ERR(file)) {
> +		mmput(ctx->mm);
>  		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
> +	}
>  out:
>  	return file;
>  }

This bug would have generated a memleak in the error code path (which
could only run if running out of files or memory, unfortunately not a
condition that gets routinely exercised).

It's great you spotted it now, we can fix it before final 4.3. I'll
forward it to Andrew to be sure it's not missed.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
