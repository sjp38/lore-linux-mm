Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF636B0085
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:14:55 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id a41so1295660yho.1
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:14:55 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id r4si7757105yhg.10.2014.01.21.14.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 14:14:54 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id i7so2308487yha.28
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:14:53 -0800 (PST)
Date: Tue, 21 Jan 2014 14:14:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: fix ALLOC_SLOWPATH stat
In-Reply-To: <alpine.DEB.2.02.1401081824170.15616@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1401211413440.1666@chino.kir.corp.google.com>
References: <20140106204300.DE79BA86@viggo.jf.intel.com> <alpine.DEB.2.02.1401081824170.15616@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Wed, 8 Jan 2014, David Rientjes wrote:

> > There used to be only one path out of __slab_alloc(), and
> > ALLOC_SLOWPATH got bumped in that exit path.  Now there are two,
> > and a bunch of gotos.  ALLOC_SLOWPATH can now get set more than once
> > during a single call to __slab_alloc() which is pretty bogus.
> > Here's the sequence:
> > 
> > 1. Enter __slab_alloc(), fall through all the way to the
> >    stat(s, ALLOC_SLOWPATH);
> > 2. hit 'if (!freelist)', and bump DEACTIVATE_BYPASS, jump to
> >    new_slab (goto #1)
> > 3. Hit 'if (c->partial)', bump CPU_PARTIAL_ALLOC, goto redo
> >    (goto #2)
> > 4. Fall through in the same path we did before all the way to
> >    stat(s, ALLOC_SLOWPATH)
> > 5. bump ALLOC_REFILL stat, then return
> > 
> > Doing this is obviously bogus.  It keeps us from being able to
> > accurately compare ALLOC_SLOWPATH vs. ALLOC_FASTPATH.  It also
> > means that the total number of allocs always exceeds the total
> > number of frees.
> > 
> > This patch moves stat(s, ALLOC_SLOWPATH) to be called from the
> > same place that __slab_alloc() is.  This makes it much less
> > likely that ALLOC_SLOWPATH will get botched again in the
> > spaghetti-code inside __slab_alloc().
> > 
> > Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 

Pekka, are you going to pick this up for linux-next?  I think it would be 
nice to have for 3.14 for those of us who use the stats.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
