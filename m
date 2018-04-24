Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D03A6B0010
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:31:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a38-v6so22138444wra.10
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:31:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si2107334edh.126.2018.04.24.06.31.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 06:31:53 -0700 (PDT)
Date: Tue, 24 Apr 2018 07:31:46 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180424133146.GG17484@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> 
> 
> On Mon, 23 Apr 2018, Michal Hocko wrote:
> 
> > On Mon 23-04-18 10:06:08, Mikulas Patocka wrote:
> > 
> > > > > He didn't want to fix vmalloc(GFP_NOIO)
> > > > 
> > > > I don't remember that conversation, so I don't know whether I agree with
> > > > his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> > > > towards marking regions with memalloc_noio_save() / restore.  If you do
> > > > that, you won't need vmalloc(GFP_NOIO).
> > > 
> > > He said the same thing a year ago. And there was small progress. 6 out of 
> > > 27 __vmalloc calls were converted to memalloc_noio_save in a year - 5 in 
> > > infiniband and 1 in btrfs. (the whole discussion is here 
> > > http://lkml.iu.edu/hypermail/linux/kernel/1706.3/04681.html )
> > 
> > Well this is not that easy. It requires a cooperation from maintainers.
> > I can only do as much. I've posted patches in the past and actively
> > bringing up this topic at LSFMM last two years...
> 
> You're right - but you have chosen the uneasy path.

Yes.

> Fixing __vmalloc code 
> is easy and it doesn't require cooperation with maintainers.

But it is a hack against the intention of the scope api. It also alows
maintainers to not care about their broken code.

> > > He refuses 15-line patch to fix GFP_NOIO bug because he believes that in 4 
> > > years, the kernel will be refactored and GFP_NOIO will be eliminated. Why 
> > > does he have veto over this part of the code? I'd much rather argue with 
> > > people who have constructive comments about fixing bugs than with him.
> > 
> > I didn't NACK the patch AFAIR. I've said it is not a good idea longterm.
> > I would be much more willing to change my mind if you would back your
> > patch by a real bug report. Hacks are acceptable when we have a real
> > issue in hands. But if we want to fix potential issue then better make
> > it properly.
> 
> Developers should fix bugs in advance, not to wait until a crash hapens, 
> is analyzed and reported.

I agree. But are those existing users broken in the first place? I have
seen so many GFP_NOFS abuses that I would dare to guess that most of
those vmalloc NOFS abusers can be simply turned into GFP_KERNEL. Maybe
that is the reason we haven't heard any complains in years.

-- 
Michal Hocko
SUSE Labs
