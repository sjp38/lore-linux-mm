Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id F3DCF6B0276
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 12:19:55 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so18480839igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 09:19:55 -0700 (PDT)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id m130si15937568ioe.55.2015.09.03.09.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 03 Sep 2015 09:19:55 -0700 (PDT)
Date: Thu, 3 Sep 2015 11:19:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for
 4.3)
In-Reply-To: <20150903122949.78ee3c94@redhat.com>
Message-ID: <alpine.DEB.2.11.1509031113450.24411@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com> <20150903005115.GA27804@redhat.com> <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com> <20150903060247.GV1933@devil.localdomain>
 <20150903122949.78ee3c94@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, 3 Sep 2015, Jesper Dangaard Brouer wrote:

> > IOWs, slab merging prevents us from implementing effective active
> > fragmentation management algorithms and hence prevents us  from
> > reducing slab fragmentation via improved shrinker reclaim
> > algorithms.  Simply put: slab merging reduces the effectiveness of
> > shrinker based slab reclaim.
>
> I'm buying into the problem of variable object lifetime sharing the
> same slub.

Well yeah I see the logic of the argument but what I have seen in practice
is that the access to objects becomes rather random over time. inodes and
denties are used by multiple underlying volumes/mountpoints etc. They are
expired individually etc etc. The references to objects become garbled
over time anyways.

What I would be interested in is some means by which locality of objects
of different caches can be explicitly specified. This would allow the
placing together of multiple objects in the same page frame. F.e. dentries
and inodes and other metadata of a filesystem that is related. This would
enhance the locality of the data and allow better defragmentation. But we
are talking here about a totally different allocator design.

> With the SLAB bulk free API I'm introducing, we can speedup slub
> slowpath, by free several objects with a single cmpxchg_double, BUT
> these objects need to belong to the same page.
>  Thus, as Dave describe with merging, other users of the same size
> objects might end up holding onto objects scattered across several
> pages, which gives the bulk free less opportunities.

This happens regardless as far as I can tell. On boot up you may end up
for a time in special situations where that is true.

> That would be a technical argument for introducing a SLAB_NO_MERGE flag
> per slab.  But I want to do some measurement before making any
> decision. And it might be hard to show for my use-case of SKB free,
> because SKB allocs will likely be dominating 256 bytes slab anyhow.

With the skbs you would want to place the skb data together with the
packet data and other network related objects right? Maybe we can think
out an allocator that can store objects related to a specific action in a
page frame that can then be tossed as a whole.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
