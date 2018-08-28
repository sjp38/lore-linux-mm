Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A160C6B4874
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:39:10 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 4-v6so2094862wra.18
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:39:10 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x78-v6si2287291wmd.159.2018.08.28.15.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 15:39:09 -0700 (PDT)
Subject: Re: Tagged pointers in the XArray
References: <20180828222727.GD11400@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fc15502d-8bf3-b7e3-af82-4645dc84e9cd@infradead.org>
Date: Tue, 28 Aug 2018 15:39:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180828222727.GD11400@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Just a question, please...

On 08/28/2018 03:27 PM, Matthew Wilcox wrote:
> 
> diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> index c74556ea4258..d1b383f3063f 100644
> --- a/include/linux/xarray.h
> +++ b/include/linux/xarray.h
> @@ -150,6 +150,54 @@ static inline int xa_err(void *entry)
>  	return 0;
>  }
>  
> +/**
> + * xa_tag_pointer() - Create an XArray entry for a tagged pointer.
> + * @p: Plain pointer.
> + * @tag: Tag value (0, 1 or 3).
> + *

What's wrong with a tag value of 2?

and what happens when one is used?  [I don't see anything preventing that.]


> + * If the user of the XArray prefers, they can tag their pointers instead
> + * of storing value entries.  Three tags are available (0, 1 and 3).
> + * These are distinct from the xa_tag_t as they are not replicated up
> + * through the array and cannot be searched for.
> + *
> + * Context: Any context.
> + * Return: An XArray entry.
> + */
> +static inline void *xa_tag_pointer(void *p, unsigned long tag)
> +{
> +	return (void *)((unsigned long)p | tag);
> +}
> +
> +/**
> + * xa_untag_pointer() - Turn an XArray entry into a plain pointer.
> + * @entry: XArray entry.
> + *
> + * If you have stored a tagged pointer in the XArray, call this function
> + * to get the untagged version of the pointer.
> + *
> + * Context: Any context.
> + * Return: A pointer.
> + */
> +static inline void *xa_untag_pointer(void *entry)
> +{
> +	return (void *)((unsigned long)entry & ~3UL);
> +}
> +
> +/**
> + * xa_pointer_tag() - Get the tag stored in an XArray entry.
> + * @entry: XArray entry.
> + *
> + * If you have stored a tagged pointer in the XArray, call this function
> + * to get the tag of that pointer.
> + *
> + * Context: Any context.
> + * Return: A tag.
> + */
> +static inline unsigned int xa_pointer_tag(void *entry)
> +{
> +	return (unsigned long)entry & 3UL;
> +}

thanks,
-- 
~Randy
