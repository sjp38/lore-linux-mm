Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BE1F76B005A
	for <linux-mm@kvack.org>; Sat,  7 Jan 2012 03:28:37 -0500 (EST)
Received: by qcsd17 with SMTP id d17so1540289qcs.14
        for <linux-mm@kvack.org>; Sat, 07 Jan 2012 00:28:36 -0800 (PST)
Message-ID: <4F08022C.1020208@gmail.com>
Date: Sat, 07 Jan 2012 03:28:28 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] SHM_UNLOCK: fix long unpreemptible section
References: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(1/6/12 4:10 PM), Hugh Dickins wrote:
> scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
> evictable again once the shared memory is unlocked.  It does this with
> pagevec_lookup()s across the whole object (which might occupy most of
> memory), and takes 300ms to unlock 7GB here.  A cond_resched() every
> PAGEVEC_SIZE pages would be good.
>
> However, KOSAKI-san points out that this is called under shmem.c's
> info->lock, and it's also under shm.c's shm_lock(), both spinlocks.
> There is no strong reason for that: we need to take these pages off
> the unevictable list soonish, but those locks are not required for it.
>
> So move the call to scan_mapping_unevictable_pages() from shmem.c's
> unlock handling up to shm.c's unlock handling.  Remove the recently
> added barrier, not needed now we have spin_unlock() before the scan.
>
> Use get_file(), with subsequent fput(), to make sure we have a
> reference to mapping throughout scan_mapping_unevictable_pages():
> that's something that was previously guaranteed by the shm_lock().
>
> Remove shmctl's lru_add_drain_all(): we don't fault in pages at
> SHM_LOCK time, and we lazily discover them to be Unevictable later,
> so it serves no purpose for SHM_LOCK; and serves no purpose for
> SHM_UNLOCK, since pages still on pagevec are not marked Unevictable.
>
> The original code avoided redundant rescans by checking VM_LOCKED
> flag at its level: now avoid them by checking shp's SHM_LOCKED.
>
> The original code called scan_mapping_unevictable_pages() on a
> locked area at shm_destroy() time: perhaps we once had accounting
> cross-checks which required that, but not now, so skip the overhead
> and just let inode eviction deal with them.
>
> Put check_move_unevictable_page() and scan_mapping_unevictable_pages()
> under CONFIG_SHMEM (with stub for the TINY case when ramfs is used),
> more as comment than to save space; comment them used for SHM_UNLOCK.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> Cc: stable@vger.kernel.org [back to 2.6.32 but will need respins]

Looks completely make sense.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
