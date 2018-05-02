Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9F886B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 09:33:03 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id b38so13195291uad.23
        for <linux-mm@kvack.org>; Wed, 02 May 2018 06:33:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r41si1881074uai.59.2018.05.02.06.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 06:33:02 -0700 (PDT)
Date: Wed, 2 May 2018 09:33:01 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180502133224.GA22123@redhat.com>
References: <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424133146.GG17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424161242.GK17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241229410.23702@file01.intranet.prod.int.rdu2.redhat.com>
 <20180501173626.4593a87d0d64f6cc9d219d20@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180501173626.4593a87d0d64f6cc9d219d20@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Babka <vbabka@suse.cz>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>

On Tue, May 01 2018 at  8:36pm -0400,
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 24 Apr 2018 12:33:01 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > 
> > 
> > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > 
> > > On Tue 24-04-18 11:30:40, Mikulas Patocka wrote:
> > > > 
> > > > 
> > > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > > 
> > > > > On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> > > > > 
> > > > > > Fixing __vmalloc code 
> > > > > > is easy and it doesn't require cooperation with maintainers.
> > > > > 
> > > > > But it is a hack against the intention of the scope api.
> > > > 
> > > > It is not!
> > > 
> > > This discussion simply doesn't make much sense it seems. The scope API
> > > is to document the scope of the reclaim recursion critical section. That
> > > certainly is not a utility function like vmalloc.
> > 
> > That 15-line __vmalloc bugfix doesn't prevent you (or any other kernel 
> > developer) from converting the code to the scope API. You make nonsensical 
> > excuses.
> > 
> 
> Fun thread!
> 
> Winding back to the original problem, I'd state it as
> 
> - Caller uses kvmalloc() but passes the address into vmalloc-naive
>   DMA API and
> 
> - Caller uses kvmalloc() but passes the address into kfree()
> 
> Yes?

I think so.

> If so, then...
> 
> Is there a way in which, in the kvmalloc-called-kmalloc path, we can
> tag the slab-allocated memory with a "this memory was allocated with
> kvmalloc()" flag?  I *think* there's extra per-object storage available
> with suitable slab/slub debugging options?  Perhaps we could steal one
> bit from the redzone, dunno.
> 
> If so then we can
> 
> a) set that flag in kvmalloc() if the kmalloc() call succeeded
> 
> b) check for that flag in the DMA code, WARN if it is set.
> 
> c) in kvfree(), clear that flag before calling kfree()
> 
> d) in kfree(), check for that flag and go WARN() if set.
> 
> So both potential bugs are detected all the time, dependent upon
> CONFIG_SLUB_DEBUG (and perhaps other slub config options).

Thanks Andrew, definitely the most sane proposal I've seen to resolve
this.
