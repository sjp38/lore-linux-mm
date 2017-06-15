Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9A1B6B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:05:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y39so5039261wry.10
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:05:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g89si272001wrd.274.2017.06.15.14.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:05:25 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:05:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/list_lru.c: use cond_resched_lock() for nlru->lock
Message-Id: <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
In-Reply-To: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
References: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Mon, 12 Jun 2017 06:17:20 +0530 Sahitya Tummala <stummala@codeaurora.org> wrote:

> __list_lru_walk_one() can hold the spin lock for longer duration
> if there are more number of entries to be isolated.
> 
> This results in "BUG: spinlock lockup suspected" in the below path -
> 
> [<ffffff8eca0fb0bc>] spin_bug+0x90
> [<ffffff8eca0fb220>] do_raw_spin_lock+0xfc
> [<ffffff8ecafb7798>] _raw_spin_lock+0x28
> [<ffffff8eca1ae884>] list_lru_add+0x28
> [<ffffff8eca1f5dac>] dput+0x1c8
> [<ffffff8eca1eb46c>] path_put+0x20
> [<ffffff8eca1eb73c>] terminate_walk+0x3c
> [<ffffff8eca1eee58>] path_lookupat+0x100
> [<ffffff8eca1f00fc>] filename_lookup+0x6c
> [<ffffff8eca1f0264>] user_path_at_empty+0x54
> [<ffffff8eca1e066c>] SyS_faccessat+0xd0
> [<ffffff8eca084e30>] el0_svc_naked+0x24
> 
> This nlru->lock has been acquired by another CPU in this path -
> 
> [<ffffff8eca1f5fd0>] d_lru_shrink_move+0x34
> [<ffffff8eca1f6180>] dentry_lru_isolate_shrink+0x48
> [<ffffff8eca1aeafc>] __list_lru_walk_one.isra.10+0x94
> [<ffffff8eca1aec34>] list_lru_walk_node+0x40
> [<ffffff8eca1f6620>] shrink_dcache_sb+0x60
> [<ffffff8eca1e56a8>] do_remount_sb+0xbc
> [<ffffff8eca1e583c>] do_emergency_remount+0xb0
> [<ffffff8eca0ba510>] process_one_work+0x228
> [<ffffff8eca0bb158>] worker_thread+0x2e0
> [<ffffff8eca0c040c>] kthread+0xf4
> [<ffffff8eca084dd0>] ret_from_fork+0x10
> 
> Link: http://marc.info/?t=149511514800002&r=1&w=2
> Fix-suggested-by: Jan kara <jack@suse.cz>
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> ---
>  mm/list_lru.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 5d8dffd..1af0709 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -249,6 +249,8 @@ restart:
>  		default:
>  			BUG();
>  		}
> +		if (cond_resched_lock(&nlru->lock))
> +			goto restart;
>  	}
>  
>  	spin_unlock(&nlru->lock);

This is rather worrying.

a) Why are we spending so long holding that lock that this is occurring?

b) With this patch, we're restarting the entire scan.  Are there
   situations in which this loop will never terminate, or will take a
   very long time?  Suppose that this process is getting rescheds
   blasted at it for some reason?

IOW this looks like a bit of a band-aid and a deeper analysis and
understanding might be needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
