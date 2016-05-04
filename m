Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9C196B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:40:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so51131633lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:40:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id qs7si6874410wjc.50.2016.05.04.12.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 12:40:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so12610951wmw.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:40:21 -0700 (PDT)
Date: Wed, 4 May 2016 21:40:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160504194019.GE21490@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20160503085356.GD28039@dhcp22.suse.cz>
 <20160504021449.GA10256@js1304-P5Q-DELUXE>
 <20160504092133.GG29978@dhcp22.suse.cz>
 <CAAmzW4NYWaNvC5MPR8RwQSiKP2b2Z5wVy9nnNxc+sTVWvQ6BGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NYWaNvC5MPR8RwQSiKP2b2Z5wVy9nnNxc+sTVWvQ6BGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 05-05-16 00:30:35, Joonsoo Kim wrote:
> 2016-05-04 18:21 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
[...]
> > Do we really consume 512B of stack during reclaim. That sounds more than
> > worrying to me.
> 
> Hmm...I checked it by ./script/stackusage and result is as below.
> 
> shrink_zone() 128
> shrink_zone_memcg() 248
> shrink_active_list() 176
> 
> We have a call path that shrink_zone() -> shrink_zone_memcg() ->
> shrink_active_list().
> I'm not sure whether it is the deepest path or not.

This is definitely not the deepest path. Slab shrinkers can take more
but 512B is still a lot. Some call paths are already too deep when
calling into the allocator and some of them already use GFP_NOFS to
prevent from potentially deep callchain slab shrinkers. Anyway worth
exploring for better solutions.

And I believe it would be better to solve this in the stackdepot
directly so other users do not have to invent their own ways around the
same issue. I have just checked the code and set_track uses save_stack
which does the same thing and it seems to be called from the slab
allocator. I have missed this usage before so the problem already does
exist. It would be unfair to request you to fix that in order to add a
new user. It would be great if this got addressed though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
