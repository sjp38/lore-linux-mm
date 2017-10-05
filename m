Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2D296B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 04:35:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v38so4291428wrc.0
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 01:35:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18si14570082wra.410.2017.10.05.01.35.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 01:35:03 -0700 (PDT)
Date: Thu, 5 Oct 2017 10:21:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] epoll: account epitem and eppoll_entry to kmemcg
Message-ID: <20171005082118.a4ynfvnq4loyufge@dhcp22.suse.cz>
References: <20171003021519.23907-1-shakeelb@google.com>
 <20171004131750.lwxhwtfsyget6bsx@dhcp22.suse.cz>
 <CALvZod6w99KoNNp_DNQegDCYqWvY1ihnnGXnRL7ufiMOkaTyxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6w99KoNNp_DNQegDCYqWvY1ihnnGXnRL7ufiMOkaTyxw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-10-17 12:33:14, Shakeel Butt wrote:
> >
> > I am not objecting to the patch I would just like to understand the
> > runaway case. ep_insert seems to limit the maximum number of watches to
> > max_user_watches which should be ~4% of lowmem if I am following the
> > code properly. pwq_cache should be bound by the number of watches as
> > well, or am I misunderstanding the code?
> >
> 
> You are absolutely right that there is a per-user limit (~4% of total
> memory if no highmem) on these caches. I think it is too generous
> particularly in the scenario where jobs of multiple users are running
> on the system and the administrator is reducing cost by overcomitting
> the memory. This is unaccounted kernel memory and will not be
> considered by the oom-killer. I think by accounting it to kmemcg, for
> systems with kmem accounting enabled, we can provide better isolation
> between jobs of different users.

Thanks for the clarification. For some reason I didn't figure that the
limit is per user, even though the name suggests so.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
