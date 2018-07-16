Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 160406B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:40:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n19-v6so4118842pgv.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 16:40:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x2-v6si30961634plv.388.2018.07.16.16.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 16:40:34 -0700 (PDT)
Date: Mon, 16 Jul 2018 16:40:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-Id: <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
In-Reply-To: <20180716124115.GA7072@bombadil.infradead.org>
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	<1531336913.3260.18.camel@HansenPartnership.com>
	<4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	<1531411494.18255.6.camel@HansenPartnership.com>
	<20180712164932.GA3475@bombadil.infradead.org>
	<1531416080.18255.8.camel@HansenPartnership.com>
	<CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
	<1531425435.18255.17.camel@HansenPartnership.com>
	<20180713003614.GW2234@dastard>
	<20180716090901.GG17280@dhcp22.suse.cz>
	<20180716124115.GA7072@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Chinner <david@fromorbit.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Mon, 16 Jul 2018 05:41:15 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, Jul 16, 2018 at 11:09:01AM +0200, Michal Hocko wrote:
> > On Fri 13-07-18 10:36:14, Dave Chinner wrote:
> > [...]
> > > By limiting the number of negative dentries in this case, internal
> > > slab fragmentation is reduced such that reclaim cost never gets out
> > > of control. While it appears to "fix" the symptoms, it doesn't
> > > address the underlying problem. It is a partial solution at best but
> > > at worst it's another opaque knob that nobody knows how or when to
> > > tune.
> > 
> > Would it help to put all the negative dentries into its own slab cache?
> 
> Maybe the dcache should be more sensitive to its own needs.  In __d_alloc,
> it could check whether there are a high proportion of negative dentries
> and start recycling some existing negative dentries.

Well, yes.

The proposed patchset adds all this background reclaiming.  Problem is
a) that background reclaiming sometimes can't keep up so a synchronous
direct-reclaim was added on top and b) reclaiming dentries in the
background will cause non-dentry-allocating tasks to suffer because of
activity from the dentry-allocating tasks, which is inappropriate.

I expect a better design is something like

__d_alloc()
{
	...
	while (too many dentries)
		call the dcache shrinker
	...
}

and that's it.  This way we have a hard upper limit and only the tasks
which are creating dentries suffer the cost.


Regarding the slab page fragmentation issue: I'm wondering if the whole
idea of balancing the slab scan rates against the page scan rates isn't
really working out.  Maybe shrink_slab() should be sitting there
hammering the caches until they have freed up a particular number of
pages.  Quite a big change, conceptually and implementationally.

Aside: about a billion years ago we were having issues with processes
getting stuck in direct reclaim because other processes were coming in
and stealing away the pages which the direct-reclaimer had just freed. 
One possible solution to that was to make direct-reclaiming tasks
release the freed pages into a list on the task_struct.  So those pages
were invisible to other allocating tasks and were available to the
direct-reclaimer when it returned from the reclaim effort.  I forget
what happened to this.

It's quite a small code change and would provide a mechanism for
implementing the hammer-cache-until-youve-freed-enough design above.



Aside 2: if we *do* do something like the above __d_alloc() pseudo code
then perhaps it could be cast in terms of pages, not dentries.  ie,

__d_alloc()
{
	...
	while (too many pages in dentry_cache)
		call the dcache shrinker
	...
}

and, apart from the external name thing (grr), that should address
these fragmentation issues, no?  I assume it's easy to ask slab how
many pages are presently in use for a particular cache.
