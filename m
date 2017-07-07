Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A84EB6B0292
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 19:18:35 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z74so5424395ioz.3
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 16:18:35 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id v2si668969itg.53.2017.07.07.16.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 16:18:34 -0700 (PDT)
Date: Fri, 7 Jul 2017 18:18:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
In-Reply-To: <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
References: <20170707083408.40410-1-glider@google.com> <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 7 Jul 2017, Andrew Morton wrote:

> On Fri,  7 Jul 2017 10:34:08 +0200 Alexander Potapenko <glider@google.com> wrote:
>
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
> >  			return 0;
> >  		}
> >
> > -		s->node[node] = n;
> >  		init_kmem_cache_node(n);
> > +		s->node[node] = n;
> >  	}
> >  	return 1;
> >  }
>
> If this matters then I have bad feelings about free_kmem_cache_nodes():

At creation time the kmem_cache structure is private and no one can run a
free operation.

> Inviting a use-after-free?  I guess not, as there should be no way
> to look up these items at this stage.

Right.

> Could the slab maintainers please take a look at these and also have a
> think about Alexander's READ_ONCE/WRITE_ONCE question?

Was I cced on these?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
