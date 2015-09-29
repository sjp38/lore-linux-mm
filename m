Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 66F9B6B0255
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 18:57:13 -0400 (EDT)
Received: by qgt47 with SMTP id 47so20437308qgt.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:57:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b66si12549654qkb.102.2015.09.29.15.57.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 15:57:12 -0700 (PDT)
Date: Tue, 29 Sep 2015 15:57:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] fs: charge pipe buffers to memcg
Message-Id: <20150929155711.3b139dab622848a14af64ca4@linux-foundation.org>
In-Reply-To: <94f055dc719129a26149b0f8b22af7c61a3fb4e6.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
	<94f055dc719129a26149b0f8b22af7c61a3fb4e6.1443262808.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 26 Sep 2015 13:45:54 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> Pipe buffers can be generated unrestrictedly by an unprivileged
> userspace process, so they shouldn't go unaccounted.
> 
> ...
>
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -400,7 +400,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
>  			int copied;
>  
>  			if (!page) {
> -				page = alloc_page(GFP_HIGHUSER);
> +				page = alloc_kmem_pages(GFP_HIGHUSER, 0);
>  				if (unlikely(!page)) {
>  					ret = ret ? : -ENOMEM;
>  					break;

This seems broken.  We have a page buffer page which has a weird
->mapcount.  Now it gets stolen (generic_pipe_buf_steal()) and spliced
into pagecache.  Then the page gets mmapped and MM starts playing with
its ->_mapcount?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
