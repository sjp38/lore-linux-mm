Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 578756B038C
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 12:50:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u199so18755936wmd.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 09:50:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a79si22749591wmi.121.2017.03.01.09.49.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 09:49:59 -0800 (PST)
Date: Wed, 1 Mar 2017 18:49:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170301174955.GB20360@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
 <20170301173710.GA12867@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301173710.GA12867@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed 01-03-17 09:37:10, Shaohua Li wrote:
> On Wed, Mar 01, 2017 at 02:36:24PM +0100, Michal Hocko wrote:
> > On Fri 24-02-17 13:31:49, Shaohua Li wrote:
> > > show MADV_FREE pages info of each vma in smaps. The interface is for
> > > diganose or monitoring purpose, userspace could use it to understand
> > > what happens in the application. Since userspace could dirty MADV_FREE
> > > pages without notice from kernel, this interface is the only place we
> > > can get accurate accounting info about MADV_FREE pages.
> > 
> > I have just got to test this patchset and noticed something that was a
> > bit surprising
> > 
> > madvise(mmap(len), len, MADV_FREE)
> > Size:             102400 kB
> > Rss:              102400 kB
> > Pss:              102400 kB
> > Shared_Clean:          0 kB
> > Shared_Dirty:          0 kB
> > Private_Clean:    102400 kB
> > Private_Dirty:         0 kB
> > Referenced:            0 kB
> > Anonymous:        102400 kB
> > LazyFree:         102368 kB
> > 
> > It took me a some time to realize that LazyFree is not accurate because
> > there are still pages on the per-cpu lru_lazyfree_pvecs. I believe this
> > is an implementation detail which shouldn't be visible to the userspace.
> > Should we simply drain the pagevec? A crude way would be to simply
> > lru_add_drain_all after we are done with the given range. We can also
> > make this lru_lazyfree_pvecs specific but I am not sure this is worth
> > the additional code.
> 
> Minchan's original patch includes a drain of pvec. I discard it because I think
> it's not worth the effort. There aren't too many memory in the per-cpu vecs.

but multiply that by the number of CPUs.

> Like what you said, I doubt this is noticeable to userspace.

maybe I wasn't clear enough. I've noticed and I expect others would as
well. We really shouldn't leak implementation details like that. So I
_believe_ this should be fixed. Draining all pagevecs is rather coarse
but it is the simplest thing to do. If you do not want to fold this
into the original patch I can send a standalone one. Or do you have any
concerns about draining?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
