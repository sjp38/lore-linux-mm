Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE0DC6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:33:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r9-v6so254577edh.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 01:33:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15-v6si465191eda.254.2018.07.17.01.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 01:33:31 -0700 (PDT)
Date: Tue, 17 Jul 2018 10:33:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180717083326.GD16803@dhcp22.suse.cz>
References: <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
 <20180716124115.GA7072@bombadil.infradead.org>
 <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Mon 16-07-18 16:40:32, Andrew Morton wrote:
> On Mon, 16 Jul 2018 05:41:15 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Mon, Jul 16, 2018 at 11:09:01AM +0200, Michal Hocko wrote:
> > > On Fri 13-07-18 10:36:14, Dave Chinner wrote:
> > > [...]
> > > > By limiting the number of negative dentries in this case, internal
> > > > slab fragmentation is reduced such that reclaim cost never gets out
> > > > of control. While it appears to "fix" the symptoms, it doesn't
> > > > address the underlying problem. It is a partial solution at best but
> > > > at worst it's another opaque knob that nobody knows how or when to
> > > > tune.
> > > 
> > > Would it help to put all the negative dentries into its own slab cache?
> > 
> > Maybe the dcache should be more sensitive to its own needs.  In __d_alloc,
> > it could check whether there are a high proportion of negative dentries
> > and start recycling some existing negative dentries.
> 
> Well, yes.
> 
> The proposed patchset adds all this background reclaiming.  Problem is
> a) that background reclaiming sometimes can't keep up so a synchronous
> direct-reclaim was added on top and b) reclaiming dentries in the
> background will cause non-dentry-allocating tasks to suffer because of
> activity from the dentry-allocating tasks, which is inappropriate.
> 
> I expect a better design is something like
> 
> __d_alloc()
> {
> 	...
> 	while (too many dentries)
> 		call the dcache shrinker
> 	...
> }
> 
> and that's it.  This way we have a hard upper limit and only the tasks
> which are creating dentries suffer the cost.

Not really. If the limit is global then everybody who hits the limit
pays regardless how many negative dentries it produced. So if anything
this really has to be per memcg. And then we are at my previous concern,
why do we even really duplicate something that the core MM already tries
to handle - aka keep balance between cached objects. Negative dentries
are not much different from the real page cache in principle. They are
subtly different from the fragmentation point of view which is
unfortunate but this is a general problem we really ought to handle
anyway.

> Regarding the slab page fragmentation issue: I'm wondering if the whole
> idea of balancing the slab scan rates against the page scan rates isn't
> really working out.  Maybe shrink_slab() should be sitting there
> hammering the caches until they have freed up a particular number of
> pages.  Quite a big change, conceptually and implementationally.
> 
> Aside: about a billion years ago we were having issues with processes
> getting stuck in direct reclaim because other processes were coming in
> and stealing away the pages which the direct-reclaimer had just freed. 
> One possible solution to that was to make direct-reclaiming tasks
> release the freed pages into a list on the task_struct.  So those pages
> were invisible to other allocating tasks and were available to the
> direct-reclaimer when it returned from the reclaim effort.  I forget
> what happened to this.

I used to have patches to do that but then justifying them was not that
easy. Most normal workloads do not suffer much and I only had some
artificial ones which are not enough to justify the additional
complexity. Anyway this could be solved also by playing with watermarks
but I haven't explored much yet.

> It's quite a small code change and would provide a mechanism for
> implementing the hammer-cache-until-youve-freed-enough design above.
> 
> 
> 
> Aside 2: if we *do* do something like the above __d_alloc() pseudo code
> then perhaps it could be cast in terms of pages, not dentries.  ie,
> 
> __d_alloc()
> {
> 	...
> 	while (too many pages in dentry_cache)
> 		call the dcache shrinker
> 	...
> }
> 
> and, apart from the external name thing (grr), that should address
> these fragmentation issues, no?  I assume it's easy to ask slab how
> many pages are presently in use for a particular cache.

I remember Dave Chinner had an idea how to age dcache pages to push
dentries with similar live time to the same page. Not sure what happened
to that.

-- 
Michal Hocko
SUSE Labs
