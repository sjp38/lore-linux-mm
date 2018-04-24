Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 674646B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:30:47 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u8so13702502qkg.15
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:30:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k16-v6si4014345qta.340.2018.04.24.08.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 08:30:46 -0700 (PDT)
Date: Tue, 24 Apr 2018 11:30:40 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180424133146.GG17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com> <20180424133146.GG17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> 
> > Fixing __vmalloc code 
> > is easy and it doesn't require cooperation with maintainers.
> 
> But it is a hack against the intention of the scope api.

It is not! You can fix __vmalloc now and you can convert the kernel to the 
scope API in 4 years. It's not one way or the other.

> It also alows maintainers to not care about their broken code.

Most maintainers don't even know that it's broken. Out of 14 subsystems 
using __vmalloc with GFP_NOIO/NOFS, only 2 realized that its 
implementation is broken and implemented a workaround (me and the XFS 
developers).

Misimplementing a function in a subtle and hard-to-notice way won't drive 
developers away from using it.

> > > > He refuses 15-line patch to fix GFP_NOIO bug because he believes that in 4 
> > > > years, the kernel will be refactored and GFP_NOIO will be eliminated. Why 
> > > > does he have veto over this part of the code? I'd much rather argue with 
> > > > people who have constructive comments about fixing bugs than with him.
> > > 
> > > I didn't NACK the patch AFAIR. I've said it is not a good idea longterm.
> > > I would be much more willing to change my mind if you would back your
> > > patch by a real bug report. Hacks are acceptable when we have a real
> > > issue in hands. But if we want to fix potential issue then better make
> > > it properly.
> > 
> > Developers should fix bugs in advance, not to wait until a crash hapens, 
> > is analyzed and reported.
> 
> I agree. But are those existing users broken in the first place? I have
> seen so many GFP_NOFS abuses that I would dare to guess that most of
> those vmalloc NOFS abusers can be simply turned into GFP_KERNEL. Maybe
> that is the reason we haven't heard any complains in years.

alloc_pages reclaims clean pages and most hard work is done by kswapd, so 
GFP_KERNEL doesn't cause much issues with writeback. But cheating isn't 
justified if you can get away with it. Incorrect GFP flags cause real 
problems with shrinkers - because shrinkers are called from alloc_pages 
and they do respond to GFP flags.

I had reported deadlock due to GFP issues (9d28eb12447). And the worst 
thing about these bug reports is that they are totally unreproducible and 
I get nothing, but a stacktrace in bugzilla. I had to guess what happened 
and I couldn't even test if the patch fixed the bug.

I'm not really happy that you are deliberately leaving these issues behind 
and making excuses.

Mikulas
