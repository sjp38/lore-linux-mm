Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9541B6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:54:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so21865825pgg.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:54:44 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id w130si13209994pfd.79.2017.01.17.14.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 14:54:43 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id t6so22795131pgt.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:54:43 -0800 (PST)
Date: Tue, 17 Jan 2017 14:54:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: add a check for the first kmem_cache not to be
 destroyed
In-Reply-To: <764E463A-F743-4BE6-8BFC-07D50FF57DDA@toanyone.net>
Message-ID: <alpine.DEB.2.10.1701171452580.142998@chino.kir.corp.google.com>
References: <20170116070459.43540-1-kwon@toanyone.net> <20170117013300.GA25940@js1304-P5Q-DELUXE> <764E463A-F743-4BE6-8BFC-07D50FF57DDA@toanyone.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kwon <kwon@toanyone.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 Jan 2017, kwon wrote:

> >> diff --git a/mm/slab_common.c b/mm/slab_common.c
> >> index 1dfc209..2d30ace 100644
> >> --- a/mm/slab_common.c
> >> +++ b/mm/slab_common.c
> >> @@ -744,7 +744,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
> >> 	bool need_rcu_barrier = false;
> >> 	int err;
> >> 
> >> -	if (unlikely(!s))
> >> +	if (unlikely(!s) || s->refcount == -1)
> >> 		return;
> > 
> > Hello, Kyunghwan.
> > 
> > Few lines below, s->refcount is checked.
> > 
> > if (s->refcount)
> >        goto unlock;
> > 
> > Am I missing something?
> > 
> > Thanks.
> 
> Hello, Joonsoo.
> 
> In case it is called the number of int size times. refcount would finally reach
> to 0 since decreased every time the function called.
> 

The only thing using create_boot_cache() should be the slab implementation 
itself, so I don't think we need to protect ourselves from doing something 
like kmem_cache_destroy(kmem_cache) or 
kmem_cache_destroy(kmem_cache_node) even a single time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
