Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id B7E3C4402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 17:50:47 -0400 (EDT)
Received: by qkas79 with SMTP id s79so48672845qka.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 14:50:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 79si12127977qgc.83.2015.10.02.14.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 14:50:46 -0700 (PDT)
Date: Fri, 2 Oct 2015 14:50:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-Id: <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
In-Reply-To: <20151002154039.69f82bdc@redhat.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Hannes Frederic Sowa <hannes@redhat.com>

On Fri, 2 Oct 2015 15:40:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > Thus, I need introducing new code like this patch and at the same time
> > have to reduce the number of instruction-cache misses/usage.  In this
> > case we solve the problem by kmem_cache_free_bulk() not getting called
> > too often. Thus, +17 bytes will hopefully not matter too much... but on
> > the other hand we sort-of know that calling kmem_cache_free_bulk() will
> > cause icache misses.
> 
> I just tested this change on top of my net-use-case patchset... and for
> some strange reason the code with this WARN_ON is faster and have much
> less icache-misses (1,278,276 vs 2,719,158 L1-icache-load-misses).
> 
> Thus, I think we should keep your fix.
> 
> I cannot explain why using WARN_ON() is better and cause less icache
> misses.  And I hate when I don't understand every detail.
> 
>  My theory is, after reading the assembler code, that the UD2
> instruction (from BUG_ON) cause some kind of icache decoder stall
> (Intel experts???).  Now that should not be a problem, as UD2 is
> obviously placed as an unlikely branch and left at the end of the asm
> function call.  But the call to __slab_free() is also placed at the end
> of the asm function (gets inlined from slab_free() as unlikely).  And
> it is actually fairly likely that bulking is calling __slab_free (slub
> slowpath call).

Yes, I was looking at the asm code and the difference is pretty small:
a not-taken ud2 versus a not-taken "call warn_slowpath_null", mainly.

But I wouldn't assume that the microbenchmarking is meaningful.  I've
seen shockingly large (and quite repeatable) microbenchmarking
differences from small changes in code which isn't even executed (and
this is one such case, actually).  You add or remove just one byte of
text and half the kernel (or half the .o file?) gets a different
alignment and this seems to change everything.

Deleting the BUG altogether sounds the best solution.  As long as the
kernel crashes in some manner, we'll be able to work out what happened.
And it's cant-happen anyway, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
