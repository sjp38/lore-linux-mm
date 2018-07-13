Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03D5B6B0273
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:17:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d1-v6so5492479pfo.16
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:17:22 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id z23-v6si24957042pfh.266.2018.07.13.16.17.20
        for <linux-mm@kvack.org>;
        Fri, 13 Jul 2018 16:17:21 -0700 (PDT)
Date: Sat, 14 Jul 2018 09:17:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180713231717.GX2234@dastard>
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <1531496812.3361.9.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1531496812.3361.9.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Fri, Jul 13, 2018 at 08:46:52AM -0700, James Bottomley wrote:
> On Fri, 2018-07-13 at 10:36 +1000, Dave Chinner wrote:
> > On Thu, Jul 12, 2018 at 12:57:15PM -0700, James Bottomley wrote:
> > > What surprises me most about this behaviour is the steadiness of
> > > the page cache ... I would have thought we'd have shrunk it
> > > somewhat given the intense call on the dcache.
> > 
> > Oh, good, the page cache vs superblock shrinker balancing still
> > protects the working set of each cache the way it's supposed to
> > under heavy single cache pressure. :)
> 
> Well, yes, but my expectation is most of the page cache is clean, so
> easily reclaimable.  I suppose part of my surprise is that I expected
> us to reclaim the clean caches first before we started pushing out the
> dirty stuff and reclaiming it.  I'm not saying it's a bad thing, just
> saying I didn't expect us to make such good decisions under the
> parameters of this test.

The clean caches are still turned over by the workload, but it is
very slow and only enough to eject old objects that have fallen out
of the working set. We've got a lot better at keeping the working
set in memory in adverse conditions over the past few years...

> > Keep in mind that the amount of work slab cache shrinkers perform is
> > directly proportional to the amount of page cache reclaim that is
> > performed and the size of the slab cache being reclaimed.  IOWs,
> > under a "single cache pressure" workload we should be directing
> > reclaim work to the huge cache creating the pressure and do very
> > little reclaim from other caches....
> 
> That definitely seems to happen.  The thing I was most surprised about
> is the steady pushing of anonymous objects to swap.  I agree the dentry
> cache doesn't seem to be growing hugely after the initial jump, so it
> seems to be the largest source of reclaim.

Which means swap behaviour has changed since I last looked at
reclaim balance several years ago. These sorts of dentry/inode loads
never used to push the system to swap. Not saying it's a bad thing,
just that it is different. :)

> > [ What follows from here is conjecture, but is based on what I've
> > seen in the past 10+ years on systems with large numbers of negative
> > dentries and fragmented dentry/inode caches. ]
> 
> OK, so I fully agree with the concern about pathological object vs page
> freeing problems (I referred to it previously).  However, I did think
> the compaction work that's been ongoing in mm was supposed to help
> here?

Compaction doesn't touch slab caches. We can't move active dentries
and other slab objects around in memory because they have external
objects with active references that point directly to them. Getting
exclusive access to active objects and all the things that point to
them from reclaim so we can move them is an intractable problem - it
has sunk slab cache defragmentation every time it has been attempted
in the past 15 years....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
