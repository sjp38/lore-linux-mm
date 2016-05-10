Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A87D56B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 05:44:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so9208034wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 02:44:50 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x9si1626380wjp.55.2016.05.10.02.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 02:44:49 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so1733509wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 02:44:49 -0700 (PDT)
Date: Tue, 10 May 2016 11:44:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160510094448.GI23576@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
 <57318932.3030804@suse.cz>
 <CAAmzW4Nb+rV88+YbD+xHDVbOfu_3HpiTVQFy6CgXAoFhpD_+pA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4Nb+rV88+YbD+xHDVbOfu_3HpiTVQFy6CgXAoFhpD_+pA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 10-05-16 17:00:08, Joonsoo Kim wrote:
> 2016-05-10 16:09 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> > On 05/10/2016 08:41 AM, Joonsoo Kim wrote:
> >>
> >> You applied band-aid for CONFIG_COMPACTION and fixed some reported
> >> problem but it is also fragile. Assume almost pageblock's skipbit are
> >> set. In this case, compaction easily returns COMPACT_COMPLETE and your
> >> logic will stop retry. Compaction isn't designed to report accurate
> >> fragmentation state of the system so depending on it's return value
> >> for OOM is fragile.
> >
> >
> > Guess I'll just post a RFC now, even though it's not much tested...
> 
> I will look at it later. But, I'd like to say something first.
> Even if compaction returns more accurate fragmentation states, it's not a good
> idea to depend on compaction's result to decide OOM. We have reclaimable but
> not migratable pages. Depending on compaction's result cannot deal
> with this case.
> 
> For example, please assume that all of the system memory are filled
> with THP pages
> or reclaimable slab pages. They cannot be migrated but we can reclaim them.

Direct reclaim should break those THP pages or shrink those slabs. And
we make sure to reclaim before we consider final call for fail from
compaction feedback. If this is a vast majority of memory we should hit
it pretty reliably AFAICS.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
