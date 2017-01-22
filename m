Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2F596B0038
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 17:25:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 14so177463069pgg.4
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 14:25:38 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h88si13654524pfk.4.2017.01.22.14.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 14:25:37 -0800 (PST)
Subject: Re: [PATCH] mm: do not export ioremap_page_range symbol for external
 module
References: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <af4a9fec-03c8-d977-6fa6-a36f222e21ef@nvidia.com>
Date: Sun, 22 Jan 2017 14:25:36 -0800
MIME-Version: 1.0
In-Reply-To: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, minchan@kernel.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/22/2017 04:58 AM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> Recently, I find the ioremap_page_range had been abusing. The improper
> address mapping is a issue. it will result in the crash. so, remove
> the symbol. It can be replaced by the ioremap_cache or others symbol.

Hi Zhong,

After thinking about this for a bit, and looking through our own (out-of-tree) kernel modules, I 
think you have a good point. I just can't see any reason for a driver to call ioremap_page_range 
directly. So the code change looks good to me.

For the commit description, here is a proposed re-wording, optional, that perhaps may be a little 
clearer. See if you like it?

-------
Recently, I've found cases in which ioremap_page_range was used incorrectly, in external modules, 
leading to crashes. This can be partly attributed to the fact that ioremap_page_range is 
lower-level, with fewer protections, as compared to the other functions that an external module 
would typically call. Those include:

         ioremap_cache
         ioremap_nocache
         ioremap_prot
         ioremap_uc
         ioremap_wc
         ioremap_wt

...each of which wraps __ioremap_caller, which in turn provides a safer way to achieve the mapping.

Therefore, stop EXPORT-ing ioremap_page_range.
-------

I may get some heat for this if another out-of-tree driver needs that symbol, but if no one else 
pops up and shrieks, you can add:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
john h


>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  lib/ioremap.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 86c8911..a3e14ce 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
>
>  	return err;
>  }
> -EXPORT_SYMBOL_GPL(ioremap_page_range);
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
