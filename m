Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E462D83295
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 07:14:36 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b65so14047017lfh.8
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 04:14:36 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id w5si2061982ljd.181.2017.06.17.04.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 04:14:35 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id u62so6315829lfg.0
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 04:14:34 -0700 (PDT)
Date: Sat, 17 Jun 2017 14:14:31 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm/list_lru.c: use cond_resched_lock() for nlru->lock
Message-ID: <20170617111431.GA27061@esperanza>
References: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
 <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hello,

On Thu, Jun 15, 2017 at 02:05:23PM -0700, Andrew Morton wrote:
> On Mon, 12 Jun 2017 06:17:20 +0530 Sahitya Tummala <stummala@codeaurora.org> wrote:
> 
> > __list_lru_walk_one() can hold the spin lock for longer duration
> > if there are more number of entries to be isolated.
> > 
> > This results in "BUG: spinlock lockup suspected" in the below path -
> > 
> > [<ffffff8eca0fb0bc>] spin_bug+0x90
> > [<ffffff8eca0fb220>] do_raw_spin_lock+0xfc
> > [<ffffff8ecafb7798>] _raw_spin_lock+0x28
> > [<ffffff8eca1ae884>] list_lru_add+0x28
> > [<ffffff8eca1f5dac>] dput+0x1c8
> > [<ffffff8eca1eb46c>] path_put+0x20
> > [<ffffff8eca1eb73c>] terminate_walk+0x3c
> > [<ffffff8eca1eee58>] path_lookupat+0x100
> > [<ffffff8eca1f00fc>] filename_lookup+0x6c
> > [<ffffff8eca1f0264>] user_path_at_empty+0x54
> > [<ffffff8eca1e066c>] SyS_faccessat+0xd0
> > [<ffffff8eca084e30>] el0_svc_naked+0x24
> > 
> > This nlru->lock has been acquired by another CPU in this path -
> > 
> > [<ffffff8eca1f5fd0>] d_lru_shrink_move+0x34
> > [<ffffff8eca1f6180>] dentry_lru_isolate_shrink+0x48
> > [<ffffff8eca1aeafc>] __list_lru_walk_one.isra.10+0x94
> > [<ffffff8eca1aec34>] list_lru_walk_node+0x40
> > [<ffffff8eca1f6620>] shrink_dcache_sb+0x60
> > [<ffffff8eca1e56a8>] do_remount_sb+0xbc
> > [<ffffff8eca1e583c>] do_emergency_remount+0xb0
> > [<ffffff8eca0ba510>] process_one_work+0x228
> > [<ffffff8eca0bb158>] worker_thread+0x2e0
> > [<ffffff8eca0c040c>] kthread+0xf4
> > [<ffffff8eca084dd0>] ret_from_fork+0x10
> > 
> > Link: http://marc.info/?t=149511514800002&r=1&w=2
> > Fix-suggested-by: Jan kara <jack@suse.cz>
> > Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> > ---
> >  mm/list_lru.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/list_lru.c b/mm/list_lru.c
> > index 5d8dffd..1af0709 100644
> > --- a/mm/list_lru.c
> > +++ b/mm/list_lru.c
> > @@ -249,6 +249,8 @@ restart:
> >  		default:
> >  			BUG();
> >  		}
> > +		if (cond_resched_lock(&nlru->lock))
> > +			goto restart;
> >  	}
> >  
> >  	spin_unlock(&nlru->lock);
> 
> This is rather worrying.
> 
> a) Why are we spending so long holding that lock that this is occurring?
> 
> b) With this patch, we're restarting the entire scan.  Are there
>    situations in which this loop will never terminate, or will take a
>    very long time?  Suppose that this process is getting rescheds
>    blasted at it for some reason?
> 
> IOW this looks like a bit of a band-aid and a deeper analysis and
> understanding might be needed.

The goal of list_lru_walk is removing inactive entries from the lru list
(LRU_REMOVED). Memory shrinkers may also choose to move active entries
to the tail of the lru list (LRU_ROTATED). LRU_SKIP is supposed to be
returned only to avoid a possible deadlock. So I don't see how
restarting lru walk could have adverse effects.

However, I do find this patch kinda ugly, because:

 - list_lru_walk already gives you a way to avoid a lockup - just make
   the callback reschedule and return LRU_RETRY every now and then, see
   shadow_lru_isolate() for an example. Alternatively, you can limit the
   number of entries scanned in one go (nr_to_walk) and reschedule
   between calls. This is what shrink_slab() does: the number of
   dentries scanned without releasing the lock is limited to 1024, see
   how super_block::s_shrink is initialized.

 - Someone might want to call list_lru_walk with a spin lock held, and I
   don't see anything wrong in doing that. With your patch it can't be
   done anymore.

That said, I think it would be better to patch shrink_dcache_sb() or
dentry_lru_isolate_shrink() instead of list_lru_walk() in order to fix
this lockup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
