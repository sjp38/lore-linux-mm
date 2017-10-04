Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9343C6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 15:33:16 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z50so8259819qtj.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 12:33:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p191sor480609yba.48.2017.10.04.12.33.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 12:33:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171004131750.lwxhwtfsyget6bsx@dhcp22.suse.cz>
References: <20171003021519.23907-1-shakeelb@google.com> <20171004131750.lwxhwtfsyget6bsx@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 4 Oct 2017 12:33:14 -0700
Message-ID: <CALvZod6w99KoNNp_DNQegDCYqWvY1ihnnGXnRL7ufiMOkaTyxw@mail.gmail.com>
Subject: Re: [PATCH] epoll: account epitem and eppoll_entry to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

>
> I am not objecting to the patch I would just like to understand the
> runaway case. ep_insert seems to limit the maximum number of watches to
> max_user_watches which should be ~4% of lowmem if I am following the
> code properly. pwq_cache should be bound by the number of watches as
> well, or am I misunderstanding the code?
>

You are absolutely right that there is a per-user limit (~4% of total
memory if no highmem) on these caches. I think it is too generous
particularly in the scenario where jobs of multiple users are running
on the system and the administrator is reducing cost by overcomitting
the memory. This is unaccounted kernel memory and will not be
considered by the oom-killer. I think by accounting it to kmemcg, for
systems with kmem accounting enabled, we can provide better isolation
between jobs of different users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
