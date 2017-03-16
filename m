Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEE26B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:46:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so76357597pfb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:46:48 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id e1si4617332plk.239.2017.03.16.01.46.47
        for <linux-mm@kvack.org>;
        Thu, 16 Mar 2017 01:46:47 -0700 (PDT)
Date: Thu, 16 Mar 2017 01:47:33 -0700
From: lkml@pengaru.com
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170316084733.GP802@shells.gnugeneration.com>
References: <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316082714.GC30501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerhard Wiesinger <lists@wiesinger.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Mar 16, 2017 at 09:27:14AM +0100, Michal Hocko wrote:
> On Thu 16-03-17 07:38:08, Gerhard Wiesinger wrote:
> [...]
> > The following commit is included in that version:
> > commit 710531320af876192d76b2c1f68190a1df941b02
> > Author: Michal Hocko <mhocko@suse.com>
> > Date:   Wed Feb 22 15:45:58 2017 -0800
> > 
> >     mm, vmscan: cleanup lru size claculations
> > 
> >     commit fd538803731e50367b7c59ce4ad3454426a3d671 upstream.
> 
> This patch shouldn't make any difference. It is a cleanup patch.
> I guess you meant 71ab6cfe88dc ("mm, vmscan: consider eligible zones in
> get_scan_count") but even that one shouldn't make any difference for 64b
> systems.
> 
> > But still OOMs:
> > [157048.030760] clamscan: page allocation stalls for 19405ms, order:0, mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
> 
> This is not OOM it is an allocation stall. The allocation request cannot
> simply make forward progress for more than 10s. This alone is bad but
> considering this is GFP_HIGHUSER_MOVABLE which has the full reclaim
> capabilities I would suspect your workload overcommits the available
> memory too much. You only have ~380MB of RAM with ~160MB sitting in the
> anonymous memory, almost nothing in the page cache so I am not wondering
> that you see a constant swap activity. There seems to be only 40M in the
> slab so we are still missing ~180MB which is neither on the LRU lists
> nor allocated by slab. This means that some kernel subsystem allocates
> from the page allocator directly.
> 
> That being said, I believe that what you are seeing is not a bug in the
> MM subsystem but rather some susbsytem using more memory than it used to
> before so your workload doesn't fit into the amount of memory you have
> anymore.
> 

While on the topic of understanding allocation stalls, Philip Freeman recently
mailed linux-kernel with a similar report, and in his case there are plenty of
page cache pages.  It was also a GFP_HIGHUSER_MOVABLE 0-order allocation.

I'm no MM expert, but it appears a bit broken for such a low-order allocation
to stall on the order of 10 seconds when there's plenty of reclaimable pages,
in addition to mostly unused and abundant swap space on SSD.

Regards,
Vito Caputo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
