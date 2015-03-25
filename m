Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B6BAB6B006C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 10:35:18 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so30809288pad.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:35:18 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id wo4si3903362pbc.243.2015.03.25.07.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 07:35:17 -0700 (PDT)
Received: by pagj7 with SMTP id j7so30901545pag.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:35:17 -0700 (PDT)
Date: Wed, 25 Mar 2015 23:35:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix fatal corruption due to wrong size class
 selection
Message-ID: <20150325143442.GA3814@blaptop>
References: <1427281092-10116-1-git-send-email-heesub.shin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427281092-10116-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sunae Seo <sunae.seo@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sooyong Suk <s.suk@samsung.com>

Hello Heesub,

On Wed, Mar 25, 2015 at 07:58:12PM +0900, Heesub Shin wrote:
> There is no point in overriding the size class below. It causes fatal
> corruption on the next chunk on the 3264-bytes size class, which is the
> last size class that is not huge.
> 
> For example, if the requested size was exactly 3264 bytes, current
> zsmalloc allocates and returns a chunk from the size class of 3264
> bytes, not 4096. User access to this chunk may overwrite head of the
> next adjacent chunk.
> 
> Here is the panic log captured when freelist was corrupted due to this:
> 
>     Kernel BUG at ffffffc00030659c [verbose debug info unavailable]
>     Internal error: Oops - BUG: 96000006 [#1] PREEMPT SMP
>     Modules linked in:
>     exynos-snapshot: core register saved(CPU:5)
>     CPUMERRSR: 0000000000000000, L2MERRSR: 0000000000000000
>     exynos-snapshot: context saved(CPU:5)
>     exynos-snapshot: item - log_kevents is disabled
>     CPU: 5 PID: 898 Comm: kswapd0 Not tainted 3.10.61-4497415-eng #1
>     task: ffffffc0b8783d80 ti: ffffffc0b71e8000 task.ti: ffffffc0b71e8000
>     PC is at obj_idx_to_offset+0x0/0x1c
>     LR is at obj_malloc+0x44/0xe8
>     pc : [<ffffffc00030659c>] lr : [<ffffffc000306604>] pstate: a0000045
>     sp : ffffffc0b71eb790
>     x29: ffffffc0b71eb790 x28: ffffffc00204c000
>     x27: 000000000001d96f x26: 0000000000000000
>     x25: ffffffc098cc3500 x24: ffffffc0a13f2810
>     x23: ffffffc098cc3501 x22: ffffffc0a13f2800
>     x21: 000011e1a02006e3 x20: ffffffc0a13f2800
>     x19: ffffffbc02a7e000 x18: 0000000000000000
>     x17: 0000000000000000 x16: 0000000000000feb
>     x15: 0000000000000000 x14: 00000000a01003e3
>     x13: 0000000000000020 x12: fffffffffffffff0
>     x11: ffffffc08b264000 x10: 00000000e3a01004
>     x9 : ffffffc08b263fea x8 : ffffffc0b1e611c0
>     x7 : ffffffc000307d24 x6 : 0000000000000000
>     x5 : 0000000000000038 x4 : 000000000000011e
>     x3 : ffffffbc00003e90 x2 : 0000000000000cc0
>     x1 : 00000000d0100371 x0 : ffffffbc00003e90
> 
> Reported-by: Sooyong Suk <s.suk@samsung.com>
> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
> Tested-by: Sooyong Suk <s.suk@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>

I am wondering how you encounter this error.
zRAM passes uncompressed page(ie, PAGE_SIZE) to zsmalloc
once it found result of compressed size is above than PAGE_SIZE * 3 /4.
Maybe, that's was a reason I couldn't see during testing.

Anyway, It's nice catch. Thanks, Heesub.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
