Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E07886B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 11:38:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so18523810lfq.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 08:38:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id zl3si4880619wjb.1.2016.05.03.08.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 08:38:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so4454612wmw.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 08:38:25 -0700 (PDT)
Date: Tue, 3 May 2016 17:38:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used
 explicitly from memalloc_no{fs,io}_{save,restore} context
Message-ID: <20160503153823.GB4470@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-3-git-send-email-mhocko@kernel.org>
 <20160426225845.GF26977@dastard>
 <20160428081759.GA31489@dhcp22.suse.cz>
 <20160428215145.GM26977@dastard>
 <20160429121219.GL21977@dhcp22.suse.cz>
 <20160429234008.GN26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429234008.GN26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, xfs@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>

On Sat 30-04-16 09:40:08, Dave Chinner wrote:
> On Fri, Apr 29, 2016 at 02:12:20PM +0200, Michal Hocko wrote:
[...]
> > - was it 
> > "inconsistent {RECLAIM_FS-ON-[RW]} -> {IN-RECLAIM_FS-[WR]} usage"
> > or a different class reports?
> 
> Typically that was involved, but it quite often there'd be a number
> of locks and sometimes even interrupt stacks in an interaction
> between 5 or 6 different processes. Lockdep covers all sorts of
> stuff now (like fs freeze annotations as well as locks and memory
> reclaim) so sometimes the only thing we can do is remove the
> reclaim context from the stack and see if that makes it go away...

That is what I was thinking of. lockdep_reclaim_{disable,enable} or
something like that to tell __lockdep_trace_alloc to not skip
mark_held_locks(). This would effectivelly help to get rid of reclaim
specific reports. It is hard to tell whether there would be others,
though.

> > > They may have been fixed since, but I'm sceptical
> > > of that because, generally speaking, developer testing only catches
> > > the obvious lockdep issues. i.e. it's users that report all the
> > > really twisty issues, and they are generally not reproducable except
> > > under their production workloads...
> > > 
> > > IOWs, the absence of reports in your testing does not mean there
> > > isn't a problem, and that is one of the biggest problems with
> > > lockdep annotations - we have no way of ever knowing if they are
> > > still necessary or not without exposing users to regressions and
> > > potential deadlocks.....
> > 
> > I understand your points here but if we are sure that those lockdep
> > reports are just false positives then we should rather provide an api to
> > silence lockdep for those paths
> 
> I agree with this - please provide such infrastructure before we
> need it...

Do you think a reclaim specific lockdep annotation would be sufficient?

> > than abusing GFP_NOFS which a) hurts
> > the overal reclaim healthiness
> 
> Which doesn't actually seem to be a problem for the vast majority of
> users.

Yes, most users are OK. Those allocations can be triggered by the
userspace (read a malicious user) quite easily and be harmful without a
good way to contain them.
 
> > and b) works around a non-existing
> > problem with lockdep disabled which is the vast majority of
> > configurations.
> 
> But the moment we have a lockdep problem, we get bug reports from
> all over the place and people complaining about it, so we are
> *required* to silence them one way or another. And, like I said,
> when the choice is simply adding GFP_NOFS or spending a week or two
> completely reworking complex code that has functioned correctly for
> 15 years, the risk/reward *always* falls on the side of "just add
> GFP_NOFS".
> 
> Please keep in mind that there is as much code in fs/xfs as there is
> in the mm/ subsystem, and XFS has twice that in userspace as well.
> I say this, because we have only have 3-4 full time developers to do
> all the work required on this code base, unlike the mm/ subsystem
> which had 30-40 full time MM developers attending LSFMM. This is why
> I push back on suggestions that require significant redesign of
> subsystem code to handle memory allocation/reclaim quirks - most
> subsystems simply don't have the resources available to do such
> work, and so will always look for the quick 2 minute fix when it is
> available....

I do understand your concerns and I really do not ask you to redesign
your code. I would like make the code more maintainable and reducing the
number of (undocumented) GFP_NOFS usage to the minimum seems to be like
a first step. Now the direct usage of GFP_NOFS (resp. KM_NOFS) in xfs is
not that large. If we can reduce the few instances which are using the
flag to silence the lockdep and replace them by a better annotation then
I think this would be an improvement as well. If we can go one step
further and can get rid of mapping_set_gfp_mask(inode->i_mapping,
(gfp_mask & ~(__GFP_FS))) then I would be even happier.

I think other fs and code which interacts with FS layer needs much more
changes than xfs to be honest.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
