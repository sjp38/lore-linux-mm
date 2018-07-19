Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA126B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:45:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f13-v6so1922919edr.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:45:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x42-v6si5047971edm.81.2018.07.19.01.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:45:40 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:45:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180719084538.GP7193@dhcp22.suse.cz>
References: <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
 <20180716124115.GA7072@bombadil.infradead.org>
 <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
 <20180717083326.GD16803@dhcp22.suse.cz>
 <20180719003329.GD19934@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719003329.GD19934@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Thu 19-07-18 10:33:29, Dave Chinner wrote:
> On Tue, Jul 17, 2018 at 10:33:26AM +0200, Michal Hocko wrote:
> > On Mon 16-07-18 16:40:32, Andrew Morton wrote:
> > > On Mon, 16 Jul 2018 05:41:15 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> > > It's quite a small code change and would provide a mechanism for
> > > implementing the hammer-cache-until-youve-freed-enough design above.
> > > 
> > > 
> > > 
> > > Aside 2: if we *do* do something like the above __d_alloc() pseudo code
> > > then perhaps it could be cast in terms of pages, not dentries.  ie,
> > > 
> > > __d_alloc()
> > > {
> > > 	...
> > > 	while (too many pages in dentry_cache)
> > > 		call the dcache shrinker
> > > 	...
> > > }
> 
> Direct reclaim will result in all the people who care about long
> tail latencies and/or highly concurent workloads starting to hate
> you.  Direct reclaim already hammers superblock shrinkers with
> excessive concurrency, this would only make it worse.

I can only confirm that! We have something similar in our SLES kernel.
We have page cache soft limit implemented for many years and it is
basically similar thing to above. We just shrink the page cache when we
have too much of it. It turned out to be a complete PITA on large
machines when hundreds of CPUs are fighting for locks. We have tried to
address that but it is a complete whack a mole.

More important lesson from this is that the original motivation for this
functionality was to not allow too much page cache which would push a
useful DB data out to swap. And as it turned out MM internals have
changed a lot since the introduction and we do not really swap out in
presence of the page cache anymore. Moreover we have a much more
effective reclaim protection thanks to memcg low limit reclaim etc.
While that is all good and nice there are still people tunning the
pagecache limit based on some really old admin guides and the feature
makes more harm than good and we see bug reports that system gets
stalled...

I really do not see why limiting (negative) dentries should be any
different.

> IOWs, anything like this needs to co-ordinate with other reclaim
> operations in progress and, most likely, be done via background
> reclaim processing rather than blocking new allocations
> indefinitely. background processing can be done in bulk and as
> efficiently as possible - concurrent direct reclaim in tiny batches
> will just hammer dcache locks and destroy performance when there is
> memory pressure.

Absolutely agreed!

> How many times do we have to learn this lesson the hard way?
> 
> > > and, apart from the external name thing (grr), that should address
> > > these fragmentation issues, no?  I assume it's easy to ask slab how
> > > many pages are presently in use for a particular cache.
> > 
> > I remember Dave Chinner had an idea how to age dcache pages to push
> > dentries with similar live time to the same page. Not sure what happened
> > to that.
> 
> Same thing that happened to all the "select the dentries on this
> page for reclaim". i.e. it's referenced dentries that we can't
> reclaim or move that are the issue, not the reclaimable dentries on
> the page.
> 
> Bsaically, without a hint at allocation time as to the expected life
> time of the dentry, we can't be smart about how we select partial
> pages to allocate from. And because we don't know at allocation time
> if the dentry is going to remain a negative dentry or not, we can't
> provide a hint about expected lifetime of teh object being
> allocated.

Can we allocate a new dentry at the time when we know the life time or
the dentry pointer is so spread by that time that we cannot?
-- 
Michal Hocko
SUSE Labs
