Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4696B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:05:05 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so16347208pdb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:05:05 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id w4si1869302pbt.157.2015.03.24.22.05.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 22:05:04 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NLR001A04SDSL60@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 25 Mar 2015 14:05:01 +0900 (KST)
Message-id: <5512421D.4000603@samsung.com>
Date: Wed, 25 Mar 2015 14:05:33 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/2] zsmalloc: do not remap dst page while prepare next src
 page
References: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1427210687-6634-2-git-send-email-sergey.senozhatsky@gmail.com>
In-reply-to: <1427210687-6634-2-git-send-email-sergey.senozhatsky@gmail.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, sunae.seo@samsung.com, cmlaika.kim@samsung.com

Hello,

On 03/25/2015 12:24 AM, Sergey Senozhatsky wrote:
> object may belong to different pages. zs_object_copy() handles
> this case and maps a new source page (get_next_page() and
> kmap_atomic()) when object crosses boundaries of the current
> source page. But it also performs unnecessary kunmap/kmap_atomic
> of the destination page (it remains unchanged), which can be
> avoided.

No, it's not unnecessary. We should do kunmap_atomic() in the reverse
order of kmap_atomic(), so unfortunately it's inevitable to
kunmap_atomic() both on d_addr and s_addr.

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index d920e8b..7af4456 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1536,12 +1536,10 @@ static void zs_object_copy(unsigned long src, unsigned long dst,
>  			break;
>  
>  		if (s_off + size >= PAGE_SIZE) {
> -			kunmap_atomic(d_addr);
>  			kunmap_atomic(s_addr);

Removing kunmap_atomic(d_addr) here may cause BUG_ON() at __kunmap_atomic().

I tried yours to see it really happens:
> kernel BUG at arch/arm/mm/highmem.c:113!
> Internal error: Oops - BUG: 0 [#1] SMP ARM
> Modules linked in:
> CPU: 2 PID: 1774 Comm: bash Not tainted 4.0.0-rc2-mm1+ #105
> Hardware name: ARM-Versatile Express
> task: ee971300 ti: e8a26000 task.ti: e8a26000
> PC is at __kunmap_atomic+0x144/0x14c
> LR is at zs_object_copy+0x19c/0x2dc

regards
heesub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
