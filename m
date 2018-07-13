Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA956B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 20:36:21 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b5-v6so18382715ple.20
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:36:21 -0700 (PDT)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id r38-v6si22176368pga.381.2018.07.12.17.36.18
        for <linux-mm@kvack.org>;
        Thu, 12 Jul 2018 17:36:19 -0700 (PDT)
Date: Fri, 13 Jul 2018 10:36:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180713003614.GW2234@dastard>
References: <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <1531330947.3260.13.camel@HansenPartnership.com>
 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531425435.18255.17.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Thu, Jul 12, 2018 at 12:57:15PM -0700, James Bottomley wrote:
> What surprises me most about this behaviour is the steadiness of the
> page cache ... I would have thought we'd have shrunk it somewhat given
> the intense call on the dcache.

Oh, good, the page cache vs superblock shrinker balancing still
protects the working set of each cache the way it's supposed to
under heavy single cache pressure. :)

Keep in mind that the amount of work slab cache shrinkers perform is
directly proportional to the amount of page cache reclaim that is
performed and the size of the slab cache being reclaimed.  IOWs,
under a "single cache pressure" workload we should be directing
reclaim work to the huge cache creating the pressure and do very
little reclaim from other caches....

[ What follows from here is conjecture, but is based on what I've
seen in the past 10+ years on systems with large numbers of negative
dentries and fragmented dentry/inode caches. ]

However, this only reaches steady state if the reclaim rate can keep
ahead of the allocation rate. This single threaded micro-workload
won't result in an internally fragmented dentry slab cache, so
reclaim is going to be as efficient as possible and have the CPU to
keep up with the allocation rate.  i.e. Bulk negative dentry reclaim
is cheap, in LRU order, and frees slab pages quickly and efficiently
in large batches so steady state is easily reached.

Problems arise when the slab *page* reclaim rate drops below
allocation rate. i.e when you have short term (negative) dentries
mixed into the same slab pages as long term stable dentries. This
causes the dentry cache to fragment internally - reclaim hits the
negative dentries and creates large numbers of partial pages - and
so reclaim of negative dentries will fail to free memory. Creating
new negative dentries then fills these partial pages first, and so
the alloc/reclaim cycles on negative dentries only ever produce
partial pages and never free slab cache pages. IOWs, the cost of
reclaim slab *pages* goes way up despite the fact that the cost of
reclaiming individual dentries has remained the same.

That's the underlying problem here - the cost of reclaiming dentries
is constant but the cost of reclaiming *slab pages* is not.  It is
not uncommon to have to trash 90% of the dentry or inode caches to
reduce internal fragmentation down to the point where pages start to
get freed and the per-slab-page reclaim cost reduces to be less than
the allocation cost. Then we see the system return to normal steady
state behaviour.

In situations where lots of negative dentries are created by
production workloads, that "90%" of the cache that needs to be
reclaimed to fix the internal fragmentation issue is all negative
dentries and just enough of the real dentries to be freeing
quantities of partial pages in the slab. Hence negative dentries are
seen as the problem because they make up the vast majority of the
dentries that get reclaimed when the problem goes away.

By limiting the number of negative dentries in this case, internal
slab fragmentation is reduced such that reclaim cost never gets out
of control. While it appears to "fix" the symptoms, it doesn't
address the underlying problem. It is a partial solution at best but
at worst it's another opaque knob that nobody knows how or when to
tune.

Very few microbenchmarks expose this internal slab fragmentation
problem because they either don't run long enough, don't create
memory pressure, or don't have access patterns that mix long and
short term slab objects together in a way that causes slab
fragmentation. Run some cold cache directory traversals (git
status?) at the same time you are creating negative dentries so you
create pinned partial pages in the slab cache and see how the
behaviour changes....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
