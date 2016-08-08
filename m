Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0A66B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 14:38:04 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f14so251979558ioj.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:38:04 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10090.outbound.protection.outlook.com. [40.107.1.90])
        by mx.google.com with ESMTPS id d130si15135523oif.127.2016.08.08.11.38.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Aug 2016 11:38:03 -0700 (PDT)
Date: Mon, 8 Aug 2016 21:37:54 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [BUG] Bad page states
Message-ID: <20160808183754.GE1983@esperanza>
References: <1470417220.13693.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+55aFzYnpS-kc+=R0HvTuFquV2qH6cqBXF0-0Q2rSCk=6nUUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CA+55aFzYnpS-kc+=R0HvTuFquV2qH6cqBXF0-0Q2rSCk=6nUUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Aug 08, 2016 at 10:48:45AM -0700, Linus Torvalds wrote:
...
> > [   43.477693] BUG: Bad page state in process S05containers  pfn:1ff02a3
> > [   43.484417] page:ffffea007fc0a8c0 count:0 mapcount:-511 mapping:          (null) index:0x0
> > [   43.492737] flags: 0x1000000000000000()
> > [   43.496602] page dumped because: nonzero mapcount
> 
> Hmm. The _mapcount field is a union with other fields, but that number
> doesn't make sense for any of the other fields.
> 
> So it's almost certainly related to "PAGE_KMEMCG_MAPCOUNT_VALUE". So

Yes, it is - my bad. The thing is I set/clear PAGE_KMEMCG_MAPCOUNT_VALUE
for pages allocated with __GFP_ACCOUNT iff memcg_kmem_enabled() is true
(see __alloc_pages_nodemask and free_pages_prepare), while the latter
gets disabled when the last cgroup gets destroyed. So if you do

 mkdir /sys/fs/cgroup/memory/test
 # run something in the root cgroup that allocates pages with
 # __GFP_ACCOUNT, e.g. a program using pipe
 rmdir /sys/fs/cgroup/memory/test

Then, if there are no other memory cgroups, you'll see the bug.

Sorry about that :-(

Obviously, the PageKmemcg flag should only be set for pages that are
actually accounted to a non-root kmemcg and hence pin memcg_kmem_enabled
static key. I'll fix that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
