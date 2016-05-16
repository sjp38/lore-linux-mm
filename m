Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF4D46B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 07:59:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so41738573wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:59:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si38243664wjh.93.2016.05.16.04.59.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 04:59:11 -0700 (PDT)
Subject: Re: [PATCH] tmpfs: don't undo fallocate past its last page
References: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739B60E.1090700@suse.cz>
Date: Mon, 16 May 2016 13:59:10 +0200
MIME-Version: 1.0
In-Reply-To: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Romano <anthony.romano@coreos.com>, hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/08/2016 03:16 PM, Anthony Romano wrote:
> When fallocate is interrupted it will undo a range that extends one byte
> past its range of allocated pages. This can corrupt an in-use page by
> zeroing out its first byte. Instead, undo using the inclusive byte range.

Huh, good catch. So why is shmem_undo_range() adding +1 to the value in 
the first place? The only other caller is shmem_truncate_range() and all 
*its* callers do subtract 1 to avoid the same issue. So a nicer fix 
would be to remove all this +1/-1 madness. Or is there some subtle 
corner case I'm missing?

> Signed-off-by: Anthony Romano <anthony.romano@coreos.com>

Looks like a stable candidate patch. Can you point out the commit that 
introduced the bug, for the Fixes: tag?

Thanks,
Vlastimil

> ---
>   mm/shmem.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 719bd6b..f0f9405 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>   			/* Remove the !PageUptodate pages we added */
>   			shmem_undo_range(inode,
>   				(loff_t)start << PAGE_SHIFT,
> -				(loff_t)index << PAGE_SHIFT, true);
> +				((loff_t)index << PAGE_SHIFT) - 1, true);
>   			goto undone;
>   		}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
