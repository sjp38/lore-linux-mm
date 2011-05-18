Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 32F726B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 05:57:26 -0400 (EDT)
Date: Wed, 18 May 2011 10:57:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110518095720.GQ5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305295404-12129-5-git-send-email-mgorman@suse.de>
 <4DCFAA80.7040109@jp.fujitsu.com>
 <1305519711.4806.7.camel@mulgrave.site>
 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
 <20110516084558.GE5279@suse.de>
 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
 <20110516102753.GF5279@suse.de>
 <4DD31221.3060205@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4DD31221.3060205@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Wed, May 18, 2011 at 09:26:09AM +0900, KOSAKI Motohiro wrote:
> >Lets see;
> >
> >shrink_page_list() only applies if inactive pages were isolated
> >	which in turn may not happen if all_unreclaimable is set in
> >	shrink_zones(). If for whatver reason, all_unreclaimable is
> >	set on all zones, we can miss calling cond_resched().
> >
> >shrink_slab only applies if we are reclaiming slab pages. If the first
> >	shrinker returns -1, we do not call cond_resched(). If that
> >	first shrinker is dcache and __GFP_FS is not set, direct
> >	reclaimers will not shrink at all. However, if there are
> >	enough of them running or if one of the other shrinkers
> >	is running for a very long time, kswapd could be starved
> >	acquiring the shrinker_rwsem and never reaching the
> >	cond_resched().
> 
> OK.
> 
> 
> >
> >balance_pgdat() only calls cond_resched if the zones are not
> >	balanced. For a high-order allocation that is balanced, it
> >	checks order-0 again. During that window, order-0 might have
> >	become unbalanced so it loops again for order-0 and returns
> >	that was reclaiming for order-0 to kswapd(). It can then find
> >	that a caller has rewoken kswapd for a high-order and re-enters
> >	balance_pgdat() without ever have called cond_resched().
> 
> Then, Shouldn't balance_pgdat() call cond_resched() unconditionally?
> The problem is NOT 100% cpu consumption. if kswapd will sleep, other
> processes need to reclaim old pages. The problem is, kswapd doesn't
> invoke context switch and other tasks hang-up.
> 

Which the shrink_slab patch does (either version). What's the gain from
sprinkling more cond_resched() around? If you think there is, submit
another pair of patches (include patch 1 from this series) but I'm not
seeing the advantage myself.

> 
> >While it appears unlikely, there are bad conditions which can result
> >in cond_resched() being avoided.
> >
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
