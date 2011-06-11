Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFB226B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 14:04:29 -0400 (EDT)
Date: Sat, 11 Jun 2011 20:04:15 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-ID: <20110611180415.GB31154@cmpxchg.org>
References: <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
 <BANLkTi=bBSeMFtUDyz+px1Kt34HDU=DEcw@mail.gmail.com>
 <alpine.LSU.2.00.1106110847190.29336@sister.anvils>
 <20110611163943.GA3238@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110611163943.GA3238@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Jun 11, 2011 at 06:39:43PM +0200, Andrea Arcangeli wrote:
> On Sat, Jun 11, 2011 at 09:04:14AM -0700, Hugh Dickins wrote:
> > I had another go at reproducing it, 2 hours that time, then a try with
> > 692e0b35427a reverted: it ran overnight for 9 hours when I stopped it.
> > 
> > Andrea, please would you ask Linus to revert that commit before -rc3?
> > Or is there something else you'd like us to try instead?  I admit that
> > I've not actually taken the time to think through exactly how it goes
> > wrong, but it does look dangerous.
> 
> Here I was asked if the mem_cgroup_newpage_charge need the mmap_sem at
> all. And if not why not to release the mmap_sem early.
> 
> https://lkml.org/lkml/2011/3/14/276
> 
> So I didn't see why mmap_sem was needed, I also asked confirmation and
> who answered agreed it was safe without mmap_sem even if it's the only
> place doing that. Maybe that assumption was wrong and we need
> mmap_sem after all if this commit is causing problems.
> 
> Or did you find something wrong in the actual patch?
> 
> Do I understand right that the bug just that we must run
> alloc_hugepage_vma+mem_cgroup_newpage_charge within the same critical
> section protected by the mmap_sem read mode? Do we know why?

The problem is that mm->owner points to a stale task structure if the
last possible owner is exiting.  The mmap_sem just prevented the task
from actually exiting through write-acquiring the mmap_sem in
khugepaged_exit().

I think enforcing lifetime of an object through locks is not the
nicest thing to do, so I stand by what I wrote in the mail you linked
to above :) and agree with Kame that mm->owner should just not point
to a stale task struct.  The memcg code can handle it going NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
