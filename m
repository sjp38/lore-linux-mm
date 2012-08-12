Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3CDF66B002B
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 19:56:32 -0400 (EDT)
Date: Sun, 12 Aug 2012 20:56:16 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC][PATCH -mm 3/3] mm,vmscan: evict inactive file pages first
Message-ID: <20120812235616.GA9033@x61.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
 <20120808174904.5d241c38@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120808174904.5d241c38@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

Howdy Rik,

On Wed, Aug 08, 2012 at 05:49:04PM -0400, Rik van Riel wrote:
> @@ -1687,6 +1700,14 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  		reclaim_stat->recent_rotated[1] /= 2;
>  	}
>  
> +	/* Lots of inactive file pages? Reclaim those only. */
> +	if (reclaim_file_only(lruvec, sc, anon, file)) {
> +		fraction[0] = 0;
> +		fraction[1] = 1;
> +		denominator = 1;
> +		goto out;
> +	}
> +

This hunk causes a &zone->lru_lock spinlock lockup down this path:
 shrink_zone()->shrink_lruvec()->shrink_list()->shrink_inactive_list()

I could trigger it by doing a Kernel RPM install on a 2GB guest, for all shots.
---8<---
...
============================================= 
[ INFO: possible recursive locking detected ]
3.6.0-rc1+ #197 Not tainted
---------------------------------------------
kswapd0/29 is trying to acquire lock:
 (&(&zone->lru_lock)->rlock){....-.}, at: [<ffffffff81167b34>]
shrink_inactive_list+0xd4/0x4b0
but task is already holding lock:
 (&(&zone->lru_lock)->rlock){....-.}, at: [<ffffffff81168037>]
shrink_lruvec+0x127/0x630
         
other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(&(&zone->lru_lock)->rlock);
  lock(&(&zone->lru_lock)->rlock);

 *** DEADLOCK ***

 May be due to missing lock nesting notation

1 lock held by kswapd0/29:
 #0:  (&(&zone->lru_lock)->rlock){....-.}, at: [<ffffffff81168037>]
shrink_lruvec+0x127/0x630

stack backtrace:
Pid: 29, comm: kswapd0 Not tainted 3.6.0-rc1+ #197
Call Trace:
 [<ffffffff810cedda>] __lock_acquire+0x125a/0x1660
 [<ffffffff8108a618>] ? __kernel_text_address+0x58/0x80
 [<ffffffff810cf27f>] lock_acquire+0x9f/0x190
 [<ffffffff81167b34>] ? shrink_inactive_list+0xd4/0x4b0
 [<ffffffff8169c9dd>] _raw_spin_lock_irq+0x4d/0x60
 [<ffffffff81167b34>] ? shrink_inactive_list+0xd4/0x4b0
 [<ffffffff811612cf>] ? lru_add_drain+0x2f/0x40
 [<ffffffff81167b34>] shrink_inactive_list+0xd4/0x4b0
 [<ffffffff81168037>] ? shrink_lruvec+0x127/0x630
 [<ffffffff81168395>] shrink_lruvec+0x485/0x630
 [<ffffffff81168743>] shrink_zone+0x203/0x2a0
 [<ffffffff8116991b>] kswapd+0x85b/0xf60
 [<ffffffff8108e4f0>] ? wake_up_bit+0x40/0x40
 [<ffffffff811690c0>] ? zone_reclaim+0x420/0x420
 [<ffffffff8108dd8e>] kthread+0xbe/0xd0
 [<ffffffff816a74c4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8169d630>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108dcd0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816a74c0>] ? gs_change+0x13/0x13
...
---8<---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
