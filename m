Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7506B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 19:40:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m2so275941152ioa.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 16:40:13 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id w74si3511503iod.51.2016.04.29.16.40.11
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 16:40:12 -0700 (PDT)
Date: Sat, 30 Apr 2016 09:40:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used
 explicitly from memalloc_no{fs,io}_{save,restore} context
Message-ID: <20160429234008.GN26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-3-git-send-email-mhocko@kernel.org>
 <20160426225845.GF26977@dastard>
 <20160428081759.GA31489@dhcp22.suse.cz>
 <20160428215145.GM26977@dastard>
 <20160429121219.GL21977@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429121219.GL21977@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, xfs@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 29, 2016 at 02:12:20PM +0200, Michal Hocko wrote:
> On Fri 29-04-16 07:51:45, Dave Chinner wrote:
> > On Thu, Apr 28, 2016 at 10:17:59AM +0200, Michal Hocko wrote:
> > > [Trim the CC list]
> > > On Wed 27-04-16 08:58:45, Dave Chinner wrote:
> > > [...]
> > > > Often these are to silence lockdep warnings (e.g. commit b17cb36
> > > > ("xfs: fix missing KM_NOFS tags to keep lockdep happy")) because
> > > > lockdep gets very unhappy about the same functions being called with
> > > > different reclaim contexts. e.g.  directory block mapping might
> > > > occur from readdir (no transaction context) or within transactions
> > > > (create/unlink). hence paths like this are tagged with GFP_NOFS to
> > > > stop lockdep emitting false positive warnings....
> > > 
> > > As already said in other email, I have tried to revert the above
> > > commit and tried to run it with some fs workloads but didn't manage
> > > to hit any lockdep splats (after I fixed my bug in the patch 1.2). I
> > > have tried to find reports which led to this commit but didn't succeed
> > > much. Everything is from much earlier or later. Do you happen to
> > > remember which loads triggered them, what they looked like or have an
> > > idea what to try to reproduce them? So far I was trying heavy parallel
> > > fs_mark, kernbench inside a tiny virtual machine so any of those have
> > > triggered direct reclaim all the time.
> > 
> > Most of those issues were reported by users and not reproducable by
> > any obvious means.
> 
> I would really appreciate a reference to some of those (my google-fu has
> failed me) or at least a pattern of those splats

If you can't find them with google, then I won't. Google is mostly
useless as a patch/mailing list search tool these days. You can try
looking through this list:

https://www.google.com.au/search?q=XFS+lockdep+site:oss.sgi.com+-splice

but I'm not seeing anything particularly relevant in that list -
there isn't a single reclaim related lockdep report in that...

> - was it 
> "inconsistent {RECLAIM_FS-ON-[RW]} -> {IN-RECLAIM_FS-[WR]} usage"
> or a different class reports?

Typically that was involved, but it quite often there'd be a number
of locks and sometimes even interrupt stacks in an interaction
between 5 or 6 different processes. Lockdep covers all sorts of
stuff now (like fs freeze annotations as well as locks and memory
reclaim) so sometimes the only thing we can do is remove the
reclaim context from the stack and see if that makes it go away...
> 
> > They may have been fixed since, but I'm sceptical
> > of that because, generally speaking, developer testing only catches
> > the obvious lockdep issues. i.e. it's users that report all the
> > really twisty issues, and they are generally not reproducable except
> > under their production workloads...
> > 
> > IOWs, the absence of reports in your testing does not mean there
> > isn't a problem, and that is one of the biggest problems with
> > lockdep annotations - we have no way of ever knowing if they are
> > still necessary or not without exposing users to regressions and
> > potential deadlocks.....
> 
> I understand your points here but if we are sure that those lockdep
> reports are just false positives then we should rather provide an api to
> silence lockdep for those paths

I agree with this - please provide such infrastructure before we
need it...

> than abusing GFP_NOFS which a) hurts
> the overal reclaim healthiness

Which doesn't actually seem to be a problem for the vast majority of
users.

> and b) works around a non-existing
> problem with lockdep disabled which is the vast majority of
> configurations.

But the moment we have a lockdep problem, we get bug reports from
all over the place and people complaining about it, so we are
*required* to silence them one way or another. And, like I said,
when the choice is simply adding GFP_NOFS or spending a week or two
completely reworking complex code that has functioned correctly for
15 years, the risk/reward *always* falls on the side of "just add
GFP_NOFS".

Please keep in mind that there is as much code in fs/xfs as there is
in the mm/ subsystem, and XFS has twice that in userspace as well.
I say this, because we have only have 3-4 full time developers to do
all the work required on this code base, unlike the mm/ subsystem
which had 30-40 full time MM developers attending LSFMM. This is why
I push back on suggestions that require significant redesign of
subsystem code to handle memory allocation/reclaim quirks - most
subsystems simply don't have the resources available to do such
work, and so will always look for the quick 2 minute fix when it is
available....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
