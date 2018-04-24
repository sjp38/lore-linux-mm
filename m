Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 441896B0028
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:29:22 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c4-v6so9978497qtp.9
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:29:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w131si76792qkw.40.2018.04.24.05.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 05:29:21 -0700 (PDT)
Date: Tue, 24 Apr 2018 08:29:14 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
In-Reply-To: <20180424034643.GA26636@bombadil.infradead.org>
Message-ID: <alpine.LRH.2.02.1804240818530.28016@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com> <20180424034643.GA26636@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On Mon, 23 Apr 2018, Matthew Wilcox wrote:

> On Mon, Apr 23, 2018 at 08:06:16PM -0400, Mikulas Patocka wrote:
> > Some bugs (such as buffer overflows) are better detected
> > with kmalloc code, so we must test the kmalloc path too.
> 
> Well now, this brings up another item for the collective TODO list --
> implement redzone checks for vmalloc.  Unless this is something already
> taken care of by kasan or similar.

The kmalloc overflow testing is also not ideal - it rounds the size up to 
the next slab size and detects buffer overflows only at this boundary.

Some times ago, I made a "kmalloc guard" patch that places a magic number 
immediatelly after the requested size - so that it can detect overflows at 
byte boundary 
( https://www.redhat.com/archives/dm-devel/2014-September/msg00018.html )

That patch found a bug in crypto code:
( http://lkml.iu.edu/hypermail/linux/kernel/1409.1/02325.html )

Mikulas
