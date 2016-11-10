Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A78C6B0271
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:38:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so97829311pfb.6
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:38:10 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id j6si1816299pfa.297.2016.11.09.16.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 16:38:09 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id n85so135223715pfi.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:38:09 -0800 (PST)
Date: Wed, 9 Nov 2016 16:38:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, slab: faster active and free stats
In-Reply-To: <20161108151727.b64035da825c69bced88b46d@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com> <20161108151727.b64035da825c69bced88b46d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 8 Nov 2016, Andrew Morton wrote:

> > Reading /proc/slabinfo or monitoring slabtop(1) can become very expensive
> > if there are many slab caches and if there are very lengthy per-node
> > partial and/or free lists.
> > 
> > Commit 07a63c41fa1f ("mm/slab: improve performance of gathering slabinfo
> > stats") addressed the per-node full lists which showed a significant
> > improvement when no objects were freed.  This patch has the same
> > motivation and optimizes the remainder of the usecases where there are
> > very lengthy partial and free lists.
> > 
> > This patch maintains per-node active_slabs (full and partial) and
> > free_slabs rather than iterating the lists at runtime when reading
> > /proc/slabinfo.
> 
> Are there any nice numbers you can share?
> 

Yes, please add this to the description:


When allocating 100GB of slab from a test cache where every slab page is
on the partial list, reading /proc/slabinfo (includes all other slab
caches on the system) takes ~247ms on average with 48 samples.

As a result of this patch, the same read takes ~0.856ms on average.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
