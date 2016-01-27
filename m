Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCDD6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:59:14 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so27711384wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:59:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id km4si8615452wjc.232.2016.01.27.05.59.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 05:59:13 -0800 (PST)
Subject: Re: [PATCH v1] mm/madvise: pass return code of memory_failure() to
 userspace
References: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8CD2F.5080903@suse.cz>
Date: Wed, 27 Jan 2016 14:59:11 +0100
MIME-Version: 1.0
In-Reply-To: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Gong <gong.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>

[CC += linux-api, linux-man]

On 01/22/2016 09:27 AM, Naoya Horiguchi wrote:
> Currently the return value of memory_failure() is not passed to userspace, which
> is inconvenient for test programs that want to know the result of error handling.
> So let's return it to the caller as we already do in MADV_SOFT_OFFLINE case.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/madvise.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git v4.4-mmotm-2016-01-20-16-10/mm/madvise.c v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
> index f56825b..6a77114 100644
> --- v4.4-mmotm-2016-01-20-16-10/mm/madvise.c
> +++ v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
> @@ -555,8 +555,9 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
>  		}
>  		pr_info("Injecting memory failure for page %#lx at %#lx\n",
>  		       page_to_pfn(p), start);
> -		/* Ignore return value for now */
> -		memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
> +		ret = memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
> +		if (ret)
> +			return ret;

Can you explain what madvise can newly return for MADV_HWPOISON in which
situations, for the purposes of updated man page?

Thanks,
Vlastimil

>  	}
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
