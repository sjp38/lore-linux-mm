Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0176B0005
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 20:49:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so205246899pad.2
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 17:49:56 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id a4si30396102pav.72.2016.07.24.17.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jul 2016 17:49:55 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hh10so10457783pac.1
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 17:49:55 -0700 (PDT)
Date: Mon, 25 Jul 2016 09:49:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: Delete an unnecessary check before the
 function call "iput"
Message-ID: <20160725004956.GA430@swordfish>
References: <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <559cf499-4a01-25f9-c87f-24d906626a57@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <559cf499-4a01-25f9-c87f-24d906626a57@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>

On (07/22/16 20:02), SF Markus Elfring wrote:
> The iput() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.

there is no issue; the change is just cosmetic.


> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>



alloc_anon_inode() returns ERR_PTR, so I'd probably rather
change iput() to do IS_ERR_OR_NULL instead of !NULL.

	inode = alloc_anon_inode();
	if (IS_ERR(inode)) {
		inode = NULL;
		^^^^^^^^^^^^^
	}
	...
	iput(inode);

this NULL assignment on error path is a bit fragile.

IOW, something like this

---

diff --git a/fs/inode.c b/fs/inode.c
index 559a9da..f1b7bd2 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1497,7 +1497,7 @@ static void iput_final(struct inode *inode)
  */
 void iput(struct inode *inode)
 {
-       if (!inode)
+       if (IS_ERR_OR_NULL(inode))
                return;
        BUG_ON(inode->i_state & I_CLEAR);
 retry:


---

	-ss

> ---
>  mm/zsmalloc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 5e5237c..7b5fd2b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -2181,8 +2181,7 @@ static int zs_register_migration(struct zs_pool *pool)
>  static void zs_unregister_migration(struct zs_pool *pool)
>  {
>  	flush_work(&pool->free_work);
> -	if (pool->inode)
> -		iput(pool->inode);
> +	iput(pool->inode);
>  }
>  
>  /*
> -- 
> 2.9.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
