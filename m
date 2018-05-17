Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7AC26B038B
	for <linux-mm@kvack.org>; Thu, 17 May 2018 00:49:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u13-v6so1541320lff.0
        for <linux-mm@kvack.org>; Wed, 16 May 2018 21:49:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b4-v6sor1147154lfg.111.2018.05.16.21.49.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 21:49:27 -0700 (PDT)
Date: Thu, 17 May 2018 07:49:24 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 13/13] mm: Clear shrinker bit if there are no objects
 related to memcg
Message-ID: <20180517044924.5tq6vbqituvr3nzh@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594605549.22949.16491037134168999424.stgit@localhost.localdomain>
 <20180515055913.alk3pau43e3jps3y@esperanza>
 <1e31235c-f4e3-1046-57c8-741de095e616@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e31235c-f4e3-1046-57c8-741de095e616@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, May 15, 2018 at 11:55:04AM +0300, Kirill Tkhai wrote:
> >> @@ -586,8 +586,23 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
> >>  			continue;
> >>  
> >>  		ret = do_shrink_slab(&sc, shrinker, priority);
> >> -		if (ret == SHRINK_EMPTY)
> >> -			ret = 0;
> >> +		if (ret == SHRINK_EMPTY) {
> >> +			clear_bit(i, map->map);
> >> +			/*
> >> +			 * Pairs with mb in memcg_set_shrinker_bit():
> >> +			 *
> >> +			 * list_lru_add()     shrink_slab_memcg()
> >> +			 *   list_add_tail()    clear_bit()
> >> +			 *   <MB>               <MB>
> >> +			 *   set_bit()          do_shrink_slab()
> >> +			 */
> > 
> > Please improve the comment so that it isn't just a diagram.
> 
> Please, say, which comment you want to see here.

I want the reader to understand why we need to invoke the shrinker twice
if it returns SHRINK_EMPTY. The diagram doesn't really help here IMO. So
I'd write Something like this:

	ret = do_shrink_slab(&sc, shrinker, priority);
	if (ret == SHRINK_EMPTY) {
		clear_bit(i, map->map);
		/*
		 * After the shrinker reported that it had no objects to free,
		 * but before we cleared the corresponding bit in the memcg
		 * shrinker map, a new object might have been added. To make
		 * sure, we have the bit set in this case, we invoke the
		 * shrinker one more time and re-set the bit if it reports that
		 * it is not empty anymore. The memory barrier here pairs with
		 * the barrier in memcg_set_shrinker_bit():
		 *
		 * list_lru_add()     shrink_slab_memcg()
		 *   list_add_tail()    clear_bit()
		 *   <MB>               <MB>
		 *   set_bit()          do_shrink_slab()
		 */
		smp_mb__after_atomic();
		ret = do_shrink_slab(&sc, shrinker, priority);
			if (ret == SHRINK_EMPTY)
				ret = 0;
			else
				memcg_set_shrinker_bit(memcg, nid, i);
