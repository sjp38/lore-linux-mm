Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFA66B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 18:09:45 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id l13so25096284iga.5
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 15:09:45 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id h2si7558683icu.107.2015.01.21.15.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 15:09:44 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so10908240igb.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 15:09:43 -0800 (PST)
Date: Wed, 21 Jan 2015 15:09:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/util.c: add a none zero check of "len"
In-Reply-To: <54BE0FB3.1030008@intel.com>
Message-ID: <alpine.DEB.2.10.1501211506120.2716@chino.kir.corp.google.com>
References: <54BE0FB3.1030008@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pan Xinhui <xinhuix.pan@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, bill.c.roberts@gmail.com, yanmin_zhang@linux.intel.com

On Tue, 20 Jan 2015, Pan Xinhui wrote:

> Although this check should have been done by caller. But as it's exported to
> others,
> It's better to add a none zero check of "len" like other functions.
> 
> Signed-off-by: xinhuix.pan <xinhuix.pan@intel.com>
> ---
>  mm/util.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/util.c b/mm/util.c
> index fec39d4..3dc2873 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -72,6 +72,9 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
>  {
>  	void *p;
>  +	if (unlikely(!len))
> +		return ERR_PTR(-EINVAL);
> +
>  	p = kmalloc_track_caller(len, gfp);
>  	if (p)
>  		memcpy(p, src, len);
> @@ -91,6 +94,8 @@ void *memdup_user(const void __user *src, size_t len)
>  {
>  	void *p;
>  +	if (unlikely(!len))
> +		return ERR_PTR(-EINVAL);
>  	/*
>  	 * Always use GFP_KERNEL, since copy_from_user() can sleep and
>  	 * cause pagefault, which makes it pointless to use GFP_NOFS

Nack, there's no need for this since both slab and slub check for 
ZERO_OR_NULL_PTR() and kmalloc_slab() will return ZERO_SIZE_PTR in these 
cases.  kmemdup() would then return NULL, which is appropriate since it 
doesn't return an ERR_PTR() even when memory cannot be allocated.  
memdup_user() would return -ENOMEM for size == 0, which would arguably be 
the wrong return value, but I don't think we need to slow down either of 
these library functions to check for something as stupid as duplicating 
size == 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
