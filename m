Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA5606B0275
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:49:36 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so17656738plt.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:49:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 34-v6si21635929pgs.243.2018.07.12.09.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 09:49:35 -0700 (PDT)
Date: Thu, 12 Jul 2018 09:49:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180712164932.GA3475@bombadil.infradead.org>
References: <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz>
 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <1531330947.3260.13.camel@HansenPartnership.com>
 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531411494.18255.6.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Thu, Jul 12, 2018 at 09:04:54AM -0700, James Bottomley wrote:
> On Thu, 2018-07-12 at 11:54 -0400, Waiman Long wrote:
> > It is not that dentry cache is harder to get rid of than the other
> > memory. It is that the ability of generate unlimited number of
> > negative dentries that will displace other useful memory from the
> > system. What the patch is trying to do is to have a warning or
> > notification system in place to spot unusual activities in regard to
> > the number of negative dentries in the system. The system
> > administrators can then decide on what to do next.
> 
> But every cache has this property: I can cause the same effect by doing
> a streaming read on a multi gigabyte file: the page cache will fill
> with the clean pages belonging to the file until I run out of memory
> and it has to start evicting older cache entries.  Once we hit the
> steady state of minimal free memory, the mm subsytem tries to balance
> the cache requests (like my streaming read) against the existing pool
> of cached objects.
> 
> The question I'm trying to get an answer to is why does the dentry
> cache need special limits when the mm handling of the page cache (and
> other mm caches) just works?

I don't know that it does work.  Or that it works well.

When we try to allocate something and there's no memory readily available,
we ask all the shrinkers to shrink in order to free up memory.  That leads
to one kind of allocation (eg dentries) being able to easily kick all
the page cache out of the machine.

What we could do instead is first call the shrinker for the type of
object being allocated.  That is, assume the system is more or less in
equilibrium between all the different things it could be allocating,
and if something needs to be kicked out, it's better to kick out this
kind of thing rather than changing the equilibrium.

Of course, workloads change over time, and sometimes we should accept we
need more dentries and less page cache, or vice versa.  So we'd need a
scheme for the shrinker to say "this is getting hard, I think we do need
more dentries", and then we'd move on to calling the other shrinkers to
reclaim inodes or page cache or whatever.

I don't think we even try to work at this level today.  But it would
have the distinct advantage that we can implement this in the slab/slub
code rather than touching the page allocator.
