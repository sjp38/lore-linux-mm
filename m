Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBE06B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 00:04:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d132so139812346oib.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 21:04:17 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id c10si4446774oib.63.2016.10.12.21.04.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 21:04:16 -0700 (PDT)
Message-ID: <57FF061D.2030708@huawei.com>
Date: Thu, 13 Oct 2016 11:57:17 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] z3fold: fix the potential encode bug in encod_handle
References: <1476329585-15428-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1476329585-15428-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vitalywool@gmail.com, david@fromorbit.com, sjenning@redhat.com, ddstreet@ieee.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2016/10/13 11:33, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
> in encode_handle, it will lead to the the caller handle_to_buddy
> return the error value.
>
> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
> it will be consistent with handle_to_z3fold_header. At the same time,
> The code will much comprehensible to change the BUDDY_MASK to
> BUDDIES_MAX in handle_to_buddy.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/z3fold.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 8f9e89c..5884b9e 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -169,7 +169,7 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
>  
>  	handle = (unsigned long)zhdr;
>  	if (bud != HEADLESS)
> -		handle += (bud + zhdr->first_num) & BUDDY_MASK;
> +		handle += (bud + zhdr->first_num) & PAGE_MASK;
>  	return handle;
>  }
>  
> @@ -183,7 +183,7 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
>  static enum buddy handle_to_buddy(unsigned long handle)
>  {
>  	struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
> -	return (handle - zhdr->first_num) & BUDDY_MASK;
> +	return (handle - zhdr->first_num) & BUDDIES_MAX;
>  }
>  
>  /*
  oh,  a  obvious problem, please ignore it. I will resent the patch in v2.  Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
