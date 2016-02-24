Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 961B26B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 19:36:57 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id c200so246342051wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:36:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n9si387345wja.248.2016.02.23.16.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 16:36:56 -0800 (PST)
Date: Tue, 23 Feb 2016 16:36:49 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160224003649.GA3175@cmpxchg.org>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.10.1602221818370.25668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602221818370.25668@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Feb 22, 2016 at 06:23:19PM -0800, David Rientjes wrote:
> On Mon, 22 Feb 2016, Johannes Weiner wrote:
> 
> > In machines with 140G of memory and enterprise flash storage, we have
> > seen read and write bursts routinely exceed the kswapd watermarks and
> > cause thundering herds in direct reclaim. Unfortunately, the only way
> > to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> > the system's emergency reserves - which is entirely unrelated to the
> > system's latency requirements. In order to get kswapd to maintain a
> > 250M buffer of free memory, the emergency reserves need to be set to
> > 1G. That is a lot of memory wasted for no good reason.
> > 
> > On the other hand, it's reasonable to assume that allocation bursts
> > and overall allocation concurrency scale with memory capacity, so it
> > makes sense to make kswapd aggressiveness a function of that as well.
> > 
> > Change the kswapd watermark scale factor from the currently fixed 25%
> > of the tunable emergency reserve to a tunable 0.001% of memory.
> > 
> 
> Making this tunable independent of min_free_kbytes is great.
> 
> I'm wondering how the choice of 0.001% was picked for default?  One of my 
> workstations currently has step sizes of about 0.0005% so this will be 
> doubling the steps from min to low and low to high.  I'm not objecting to 
> that since it's definitely in the right direction (more free memory) but I 
> wonder if it will make a difference for some users.

I wish it were a bit more scientific, but I basically picked an order
of magnitude that sounds like a reasonable balance between wasted
memory and expected allocation bursts before kswapd can ramp up.

On a 10G machine, a 10M latency buffer sounds adequate, whereas 1M
might get overwhelmed and 100M is almost certainly a waste of RAM.

> > Beyond 1G of memory, this will produce bigger watermark steps than the
> > current formula in default settings. Ensure that the new formula never
> > chooses steps smaller than that, i.e. 25% of the emergency reserve.
> > 
> > On a 140G machine, this raises the default watermark steps - the
> > distance between min and low, and low and high - from 16M to 143M.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  Documentation/sysctl/vm.txt | 18 ++++++++++++++++++
> >  include/linux/mm.h          |  1 +
> >  include/linux/mmzone.h      |  2 ++
> >  kernel/sysctl.c             | 10 ++++++++++
> >  mm/page_alloc.c             | 29 +++++++++++++++++++++++++++--
> >  5 files changed, 58 insertions(+), 2 deletions(-)
> > 
> > v2: Ensure 25% of emergency reserves as a minimum on small machines -Rik
> > 
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index 89a887c..b02d940 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -803,6 +803,24 @@ performance impact. Reclaim code needs to take various locks to find freeable
> >  directory and inode objects. With vfs_cache_pressure=1000, it will look for
> >  ten times more freeable objects than there are.
> >  
> > +=============================================================
> > +
> > +watermark_scale_factor:
> > +
> > +This factor controls the aggressiveness of kswapd. It defines the
> > +amount of memory left in a node/system before kswapd is woken up and
> > +how much memory needs to be free before kswapd goes back to sleep.
> > +
> > +The unit is in fractions of 10,000. The default value of 10 means the
> > +distances between watermarks are 0.001% of the available memory in the
> > +node/system. The maximum value is 1000, or 10% of memory.
> > +
> 
> The effective maximum value can be different than the tunable, though,
> correct?  It seems like you'd want to document why watermark_scale_factor
> and the actual watermarks in /proc/zoneinfo may be different on some
> systems.

You mean because of the enforced minimum? I wondered about that, but
it seems more like an implementation detail rather than part of the
API. I doubt that in practice anybody would intentionally set the
scale factor low enough for the kernel minimum to kick in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
