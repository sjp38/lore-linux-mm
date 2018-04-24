Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADEF06B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:16:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z6so9031256pgu.20
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:16:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p61-v6si10276273plb.472.2018.04.24.10.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 10:16:56 -0700 (PDT)
Date: Tue, 24 Apr 2018 10:16:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
Message-ID: <20180424171651.GC30577@bombadil.infradead.org>
References: <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424034643.GA26636@bombadil.infradead.org>
 <alpine.LRH.2.02.1804240818530.28016@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804240818530.28016@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, Apr 24, 2018 at 08:29:14AM -0400, Mikulas Patocka wrote:
> 
> 
> On Mon, 23 Apr 2018, Matthew Wilcox wrote:
> 
> > On Mon, Apr 23, 2018 at 08:06:16PM -0400, Mikulas Patocka wrote:
> > > Some bugs (such as buffer overflows) are better detected
> > > with kmalloc code, so we must test the kmalloc path too.
> > 
> > Well now, this brings up another item for the collective TODO list --
> > implement redzone checks for vmalloc.  Unless this is something already
> > taken care of by kasan or similar.
> 
> The kmalloc overflow testing is also not ideal - it rounds the size up to 
> the next slab size and detects buffer overflows only at this boundary.
> 
> Some times ago, I made a "kmalloc guard" patch that places a magic number 
> immediatelly after the requested size - so that it can detect overflows at 
> byte boundary 
> ( https://www.redhat.com/archives/dm-devel/2014-September/msg00018.html )
> 
> That patch found a bug in crypto code:
> ( http://lkml.iu.edu/hypermail/linux/kernel/1409.1/02325.html )

Is it still worth doing this, now we have kasan?
