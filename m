Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A58A16B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 18:48:54 -0500 (EST)
Date: Tue, 15 Nov 2011 23:48:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111115234845.GK27150@suse.de>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <20111114154408.10de1bc7.akpm@linux-foundation.org>
 <20111115132513.GF27150@suse.de>
 <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 15, 2011 at 01:07:51PM -0800, David Rientjes wrote:
> On Tue, 15 Nov 2011, Mel Gorman wrote:
> 
> > Fine control is limited. If it is really needed, I would not oppose
> > a patch that allows the use of sync compaction via a new setting in
> > /sys/kernel/mm/transparent_hugepage/defrag. However, I think it is
> > a slippery slope to expose implementation details like this and I'm
> > not currently planning to implement such a patch.
> > 
> 
> This doesn't expose any implementation detail, the "defrag" tunable is 
> supposed to limit defragmentation efforts in the VM if the hugepages 
> aren't immediately available and simply fallback to using small pages.  

The current settings are "always", "madvise" and "never" which matches
the settings for /sys/kernel/mm/transparent_hugepage/enabled and are
fairly straight forward.

Adding sync here could obviously be implemented although it may
require both always-sync and madvise-sync. Alternatively, something
like an options file could be created to create a bitmap similar to
what ftrace does. Whatever the mechanism, it exposes the fact that
"sync compaction" is used. If that turns out to be not enough, then
you may want to add other steps like aggressively reclaiming memory
which also potentially may need to be controlled via the sysfs file
and this is the slippery slope.

> Given that definition, it would make sense to allow for synchronous 
> defragmentation (i.e. sync_compaction) on the second iteration of the page 
> allocator slowpath if set.  So where's the disconnect between this 
> proposed behavior and the definition of the tunable in 
> Documentation/vm/transhuge.txt?

The transhuge.txt file does not describe how defrag works or whether it
uses sync compaction internally.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
