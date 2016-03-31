Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 11D496B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 06:53:19 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id r72so135637201wmg.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 03:53:19 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id wg3si11096267wjb.162.2016.03.31.03.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 03:53:17 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id p65so109214469wmp.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 03:53:17 -0700 (PDT)
Subject: Re: [PATCH 01/11] mm/slab: hold a slab_mutex when calling
 __kmem_cache_shrink()
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56FD019A.10906@kyup.com>
Date: Thu, 31 Mar 2016 13:53:14 +0300
MIME-Version: 1.0
In-Reply-To: <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 03/28/2016 08:26 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Major kmem_cache metadata in slab subsystem is synchronized with
> the slab_mutex. In SLAB, if some of them is changed, node's shared
> array cache would be freed and re-populated. If __kmem_cache_shrink()
> is called at the same time, it will call drain_array() with n->shared
> without holding node lock so problem can happen.
> 
> We can fix this small theoretical race condition by holding node lock
> in drain_array(), but, holding a slab_mutex in kmem_cache_shrink()
> looks more appropriate solution because stable state would make things
> less error-prone and this is not performance critical path.
> 
> In addtion, annotate on SLAB functions.

Just a nit but would it not be better instead of doing comment-style
annotation to use lockdep_assert_held/_once. In both cases for someone
to understand what locks have to be held will go and read the source. In
my mind it's easier to miss a comment line, rather than the
lockdep_assert. Furthermore in case lockdep is enabled a locking
violation would spew useful info to dmesg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
