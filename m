Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9313D6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:10:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so3966142wmd.17
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 02:10:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si8136241wmd.92.2017.10.10.02.10.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 02:10:43 -0700 (PDT)
Date: Tue, 10 Oct 2017 11:10:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171010091042.eokqlrqec33w3qzt@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009180409.z3mpk3m7m75hjyfv@dhcp22.suse.cz>
 <20171009181754.37svpqljub2goojr@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009181754.37svpqljub2goojr@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 09-10-17 20:17:54, Michal Hocko wrote:
> the primary concern for this patch was whether we really need/want to
> charge short therm objects which do not outlive a single syscall.

Let me expand on this some more. What is the benefit of kmem accounting
of such an object? It cannot stop any runaway as a syscall lifetime
allocations are bound to number of processes which we kind of contain by
other means. If we do account then we put a memory pressure due to
something that cannot be reclaimed by no means. Even the memcg OOM
killer would simply kick a single path while there might be others
to consume the same type of memory.

So what is the actual point in accounting these? Does it help to contain
any workload better? What kind of workload?

Or am I completely wrong and name objects can outlive a syscall
considerably?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
