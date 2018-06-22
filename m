Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7BFA6B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:52:11 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a10-v6so5271054qtp.2
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:52:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u1-v6si613024qka.174.2018.06.22.05.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 05:52:10 -0700 (PDT)
Date: Fri, 22 Jun 2018 08:52:09 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180622090935.GT10465@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806220845190.8072@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com> <20180615073201.GB24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com> <20180615115547.GH24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com> <20180615130925.GI24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com> <20180619104312.GD13685@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com> <20180622090151.GS10465@dhcp22.suse.cz> <20180622090935.GT10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Fri, 22 Jun 2018, Michal Hocko wrote:

> On Fri 22-06-18 11:01:51, Michal Hocko wrote:
> > On Thu 21-06-18 21:17:24, Mikulas Patocka wrote:
> [...]
> > > What about this patch? If __GFP_NORETRY and __GFP_FS is not set (i.e. the 
> > > request comes from a block device driver or a filesystem), we should not 
> > > sleep.
> > 
> > Why? How are you going to audit all the callers that the behavior makes
> > sense and moreover how are you going to ensure that future usage will
> > still make sense. The more subtle side effects gfp flags have the harder
> > they are to maintain.
> 
> So just as an excercise. Try to explain the above semantic to users. We
> currently have the following.
> 
>  * __GFP_NORETRY: The VM implementation will try only very lightweight
>  *   memory direct reclaim to get some memory under memory pressure (thus
>  *   it can sleep). It will avoid disruptive actions like OOM killer. The
>  *   caller must handle the failure which is quite likely to happen under
>  *   heavy memory pressure. The flag is suitable when failure can easily be
>  *   handled at small cost, such as reduced throughput
> 
>  * __GFP_FS can call down to the low-level FS. Clearing the flag avoids the
>  *   allocator recursing into the filesystem which might already be holding
>  *   locks.
> 
> So how are you going to explain gfp & (__GFP_NORETRY | ~__GFP_FS)? What
> is the actual semantic without explaining the whole reclaim or force
> users to look into the code to understand that? What about GFP_NOIO |
> __GFP_NORETRY? What does it mean to that "should not sleep". Do all
> shrinkers have to follow that as well?

My reasoning was that there is broken code that uses __GFP_NORETRY and 
assumes that it can't fail - so conditioning the change on !__GFP_FS would 
minimize the diruption to the broken code.

Anyway - if you want to test only on __GFP_NORETRY (and fix those 16 
broken cases that assume that __GFP_NORETRY can't fail), I'm OK with that.

Mikulas


Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -2674,6 +2674,7 @@ static bool shrink_node(pg_data_t *pgdat
 		 * the LRU too quickly.
 		 */
 		if (!sc->hibernation_mode && !current_is_kswapd() &&
+		   !(sc->gfp_mask & __GFP_NORETRY) &&
 		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
 			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
