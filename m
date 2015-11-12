Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7477E6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:59:38 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so60546140pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:59:38 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ie7si75558pad.155.2015.11.12.01.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 01:59:37 -0800 (PST)
Received: by padhx2 with SMTP id hx2so60710107pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:59:37 -0800 (PST)
Date: Thu, 12 Nov 2015 01:59:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members'
 types
In-Reply-To: <20151112061701.GA498@swordfish>
Message-ID: <alpine.DEB.2.10.1511120144020.18610@chino.kir.corp.google.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com> <alpine.DEB.2.10.1511111251030.4742@chino.kir.corp.google.com> <20151112011347.GC1651@swordfish>
 <alpine.DEB.2.10.1511112105200.9296@chino.kir.corp.google.com> <20151112061701.GA498@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 Nov 2015, Sergey Senozhatsky wrote:

> > This has nothing to do with object_size in the kernel.
> 
> what we have in slabinfo as slab_size(), ->object_size, etc.
> comming from slub's sysfs attrs:
> 
> 	chdir("/sys/kernel/slab")
> 	while readdir
> 		...
> 		slab->object_size = get_obj("object_size");
> 		slab->slab_size = get_obj("slab_size");
> 		...
> 
> and attr show handlers are:
> 
> ...
>  static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
>  {
>  	return sprintf(buf, "%d\n", s->size);
>  }
>  SLAB_ATTR_RO(slab_size);
> 
>  static ssize_t object_size_show(struct kmem_cache *s, char *buf)
>  {
>  	return sprintf(buf, "%d\n", s->object_size);
>  }
>  SLAB_ATTR_RO(object_size);
> ...
> 
> so those are sprintf("%d") of `struct kmem_cache'-s `int'
> values.
> 
> 
> > total_used and total_objects are unsigned long long.
> 
> yes, that's correct.
> but `total_used / total_objects' cannot be larger that the size
> of the largest object, which is represented in the kernel and
> returned to user space as `int'. it must fit into `unsigned int'.
> 

Again, I am referring only to slabinfo as its own logical unit, it 
shouldn't be based on the implementation of any slab allocator in 
particular.  avg_objsize has nothing to do with your patch, which is 
advertised as fixing the mismatch in sign type of variables under 
comparison.

There seems to be an on-going issue in this patchset that you're not 
confronting: you are mixing extraneous changes into patches that are 
supposed to do one thing.  This already got you in trouble in the first 
patch where you just threw -O2 into the Makefile randomly, and without any 
mention in the commit description, and then you don't understand how to 
fix the warnings that it now presents in page-types.

The warnings being shown are a result of the particular _optimization_ 
that your gcc version has done and your subsequent patch is only 
addressing the ones that appear when you, yourself, compile.  Between 
different gcc versions, the optimization done by -O2 may be different and 
it will warn of more or less variables that may be clobbered as a result 
OF ITS OPTIMIZATION.  You miss entirely that _any_ variable modified after 
the setjmp() can be clobbered, most notably "off" which is the iterator 
of the very loop the setjmp() appears in!  Playing whack-a-mole in the 
warnings you get without understanding them is the issue here.

Please, very respectfully, do not include extraneous changes into 
patches, especially without mentioning them in the commit description, 
when the change isn't needed or understood.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
