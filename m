Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 908C76B0012
	for <linux-mm@kvack.org>; Fri, 20 May 2011 06:11:31 -0400 (EDT)
Date: Fri, 20 May 2011 12:11:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-ID: <20110520101120.GC11729@random.random>
References: <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
 <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
 <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
 <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
 <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
 <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
 <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, May 20, 2011 at 02:08:56PM +0900, KAMEZAWA Hiroyuki wrote:
> +	if (!PageCompound(page)) {
> +		compound_unlock(page);
> +		spin_unlock_irq(&zone->lru_lock);
> +		return false;
> +	}

If you turn this into a BUG_ON(!PageCompound)) I'm ok with it. But it
wasn't supposed to ever happen so the above shouldn't be needed.

This very check is done in split_huge_page after taking the root
anon_vma lock. And every other thread or process sharing the page has
to take the anon_vma lock, and then check PageCompound too before it
can proceed into __split_huge_page. So I don't see a problem but
please add the BUG_ON if you are concerned. A BUG_ON definitely can't
hurt. Also note, __split_huge_page is static and is only called by
split_huge_page which does the check after proper locking.

    if (!PageCompound(page))
       goto out_unlock;

I figure it's not easily reproducible but you can easily rule out THP
issues by reproducing at least once after booting with
transparent_hugepage=never or by building the kernel with
CONFIG_TRANSPARENT_HUGEPAGE=n.

I'm afraid we might have some lru active/inactive/isolated vmstat.c
related issue so that's the part of the code I'd recommend to review
(I checked it and I didn't see wrong stuff yet, not even in THP
context yet but I'm still worried we have a statistic issue
somewhere). I had a bugreport during -rc by two people (one was UP
build and one was SMP build) not easily reproducible too, that hinted
a possible nr_inactive* or nr_inactive* (or both) being wrong (not
sure if _anon or _file, could be just one lru type or both). If stats
are off, that may also trigger oom killer by making the VM shrinking
(which also activates the swapping) bail out early thinking it can't
shrink no more. It could be the same statistic problem that sometime
makes the VM think it can't shrink no more and lead into early oom
killing, and at other times it loops indefinitely in too_many_isolated
if nr_isolated_X > nr_inactive_X indefinitely for __GFP_NO_KSWAPD
allocations (kswapd is immune from such loop, so if kswapd is allowed
to run, it probably kswapd then increases nr_inactive by deactivating
enough pages to make it unblock). Just a wild guess...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
