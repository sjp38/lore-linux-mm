Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F379C6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:16:04 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so54806830pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 22:16:04 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id sf2si17754692pbc.162.2015.11.11.22.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 22:16:04 -0800 (PST)
Received: by pasz6 with SMTP id z6so56778936pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 22:16:03 -0800 (PST)
Date: Thu, 12 Nov 2015 15:17:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members'
 types
Message-ID: <20151112061701.GA498@swordfish>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1511111251030.4742@chino.kir.corp.google.com>
 <20151112011347.GC1651@swordfish>
 <alpine.DEB.2.10.1511112105200.9296@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511112105200.9296@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/11/15 21:07), David Rientjes wrote:
[..]
> > > >  	/* Object size */
> > > > -	unsigned long long min_objsize = max, max_objsize = 0, avg_objsize;
> > > > +	unsigned int min_objsize = UINT_MAX, max_objsize = 0, avg_objsize;
> > > >  
> > > >  	/* Number of partial slabs in a slabcache */
> > > >  	unsigned long long min_partial = max, max_partial = 0,
> > > 
> > > avg_objsize should not be unsigned int.
> > 
> > Hm. the assumption is that `avg_objsize' cannot be larger
> > than `max_objsize', which is
> > 	`int object_size;' in `struct kmem_cache' from slab_def.h
> > and
> > 	`unsigned int object_size;' in `struct kmem_cache' from slab.h.
> > 
> > 
> >  avg_objsize = total_used / total_objects;
> > 
> 

I'm not sure I clearly understand the problems you're pointing
me to.

> This has nothing to do with object_size in the kernel.

what we have in slabinfo as slab_size(), ->object_size, etc.
comming from slub's sysfs attrs:

	chdir("/sys/kernel/slab")
	while readdir
		...
		slab->object_size = get_obj("object_size");
		slab->slab_size = get_obj("slab_size");
		...

and attr show handlers are:

...
 static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", s->size);
 }
 SLAB_ATTR_RO(slab_size);

 static ssize_t object_size_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", s->object_size);
 }
 SLAB_ATTR_RO(object_size);
...

so those are sprintf("%d") of `struct kmem_cache'-s `int'
values.


> total_used and total_objects are unsigned long long.

yes, that's correct.
but `total_used / total_objects' cannot be larger that the size
of the largest object, which is represented in the kernel and
returned to user space as `int'. it must fit into `unsigned int'.


> If you need to convert max_objsize to be unsigned long long as
> well, that would be better.

... in case if someday `struct kmem_cache' will be updated to keep
`unsigned long' sized objects and sysfs attrs will do sprintf("%lu")?
IOW, if slabs will keep objects bigger that 4gig?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
