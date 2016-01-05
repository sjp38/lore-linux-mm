Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 059236B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:45:33 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so28034202wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:45:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x203si6102502wmx.3.2016.01.05.07.45.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 07:45:32 -0800 (PST)
Date: Tue, 5 Jan 2016 16:45:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Message-ID: <20160105154529.GG15324@dhcp22.suse.cz>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160105124735.GA15324@dhcp22.suse.cz>
 <20160105131039.GA19907@node.shutemov.name>
 <20160105133122.GB15324@dhcp22.suse.cz>
 <20160105150312.GC19907@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105150312.GC19907@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue 05-01-16 17:03:12, Kirill A. Shutemov wrote:
> On Tue, Jan 05, 2016 at 02:31:23PM +0100, Michal Hocko wrote:
> > On Tue 05-01-16 15:10:39, Kirill A. Shutemov wrote:
> > > On Tue, Jan 05, 2016 at 01:47:35PM +0100, Michal Hocko wrote:
> > > > On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
> > > > > As far as I can see we explicitly munlock pages everywhere before unmap
> > > > > them. The only case when we don't to that is OOM-reaper.
> > > > 
> > > > Very well spotted!
> > > > 
> > > > > I don't think we should bother with munlocking in this case, we can just
> > > > > skip the locked VMA.
> > > > 
> > > > Why cannot we simply munlock them here for the private mappings?
> > > 
> > > It's probably right think to do, but I wanted to fix the bug first.
> > 
> > Fair enough. It is surely simpler, although I think we should tear
> > private mappings down even when mlocked. I can cook up a separate patch
> > on top of yours which is obviously correct and can be folded into the
> > original one.
> 
> I prefer it not to be folded. To be able to revert in something go wrong.

Sorry, I meant your fixup should be folded. The one to allow munlock as
a separate fix.
> 
> > > And I wasn't ready to investigate context the reaper working in to check
> > > if it's safe to munlock there. For instance, munlock would take page lock
> > > and I'm not sure at the moment if it can or cannot lead to deadlock in
> > > some scenario. So I choose safer fix.
> > 
> > repear is a flat kernel thread context which doesn't sit on any locks
> > (except for mmap sem for read taken on the way) so I do not immediately
> > see any potential for the dead lock. If the original context which
> > wakes it up depend on the page lock to move on then we would be screwed
> > already because we can end up doing exit_mmap in that context already
> > and so end up doing munlock as well.
> 
> Can target process hold page lock? Or a process in direct replaim?

The target process is the OOM victim. It can be doing anything.
Including holding the page lock. But it cannot be holding page lock
while doing the allocation or invoking the OOM killer because that would
be a deadlock already even without oom reaper in the picture.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
