Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1906B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 03:02:30 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so8502427pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 00:02:30 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id am7si7598652pad.150.2015.06.09.00.02.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 00:02:29 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id AF001AC033E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:02:25 +0900 (JST)
Message-ID: <55768F59.8040708@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 16:01:45 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 07/12] mm: introduce __GFP_MIRROR to allocate mirrored
 pages
References: <55704A7E.5030507@huawei.com> <55704C4D.9070508@huawei.com>
In-Reply-To: <55704C4D.9070508@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 22:02, Xishi Qiu wrote:
> This patch introduces a new gfp flag called "__GFP_MIRROR", it is used to
> allocate mirrored pages through buddy system.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

In Tony's original proposal, the motivation was to mirror all kernel memory.

Is the purpose of this patch making mirrored range available for user space ?

But, hmm... I don't think adding a new GFP flag is a good idea. It adds many conditional jumps.

How about using GFP_KERNEL for user memory if the user wants mirrored memory with mirroring
all kernel memory?

Thanks,
-Kame

> ---
>   include/linux/gfp.h | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 15928f0..89d0091 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -35,6 +35,7 @@ struct vm_area_struct;
>   #define ___GFP_NO_KSWAPD	0x400000u
>   #define ___GFP_OTHER_NODE	0x800000u
>   #define ___GFP_WRITE		0x1000000u
> +#define ___GFP_MIRROR		0x2000000u
>   /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>
>   /*
> @@ -95,13 +96,15 @@ struct vm_area_struct;
>   #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
>   #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
>
> +#define __GFP_MIRROR	((__force gfp_t)___GFP_MIRROR)	/* Allocate mirrored memory */
> +
>   /*
>    * This may seem redundant, but it's a way of annotating false positives vs.
>    * allocations that simply cannot be supported (e.g. page tables).
>    */
>   #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>
> -#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
>   #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>
>   /* This equals 0, but use constants in case they ever change */
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
