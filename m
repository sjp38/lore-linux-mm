Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0C66B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 21:33:45 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so45652068wic.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:33:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo1si11223527wjb.27.2015.06.17.18.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 18:33:44 -0700 (PDT)
Message-ID: <1434591216.1903.44.camel@stgolabs.net>
Subject: Re: [PATCH] mm: use srcu for shrinkers
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 17 Jun 2015 18:33:36 -0700
In-Reply-To: <20150617074751.GC25056@dhcp22.suse.cz>
References: <1434398602.1903.15.camel@stgolabs.net>
	 <20150617074751.GC25056@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2015-06-17 at 09:47 +0200, Michal Hocko wrote:
> On the other hand using srcu is a neat idea. Shrinkers only need the
> existence guarantee when racing with unregister. Register even shouldn't
> be that interesting because such a shrinker wouldn't have much to
> shrink anyway so we can safely miss it AFAIU. With the srcu read lock
> we can finally get rid of the try_lock. I do not think you need an
> ugly spin_is_locked as the replacement though. We have the existence
> guarantee and that should be sufficient.

So the reason for the spin_is_locked check was that I was concerned
about new reader(s) that come in while doing the registry. Currently
this is forbidden by the trylock and fake-ish retry. But yes, perhaps I
was being over safe and we shouldn't be blockling the reclaim simply
because a shrinker is registering. And it would be cleaner to get rid of
the whole retry idea and just use rcu guarantees.

This is probably a little late in the game to try to push for 4.2, so
I'll send a v2 with any other updates that might come up once the merge
window closes.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
