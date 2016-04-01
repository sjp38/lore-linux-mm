Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 35C7C6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:16:03 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id e128so61632912pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:16:03 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n3si17787268pfb.123.2016.03.31.19.16.01
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 19:16:02 -0700 (PDT)
Date: Fri, 1 Apr 2016 11:18:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/11] mm/slab: hold a slab_mutex when calling
 __kmem_cache_shrink()
Message-ID: <20160401021806.GA13179@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
 <56FD019A.10906@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FD019A.10906@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 31, 2016 at 01:53:14PM +0300, Nikolay Borisov wrote:
> 
> 
> On 03/28/2016 08:26 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Major kmem_cache metadata in slab subsystem is synchronized with
> > the slab_mutex. In SLAB, if some of them is changed, node's shared
> > array cache would be freed and re-populated. If __kmem_cache_shrink()
> > is called at the same time, it will call drain_array() with n->shared
> > without holding node lock so problem can happen.
> > 
> > We can fix this small theoretical race condition by holding node lock
> > in drain_array(), but, holding a slab_mutex in kmem_cache_shrink()
> > looks more appropriate solution because stable state would make things
> > less error-prone and this is not performance critical path.
> > 
> > In addtion, annotate on SLAB functions.
> 
> Just a nit but would it not be better instead of doing comment-style
> annotation to use lockdep_assert_held/_once. In both cases for someone
> to understand what locks have to be held will go and read the source. In
> my mind it's easier to miss a comment line, rather than the
> lockdep_assert. Furthermore in case lockdep is enabled a locking
> violation would spew useful info to dmesg.

Good idea. I'm not sure if lockdep_assert is best fit but I will add
something to check it rather than just adding the comment.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
