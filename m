Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBE26B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:21:26 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id z8so38859480ige.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:21:26 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id g131si17842153iog.156.2016.02.26.08.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 08:21:25 -0800 (PST)
Date: Fri, 26 Feb 2016 10:21:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 16/17] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
In-Reply-To: <1456466484-3442-17-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1602261017050.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com> <1456466484-3442-17-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 26 Feb 2016, js1304@gmail.com wrote:

> Although this idea can apply to all caches whose size is larger than
> management array size, it isn't applied to caches which have a
> constructor.  If such cache's object is used for management array,
> constructor should be called for it before that object is returned to
> user.  I guess that overhead overwhelm benefit in that case so this idea
> doesn't applied to them at least now.

Caches which have a constructor (or are used with SLAB_RCU_FREE) have a
defined content even when they are free. Therefore they cannot be used
for the freelist.

> For summary, from now on, slab management type is determined by
> following logic.
>
> 1) if management array size is smaller than object size and no ctor, it
>    becomes OBJFREELIST_SLAB.

Also do not do this for RCU slabs.

> 2) if management array size is smaller than leftover, it becomes
>    NORMAL_SLAB which uses leftover as a array.
>
> 3) if OFF_SLAB help to save memory than way 4), it becomes OFF_SLAB.
>    It allocate a management array from the other cache so memory waste
>    happens.

Wonder how many of these ugly off slabs are left after what you did here.

> TOTAL = OBJFREELIST + NORMAL(leftover) + NORMAL + OFF
>
> /Before/
> 126 = 0 + 60 + 25 + 41
>
> /After/
> 126 = 97 + 12 + 15 + 2
>
> Result shows that number of caches that doesn't waste memory increase
> from 60 to 109.

Great results.

> v2: fix SLAB_DESTROTY_BY_RCU cache type handling

Ok how are they handled now? Do not see that dealt with in the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
