Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 592606B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 21:24:37 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so692748yho.30
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 18:24:37 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id i68si2985112yhq.145.2014.01.08.18.24.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 18:24:36 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so685231yhn.4
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 18:24:36 -0800 (PST)
Date: Wed, 8 Jan 2014 18:24:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: fix ALLOC_SLOWPATH stat
In-Reply-To: <20140106204300.DE79BA86@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1401081824170.15616@chino.kir.corp.google.com>
References: <20140106204300.DE79BA86@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, akpm@linux-foundation.org, penberg@kernel.org

On Mon, 6 Jan 2014, Dave Hansen wrote:

> There used to be only one path out of __slab_alloc(), and
> ALLOC_SLOWPATH got bumped in that exit path.  Now there are two,
> and a bunch of gotos.  ALLOC_SLOWPATH can now get set more than once
> during a single call to __slab_alloc() which is pretty bogus.
> Here's the sequence:
> 
> 1. Enter __slab_alloc(), fall through all the way to the
>    stat(s, ALLOC_SLOWPATH);
> 2. hit 'if (!freelist)', and bump DEACTIVATE_BYPASS, jump to
>    new_slab (goto #1)
> 3. Hit 'if (c->partial)', bump CPU_PARTIAL_ALLOC, goto redo
>    (goto #2)
> 4. Fall through in the same path we did before all the way to
>    stat(s, ALLOC_SLOWPATH)
> 5. bump ALLOC_REFILL stat, then return
> 
> Doing this is obviously bogus.  It keeps us from being able to
> accurately compare ALLOC_SLOWPATH vs. ALLOC_FASTPATH.  It also
> means that the total number of allocs always exceeds the total
> number of frees.
> 
> This patch moves stat(s, ALLOC_SLOWPATH) to be called from the
> same place that __slab_alloc() is.  This makes it much less
> likely that ALLOC_SLOWPATH will get botched again in the
> spaghetti-code inside __slab_alloc().
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
