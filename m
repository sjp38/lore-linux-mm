Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA716B00BD
	for <linux-mm@kvack.org>; Wed,  7 May 2014 23:05:13 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so2066100pad.23
        for <linux-mm@kvack.org>; Wed, 07 May 2014 20:05:13 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id ov9si2844166pbc.342.2014.05.07.20.05.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 20:05:12 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so1870362pde.27
        for <linux-mm@kvack.org>; Wed, 07 May 2014 20:05:12 -0700 (PDT)
Date: Wed, 7 May 2014 20:05:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: fix ALLOC_SLOWPATH stat
In-Reply-To: <alpine.DEB.2.02.1401211413440.1666@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405072004390.12567@chino.kir.corp.google.com>
References: <20140106204300.DE79BA86@viggo.jf.intel.com> <alpine.DEB.2.02.1401081824170.15616@chino.kir.corp.google.com> <alpine.DEB.2.02.1401211413440.1666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>

On Tue, 21 Jan 2014, David Rientjes wrote:

> On Wed, 8 Jan 2014, David Rientjes wrote:
> 
> > > There used to be only one path out of __slab_alloc(), and
> > > ALLOC_SLOWPATH got bumped in that exit path.  Now there are two,
> > > and a bunch of gotos.  ALLOC_SLOWPATH can now get set more than once
> > > during a single call to __slab_alloc() which is pretty bogus.
> > > Here's the sequence:
> > > 
> > > 1. Enter __slab_alloc(), fall through all the way to the
> > >    stat(s, ALLOC_SLOWPATH);
> > > 2. hit 'if (!freelist)', and bump DEACTIVATE_BYPASS, jump to
> > >    new_slab (goto #1)
> > > 3. Hit 'if (c->partial)', bump CPU_PARTIAL_ALLOC, goto redo
> > >    (goto #2)
> > > 4. Fall through in the same path we did before all the way to
> > >    stat(s, ALLOC_SLOWPATH)
> > > 5. bump ALLOC_REFILL stat, then return
> > > 
> > > Doing this is obviously bogus.  It keeps us from being able to
> > > accurately compare ALLOC_SLOWPATH vs. ALLOC_FASTPATH.  It also
> > > means that the total number of allocs always exceeds the total
> > > number of frees.
> > > 
> > > This patch moves stat(s, ALLOC_SLOWPATH) to be called from the
> > > same place that __slab_alloc() is.  This makes it much less
> > > likely that ALLOC_SLOWPATH will get botched again in the
> > > spaghetti-code inside __slab_alloc().
> > > 
> > > Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> 
> Pekka, are you going to pick this up for linux-next?  I think it would be 
> nice to have for 3.14 for those of us who use the stats.
> 

Ping #2.  Pekka or Andrew, would you pick this up for linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
