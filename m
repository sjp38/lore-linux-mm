Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22930280284
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 00:51:23 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id kr7so10754116pab.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 21:51:23 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p75si8509731pfa.165.2016.11.10.21.51.21
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 21:51:22 -0800 (PST)
Date: Fri, 11 Nov 2016 14:53:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, slab: faster active and free stats
Message-ID: <20161111055326.GA16336@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com>
 <20161108151727.b64035da825c69bced88b46d@linux-foundation.org>
 <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 09, 2016 at 04:38:08PM -0800, David Rientjes wrote:
> On Tue, 8 Nov 2016, Andrew Morton wrote:
> 
> > > Reading /proc/slabinfo or monitoring slabtop(1) can become very expensive
> > > if there are many slab caches and if there are very lengthy per-node
> > > partial and/or free lists.
> > > 
> > > Commit 07a63c41fa1f ("mm/slab: improve performance of gathering slabinfo
> > > stats") addressed the per-node full lists which showed a significant
> > > improvement when no objects were freed.  This patch has the same
> > > motivation and optimizes the remainder of the usecases where there are
> > > very lengthy partial and free lists.
> > > 
> > > This patch maintains per-node active_slabs (full and partial) and
> > > free_slabs rather than iterating the lists at runtime when reading
> > > /proc/slabinfo.
> > 
> > Are there any nice numbers you can share?
> > 
> 
> Yes, please add this to the description:
> 
> 
> When allocating 100GB of slab from a test cache where every slab page is
> on the partial list, reading /proc/slabinfo (includes all other slab
> caches on the system) takes ~247ms on average with 48 samples.
> 
> As a result of this patch, the same read takes ~0.856ms on average.

Hello, David.

Maintaining acitve/free_slab counters looks so complex. And, I think
that we don't need to maintain these counters for faster slabinfo.
Key point is to remove iterating n->slabs_partial list.

We can calculate active slab/object by following equation as you did in
this patch.

active_slab(n) = n->num_slab - the number of free_slab
active_object(n) = n->num_slab * cachep->num - n->free_objects

To get the number of free_slab, we need to iterate n->slabs_free list
but I guess it would be small enough.

If you don't like to iterate n->slabs_free list in slabinfo, just
maintaining the number of slabs_free would be enough.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
