Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 534786B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 22:19:08 -0400 (EDT)
Received: by ignm3 with SMTP id m3so24517137ign.0
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 19:19:08 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id da20si3560820icb.39.2015.04.10.19.19.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Apr 2015 19:19:07 -0700 (PDT)
Date: Fri, 10 Apr 2015 21:19:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub bulk alloc: Extract objects from the per cpu slab
In-Reply-To: <20150409131916.51a533219dbff7a6f2294034@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1504102115320.1179@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org> <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org> <alpine.DEB.2.11.1504090859560.19278@gentwo.org> <20150409131916.51a533219dbff7a6f2294034@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: brouer@redhat.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 9 Apr 2015, Andrew Morton wrote:

> > This is going to increase as we add more capabilities. I have a second
> > patch here that extends the fast allocation to the per cpu partial pages.
>
> Yes, but what is the expected success rate of the initial bulk
> allocation attempt?  If it's 1% then perhaps there's no point in doing
> it.

After we have extracted object from all structures aorund we can also go
directly to the page allocator if we wanted and bypass lots of the
processing for metadata. So we will ultimately end up with 100% success
rate.

> > > This kmem_cache_cpu.tid logic is a bit opaque.  The low-level
> > > operations seem reasonably well documented but I couldn't find anywhere
> > > which tells me how it all actually works - what is "disambiguation
> > > during cmpxchg" and how do we achieve it?
> >
> > This is used to force a retry in slab_alloc_node() if preemption occurs
> > there. We are modifying the per cpu state thus a retry must be forced.
>
> No, I'm not referring to this patch.  I'm referring to the overall
> design concept behind kmem_cache_cpu.tid.  This patch made me go and
> look, and it's a bit of a head-scratcher.  It's unobvious and doesn't
> appear to be documented in any central place.  Perhaps it's in a
> changelog, but who has time for that?

The tid logic is documented somewhat in mm/slub.c. Line 1749 and
following.

> Keeping them in -next is not a problem - I was wondering about when to
> start moving the code into mainline.

When Mr. Brouer has confirmed that the stuff actually does some good for
his issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
