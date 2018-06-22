Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2E526B000D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:01:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g16-v6so339974edq.10
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:01:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e45-v6si3486482edd.409.2018.06.22.02.01.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 02:01:52 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:01:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180622090151.GS10465@dhcp22.suse.cz>
References: <20180614073153.GB9371@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615073201.GB24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615130925.GI24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com>
 <20180619104312.GD13685@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 21-06-18 21:17:24, Mikulas Patocka wrote:
[...]
> > But seriously, isn't the best way around the throttling issue to use
> > PF_LESS_THROTTLE?
> 
> Yes - it could be done by setting PF_LESS_THROTTLE. But I think it would 
> be better to change it just in one place than to add PF_LESS_THROTTLE to 
> every block device driver (because adding it to every block driver results 
> in more code).

Why would every block device need this? I thought we were talking about
mempool allocator and the md variant of it. They are explicitly doing
their own back off so PF_LESS_THROTTLE sounds appropriate to me.

> What about this patch? If __GFP_NORETRY and __GFP_FS is not set (i.e. the 
> request comes from a block device driver or a filesystem), we should not 
> sleep.

Why? How are you going to audit all the callers that the behavior makes
sense and moreover how are you going to ensure that future usage will
still make sense. The more subtle side effects gfp flags have the harder
they are to maintain.

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Cc: stable@vger.kernel.org
> 
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -2674,6 +2674,7 @@ static bool shrink_node(pg_data_t *pgdat
>  		 * the LRU too quickly.
>  		 */
>  		if (!sc->hibernation_mode && !current_is_kswapd() &&
> +		   (sc->gfp_mask & (__GFP_NORETRY | __GFP_FS)) != __GFP_NORETRY &&
>  		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
>  			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
>  

-- 
Michal Hocko
SUSE Labs
