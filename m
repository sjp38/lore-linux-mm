Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7985B6B00B4
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 18:02:26 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 19so2535392ykq.9
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 15:02:26 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net ([2001:558:fe21:29:250:56ff:feaf:29a])
        by mx.google.com with ESMTPS id x10si22994108qal.20.2015.02.18.15.02.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 15:02:24 -0800 (PST)
Date: Wed, 18 Feb 2015 17:02:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <20150218103245.3aa3ca87@redhat.com>
Message-ID: <alpine.DEB.2.11.1502181700100.20837@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org> <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <20150213023534.GA6592@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1502130941360.9442@gentwo.org> <20150217051541.GA15413@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1502170959130.4996@gentwo.org> <20150218103245.3aa3ca87@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Wed, 18 Feb 2015, Jesper Dangaard Brouer wrote:

> (My use-case is in area of 32-64 elems)

Ok that is in the realm of a couple of pages from the page allocator?

> > Its not that detailed. It is just layin out the basic strategy for the
> > array allocs. First go to the partial lists to decrease fragmentation.
> > Then bypass the allocator layers completely and go direct to the page
> > allocator if all objects that the page will accomodate can be put into
> > the array. Lastly use the cpu hot objects to fill in the leftover (which
> > would in any case be less than the objects in a page).
>
> IMHO this strategy is a bit off, from what I was looking for.
>
> I would prefer the first elements to be cache hot, and the later/rest of
> the elements can be more cache-cold. Reasoning behind this is,
> subsystem calling this alloc_array have likely ran out of elems (from
> it's local store/prev-call) and need to handout one elem immediately
> after this call returns.

The problem is that going for the cache hot objects involves dealing with
synchronization that you would not have to spend time on if going direct
to the page allocator or going to the partial lists and retrieving
multiple objects by taking a single lock.

Per cpu object (cache hot!) is already optimized to the hilt. There wont
be much of a benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
