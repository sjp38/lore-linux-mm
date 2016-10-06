Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 214726B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 07:14:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b201so5985536wmb.2
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 04:14:30 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ws7si16401321wjb.93.2016.10.06.04.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 04:14:28 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id p138so2996176wmb.0
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 04:14:28 -0700 (PDT)
Date: Thu, 6 Oct 2016 13:14:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] mm: give GFP_REPEAT a better semantic
Message-ID: <20161006111426.GE10570@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I would like to revive this thread. It seems we haven't found any
conclusion. The main objection so far has been that the __GFP_RETRY_HARD
may-fail semantic is not clear and that it is mixing two things (fail
for !costly and repeat for costly orders) together. As for the first
part I guess we can think of a better name. __GFP_RETRY_MAYFAIL should be
more clear IMHO.

For the second objection Johannes has suggested a separate __GFP_MAYFAIL
flag. In one variant we would keep __GFP_REPEAT as a modifier to try
harder on top. My main objection was that the gfp flag space is really
scarce but we received some relief after
http://lkml.kernel.org/r/20160912114852.GI14524@dhcp22.suse.cz so maybe
we can reconsider this.

I am not convinced that a separate MAYFAIL flag would make situation
much better semantic wise, though. a) it adds de-facto another gfp
order specific flag and we have seen that this concept is not really
working well from the past and b) the name doesn't really help users
to make clear how hard the allocator tries if we keep GFP_REPEAT -
e.g. what is the difference between GFP_KERNEL|__GFP_MAYFAIL and
GFP_KERNEL|__GFP_MAYFAIL|__GFP_REPEAT?

One way to differentiate the two would be to not trigger the OOM killer
in the first case which would make it similar to GFP_NORETRY except we
would retry as long as there is a progress and fail right before the
OOM would be declared. __GFP_REPEAT on top would invoke OOM for !costly
requests and keep retrying until we hit the OOM again in the same
path. To me it sounds quite complicated and the OOM behavior subtle and
non intuitive. An alternative would be to ignore __GFP_REPEAT for
!costly orders and have it costly specific.

Another suggestion by Johannes was to make __GFP_REPEAT default for
costly orders and drop the flag. __GFP_NORETRY can be used to opt-out
and have the previous behavior. __GFP_MAYFAIL would then be more clear
but the main problem then is that many allocation requests could turn
out to be really disruptive leading to performance issues which would
be not that easy to debug. While we only have few GFP_REPEAT users
(~30) currently there are way much more allocations which would be more
aggressive now. So the question is how to identify those which should be
changed to NORETRY and how to tell users when to opt-out in newly added
allocation sites. To me this sounds really risky and whack-a-mole games.

Does anybody see other option(s)?

I fully realize the situation is not easy and our costly vs. !costly
heritage is hard to come around. Whatever we do can end up in a similar
mess we had with GFP_REPEAT but I believe that we should find a way
to tell that a particular request is OK to fail and override default
allocator policy. To me __GFP_RETRY_MAYFAIL with "retry as long as there
are reasonable chances to succeed and then fail" semantic sounds the
most coherent and attractive because it is not order specific from the
user point of view and there is a zero risk of reggressions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
