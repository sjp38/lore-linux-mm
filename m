Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1958B6B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 20:36:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b25so11580968pfn.10
        for <linux-mm@kvack.org>; Tue, 01 May 2018 17:36:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o9-v6si10422425plk.434.2018.05.01.17.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 17:36:28 -0700 (PDT)
Date: Tue, 1 May 2018 17:36:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-Id: <20180501173626.4593a87d0d64f6cc9d219d20@linux-foundation.org>
In-Reply-To: <alpine.LRH.2.02.1804241229410.23702@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180420130852.GC16083@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
	<20180420210200.GH10788@bombadil.infradead.org>
	<alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
	<20180421144757.GC14610@bombadil.infradead.org>
	<alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180423151545.GU17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424133146.GG17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424161242.GK17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241229410.23702@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Tue, 24 Apr 2018 12:33:01 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Tue, 24 Apr 2018, Michal Hocko wrote:
> 
> > On Tue 24-04-18 11:30:40, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > 
> > > > On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> > > > 
> > > > > Fixing __vmalloc code 
> > > > > is easy and it doesn't require cooperation with maintainers.
> > > > 
> > > > But it is a hack against the intention of the scope api.
> > > 
> > > It is not!
> > 
> > This discussion simply doesn't make much sense it seems. The scope API
> > is to document the scope of the reclaim recursion critical section. That
> > certainly is not a utility function like vmalloc.
> 
> That 15-line __vmalloc bugfix doesn't prevent you (or any other kernel 
> developer) from converting the code to the scope API. You make nonsensical 
> excuses.
> 

Fun thread!

Winding back to the original problem, I'd state it as

- Caller uses kvmalloc() but passes the address into vmalloc-naive
  DMA API and

- Caller uses kvmalloc() but passes the address into kfree()

Yes?

If so, then...

Is there a way in which, in the kvmalloc-called-kmalloc path, we can
tag the slab-allocated memory with a "this memory was allocated with
kvmalloc()" flag?  I *think* there's extra per-object storage available
with suitable slab/slub debugging options?  Perhaps we could steal one
bit from the redzone, dunno.

If so then we can

a) set that flag in kvmalloc() if the kmalloc() call succeeded

b) check for that flag in the DMA code, WARN if it is set.

c) in kvfree(), clear that flag before calling kfree()

d) in kfree(), check for that flag and go WARN() if set.

So both potential bugs are detected all the time, dependent upon
CONFIG_SLUB_DEBUG (and perhaps other slub config options).
