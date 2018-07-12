Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D86206B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:04:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s16-v6so17488493plr.22
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:04:59 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id u13-v6si7955914pgg.263.2018.07.12.09.04.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 09:04:58 -0700 (PDT)
Message-ID: <1531411494.18255.6.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 12 Jul 2018 09:04:54 -0700
In-Reply-To: <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
	 <20180709081920.GD22049@dhcp22.suse.cz>
	 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
	 <20180710142740.GQ14284@dhcp22.suse.cz>
	 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
	 <20180711102139.GG20050@dhcp22.suse.cz>
	 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	 <1531330947.3260.13.camel@HansenPartnership.com>
	 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Thu, 2018-07-12 at 11:54 -0400, Waiman Long wrote:
> On 07/11/2018 03:21 PM, James Bottomley wrote:
> > On Wed, 2018-07-11 at 15:07 -0400, Waiman Long wrote:
> > > On 07/11/2018 01:42 PM, James Bottomley wrote:
> > > > On Wed, 2018-07-11 at 11:13 -0400, Waiman Long wrote:
> > > > > On 07/11/2018 06:21 AM, Michal Hocko wrote:
> > > > > > On Tue 10-07-18 12:09:17, Waiman Long wrote:
> > > > 
> > > > [...]
> > > > > > > I am going to reduce the granularity of each unit to
> > > > > > > 1/1000
> > > > > > > of the total system memory so that for large system with
> > > > > > > TB
> > > > > > > of memory, a smaller amount of memory can be specified.
> > > > > > 
> > > > > > It is just a matter of time for this to be too coarse as
> > > > > > well.
> > > > > 
> > > > > The goal is to not have too much memory being consumed by
> > > > > negative
> > > > > dentries and also the limit won't be reached by regular daily
> > > > > activities. So a limit of 1/1000 of the total system memory
> > > > > will
> > > > > be good enough on large memory system even if the absolute
> > > > > number
> > > > > is really big.
> > > > 
> > > > OK, I think the reason we're going round and round here without
> > > > converging is that one of the goals of the mm subsystem is to
> > > > manage all of our cached objects and to it the negative (and
> > > > positive) dentries simply look like a clean cache of
> > > > objects.A A Right at the moment mm manages them in the same way
> > > > it
> > > > manages all the other caches, a lot of which suffer from the
> > > > "you
> > > > can cause lots of allocations to artificially grow them"
> > > > problem.A A So the main question is why doesn't the current mm
> > > > control of the caches work well enough for dentries?A 
> > > > What are the problems you're seeing that mm should be
> > > > catching?A A If
> > > > you can answer this, then we could get on to whether a separate
> > > > shrinker, cache separation or some fix in mm itself is the
> > > > right
> > > > answer.
> > > > 
> > > > What you say above is based on a conclusion: limiting dentries
> > > > improves the system performance.A A What we're asking for is
> > > > evidence
> > > > for that conclusion so we can explore whether the same would go
> > > > for
> > > > any of our other system caches (so do we have a global cache
> > > > management problem or is it only the dentry cache?)
> > > > 
> > > > James
> > > > 
> > > 
> > > I am not saying that limiting dentries will improve performance.
> > > I am
> > > just saying that unlimited growth in the number of negative
> > > dentries
> > > will reduce the amount of memory available to other applications
> > > and
> > > hence will have an impact on performance. Normally the amount of
> > > memory consumed by dentries is a very small portion of the system
> > > memory.
> > 
> > OK, can we poke on only this point for a while?A A Linux never really
> > has
> > any "available memory": pretty much as soon as you boot up the
> > system
> > will consume all your free memory for some type of cache (usually
> > the
> > page cache which got filled during boot).A A The expectation is that
> > in a
> > steady, running, state the system is using almost all available
> > memory
> > for caching something ... if it's not negative dentries it will be
> > something else.A A The mm assumption is that clean cache is so cheap
> > to
> > recover that it's almost equivalent to free memory and your patch
> > is
> > saying this isn't so and we have a problem dumping the dentry
> > cache.
> > 
> > So, why can't we treat the dentry cache as equivalent to free
> > memory?A 
> > What in your tests is making it harder to recover the memory in the
> > dentry cache?
> > 
> > James
> 
> It is not that dentry cache is harder to get rid of than the other
> memory. It is that the ability of generate unlimited number of
> negative dentries that will displace other useful memory from the
> system. What the patch is trying to do is to have a warning or
> notification system in place to spot unusual activities in regard to
> the number of negative dentries in the system. The system
> administrators can then decide on what to do next.

But every cache has this property: I can cause the same effect by doing
a streaming read on a multi gigabyte file: the page cache will fill
with the clean pages belonging to the file until I run out of memory
and it has to start evicting older cache entries.  Once we hit the
steady state of minimal free memory, the mm subsytem tries to balance
the cache requests (like my streaming read) against the existing pool
of cached objects.

The question I'm trying to get an answer to is why does the dentry
cache need special limits when the mm handling of the page cache (and
other mm caches) just works?

James


> For many user activities, there are ways to audit what the users are
> doing and what resources they are consuming. I don't think that is
> the case for negative dentries. The closest I can think of is the use
> of memory controller to limit the amount of kernel memory use. This
> patchset will provide more visibility about the memory consumption of
> negative dentries for the system as a whole, though it won't go into
> the per-user level. We just don't want a disproportionate amount of
> memory to be used up by negative dentries.
> 
> Cheers,
> Longman
> 
> Cheers,
> Longman
> 
