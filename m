Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 91F9B6B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:44:44 -0500 (EST)
Received: by pasz6 with SMTP id z6so42182002pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:44:44 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id rq5si14744900pab.234.2015.11.11.12.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 12:44:17 -0800 (PST)
Received: by padhx2 with SMTP id hx2so40908358pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:44:17 -0800 (PST)
Date: Wed, 11 Nov 2015 12:44:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] tools/vm/page-types: suppress gcc warnings
In-Reply-To: <1447162326-30626-3-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.10.1511111242060.3565@chino.kir.corp.google.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, 10 Nov 2015, Sergey Senozhatsky wrote:

> Define 'end' and 'first' as volatile to suppress
> gcc warnings:
> 
> page-types.c:854:13: warning: variable 'end' might be
>    clobbered by 'longjmp' or 'vfork' [-Wclobbered]
> page-types.c:858:6: warning: variable 'first' might be
>    clobbered by 'longjmp' or 'vfork' [-Wclobbered]
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  tools/vm/page-types.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
> index bcf5ec7..0651cd5 100644
> --- a/tools/vm/page-types.c
> +++ b/tools/vm/page-types.c
> @@ -851,11 +851,12 @@ static void walk_file(const char *name, const struct stat *st)
>  	uint8_t vec[PAGEMAP_BATCH];
>  	uint64_t buf[PAGEMAP_BATCH], flags;
>  	unsigned long nr_pages, pfn, i;
> -	off_t off, end = st->st_size;
> +	off_t off;
>  	int fd;
>  	ssize_t len;
>  	void *ptr;
> -	int first = 1;
> +	volatile int first = 1;
> +	volatile off_t end = st->st_size;
>  
>  	fd = checked_open(name, O_RDONLY|O_NOATIME|O_NOFOLLOW);
>  

This can't possibly be correct, the warnings are legitimate and the result 
of the sigsetjmp() in the function.  You may be interested in 
returns_twice rather than marking random automatic variables as volatile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
