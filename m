Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCC106B04BC
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:32:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so27001791wrf.5
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:32:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j19si7582081wmi.49.2017.07.10.13.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 13:32:40 -0700 (PDT)
Date: Mon, 10 Jul 2017 13:32:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
Message-Id: <20170710133238.2afcda57ea28e020ca03c4f0@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
References: <20170707083408.40410-1-glider@google.com>
	<20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
	<alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 7 Jul 2017 18:18:31 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Fri, 7 Jul 2017, Andrew Morton wrote:
> 
> > On Fri,  7 Jul 2017 10:34:08 +0200 Alexander Potapenko <glider@google.com> wrote:
> >
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
> > >  			return 0;
> > >  		}
> > >
> > > -		s->node[node] = n;
> > >  		init_kmem_cache_node(n);
> > > +		s->node[node] = n;
> > >  	}
> > >  	return 1;
> > >  }
> >
> > If this matters then I have bad feelings about free_kmem_cache_nodes():
> 
> At creation time the kmem_cache structure is private and no one can run a
> free operation.
> 
> > Inviting a use-after-free?  I guess not, as there should be no way
> > to look up these items at this stage.
> 
> Right.

Still.   It looks bad, and other sites do these things in the other order.

> > Could the slab maintainers please take a look at these and also have a
> > think about Alexander's READ_ONCE/WRITE_ONCE question?
> 
> Was I cced on these?

It's all on linux-mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
