Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A8D4A6B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 12:24:22 -0400 (EDT)
Received: by lahe2 with SMTP id e2so78837688lah.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 09:24:21 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id u7si1622502lae.3.2015.07.22.09.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 09:24:20 -0700 (PDT)
Date: Wed, 22 Jul 2015 19:23:53 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150722162353.GM23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Tue, Jul 21, 2015 at 04:34:02PM -0700, Andrew Morton wrote:
> On Sun, 19 Jul 2015 15:31:09 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Hi,
> > 
> > This patch set introduces a new user API for tracking user memory pages
> > that have not been used for a given period of time. The purpose of this
> > is to provide the userspace with the means of tracking a workload's
> > working set, i.e. the set of pages that are actively used by the
> > workload. Knowing the working set size can be useful for partitioning
> > the system more efficiently, e.g. by tuning memory cgroup limits
> > appropriately, or for job placement within a compute cluster.
> > 
> > It is based on top of v4.2-rc2-mmotm-2015-07-15-16-46
> > It applies without conflicts to v4.2-rc2-mmotm-2015-07-17-16-04 as well
> > 
> > ---- USE CASES ----
> > 
> > The unified cgroup hierarchy has memory.low and memory.high knobs, which
> > are defined as the low and high boundaries for the workload working set
> > size. However, the working set size of a workload may be unknown or
> > change in time. With this patch set, one can periodically estimate the
> > amount of memory unused by each cgroup and tune their memory.low and
> > memory.high parameters accordingly, therefore optimizing the overall
> > memory utilization.
> > 
> > Another use case is balancing workloads within a compute cluster.
> > Knowing how much memory is not really used by a workload unit may help
> > take a more optimal decision when considering migrating the unit to
> > another node within the cluster.
> > 
> > Also, as noted by Minchan, this would be useful for per-process reclaim
> > (https://lwn.net/Articles/545668/). With idle tracking, we could reclaim idle
> > pages only by smart user memory manager.
> > 
> > ---- USER API ----
> > 
> > The user API consists of two new proc files:
> > 
> >  * /proc/kpageidle.  This file implements a bitmap where each bit corresponds
> >    to a page, indexed by PFN.
> 
> What are the bit mappings?  If I read the first byte of /proc/kpageidle
> I get PFN #0 in bit zero of that byte?  And the second byte of
> /proc/kpageidle contains PFN #8 in its LSB, etc?

The bit mapping is an array of u64 elements. Page at pfn #i corresponds
to bit #i%64 of element #i/64. Byte order is native.

Will add this to docs.

> 
> Maybe this is covered in the documentation file.
> 
> > When the bit is set, the corresponding page is
> >    idle. A page is considered idle if it has not been accessed since it was
> >    marked idle.
> 
> Perhaps we can spell out in some detail what "accessed" means?  I see
> you've hooked into mark_page_accessed(), so a read from disk is an
> access.  What about a write to disk?  And what about a page being
> accessed from some random device (could hook into get_user_pages()?) Is
> getting written to swap an access?  When a dirty pagecache page is
> written out by kswapd or direct reclaim?
> 
> This also should be in the permanent documentation.

OK, will add.

> 
> > To mark a page idle one should set the bit corresponding to the
> >    page by writing to the file. A value written to the file is OR-ed with the
> >    current bitmap value. Only user memory pages can be marked idle, for other
> >    page types input is silently ignored. Writing to this file beyond max PFN
> >    results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
> >    set.
> > 
> >    This file can be used to estimate the amount of pages that are not
> >    used by a particular workload as follows:
> > 
> >    1. mark all pages of interest idle by setting corresponding bits in the
> >       /proc/kpageidle bitmap
> >    2. wait until the workload accesses its working set
> >    3. read /proc/kpageidle and count the number of bits set
> 
> Security implications.  This interface could be used to learn about a
> sensitive application by poking data at it and then observing its
> memory access patterns.  Perhaps this is why the proc files are
> root-only (whcih I assume is sufficient). 

That's one point. Another point is that if we allow unprivileged users
to access it, they may interfere with the system-wide daemon doing the
regular scan and estimating the system wss.

> Some words here about the security side of things and the reasoning
> behind the chosen permissions would be good to have.
> 
> >  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
> >    memory cgroup each page is charged to, indexed by PFN.
> 
> Actually "closest online ancestor".  This also should be in the
> interface documentation.

Actually, the userspace knows nothing about online/offline cgroups,
because all cgroups used to be online and charge re-parenting was used
to forcibly empty a memcg on deletion. Anyways, I'll add a note.

> 
> > Only available when CONFIG_MEMCG is set.
> 
> CONFIG_MEMCG and CONFIG_IDLE_PAGE_TRACKING I assume?

No, it's present iff CONFIG_PROC_PAGE_MONITOR && CONFIG_MEMCG, because
it might be useful even w/o CONFIG_IDLE_PAGE_TRACKING, e.g. in order to
find out which memcg  pages of a particular process are accounted to.

> 
> > 
> >    This file can be used to find all pages (including unmapped file
> >    pages) accounted to a particular cgroup. Using /proc/kpageidle, one
> >    can then estimate the cgroup working set size.
> > 
> > For an example of using these files for estimating the amount of unused
> > memory pages per each memory cgroup, please see the script attached
> > below.
> 
> Why were these put in /proc anyway?  Rather than under /sys/fs/cgroup
> somewhere?  Presumably because /proc/kpageidle is useful in non-memcg
> setups.

Yes, one might use it for estimating active wss of a single process or
the whole system.

> 
> > ---- PERFORMANCE EVALUATION ----
> 
> "^___" means "end of changelog".  Perhaps that should have been
> "^---\n" - unclear.

Sorry :-/

> 
> > Documentation/vm/pagemap.txt           |  22 ++-
> 
> I think we'll need quite a lot more than this to fully describe the
> interface?

Agree, the documentation sucks :-( Will try to forge something more
thorough.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
