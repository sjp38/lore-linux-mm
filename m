Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5D46B0254
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 13:10:57 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so125826379ioi.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:10:57 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id z6si3794516igz.2.2015.09.08.10.10.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 10:10:56 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:10:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mm] slab: implement bulking for SLAB allocator
In-Reply-To: <20150908175451.2ce83a0b@redhat.com>
Message-ID: <alpine.DEB.2.11.1509081209180.25526@east.gentwo.org>
References: <20150908142147.22804.37717.stgit@devil> <alpine.DEB.2.11.1509081020510.25292@east.gentwo.org> <20150908175451.2ce83a0b@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Tue, 8 Sep 2015, Jesper Dangaard Brouer wrote:

> This test was a single CPU benchmark with no congestion or concurrency.
> But the code was compiled with CONFIG_NUMA=y.
>
> I don't know the slAb code very well, but the kmem_cache_node->list_lock
> looks like a scalability issue.  I guess that is what you are referring
> to ;-)

That lock can be mitigated like in SLUB by increasing per cpu resources.
The problem in SLAB is the categorization of objects on free as to which
node they came from and the use of arrays of pointers to avoid freeing the
object to the object tracking metadata structures in the slab page.

The arrays of pointers have to be replicated for each node, each slab and
each processor.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
