Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id D5D186B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:38:48 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so3724804yhq.5
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:38:48 -0800 (PST)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id t39si8624514yhp.225.2013.12.10.04.38.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 04:38:47 -0800 (PST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so7542545pbb.4
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:38:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52A6FFF0.6080207@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
	<5287164773f8aade33ce17f3c91546c6e1afaf85.1386571280.git.vdavydov@parallels.com>
	<20131210041826.GB31386@dastard>
	<52A6FFF0.6080207@parallels.com>
Date: Tue, 10 Dec 2013 16:38:46 +0400
Message-ID: <CAA6-i6pWF-iiqLEUwcODKUCr+ng-H0Wc=L7+WFxUxo=Yr7MM8A@mail.gmail.com>
Subject: Re: [PATCH v13 13/16] vmscan: take at least one pass with shrinkers
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Dave Chinner <david@fromorbit.com>, dchinner@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Glauber Costa <gloomer@openvz.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Tue, Dec 10, 2013 at 3:50 PM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> On 12/10/2013 08:18 AM, Dave Chinner wrote:
>> On Mon, Dec 09, 2013 at 12:05:54PM +0400, Vladimir Davydov wrote:
>>> From: Glauber Costa <glommer@openvz.org>
>>>
>>> In very low free kernel memory situations, it may be the case that we
>>> have less objects to free than our initial batch size. If this is the
>>> case, it is better to shrink those, and open space for the new workload
>>> then to keep them and fail the new allocations.
>>>
>>> In particular, we are concerned with the direct reclaim case for memcg.
>>> Although this same technique can be applied to other situations just as
>>> well, we will start conservative and apply it for that case, which is
>>> the one that matters the most.
>> This should be at the start of the series.
>
> Since Glauber wanted to introduce this only for memcg-reclaim first,
> this can't be at the start of the series, but I'll move it to go
> immediately after per-memcg shrinking core in the next iteration.
>
> Thanks.

So, the reason for that being memcg only, is that the reclaim for
small objects triggered
a bunch of XFS regressions (I am sure the regressions are general, but
I've tested them using
ZFS).

In theory they shouldn't, so we can try to make it global again, so
long as it comes together
with benchmarks demonstrating that it is a safe change.

I am not sure the filesystem people would benefit from that directly,
though. So it may not be worth the hassle...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
