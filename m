Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84D896B02C3
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 12:29:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 24so34661039lfr.10
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 09:29:00 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id a89si5122246ljb.130.2017.07.01.09.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jul 2017 09:28:59 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id t72so12176451lff.0
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 09:28:58 -0700 (PDT)
Date: Sat, 1 Jul 2017 19:28:56 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v4 2/2] fs/dcache.c: fix spin lockup issue on nlru->lock
Message-ID: <20170701162856.i7ysaqb5s24hqero@esperanza>
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
 <1498707575-2472-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498707575-2472-1-git-send-email-stummala@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Jun 29, 2017 at 09:09:35AM +0530, Sahitya Tummala wrote:
> __list_lru_walk_one() acquires nlru spin lock (nlru->lock) for
> longer duration if there are more number of items in the lru list.
> As per the current code, it can hold the spin lock for upto maximum
> UINT_MAX entries at a time. So if there are more number of items in
> the lru list, then "BUG: spinlock lockup suspected" is observed in
> the below path -
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
> This nlru->lock is acquired by another CPU in this path -
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
> Fix this lockup by reducing the number of entries to be shrinked
> from the lru list to 1024 at once. Also, add cond_resched() before
> processing the lru list again.
> 
> Link: http://marc.info/?t=149722864900001&r=1&w=2
> Fix-suggested-by: Jan kara <jack@suse.cz>
> Fix-suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
