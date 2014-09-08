Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 33BEB6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 10:46:16 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id x13so2514251qcv.27
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 07:46:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l18si11363375qgd.78.2014.09.08.07.46.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Sep 2014 07:46:15 -0700 (PDT)
Date: Mon, 8 Sep 2014 10:46:03 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: implement kmalloc guard
In-Reply-To: <alpine.DEB.2.11.1409080932490.20388@gentwo.org>
Message-ID: <alpine.LRH.2.02.1409081041160.29432@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.11.1409080932490.20388@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com



On Mon, 8 Sep 2014, Christoph Lameter wrote:

> On Fri, 5 Sep 2014, Mikulas Patocka wrote:
> 
> > This patch adds a new option DEBUG_KMALLOC that makes it possible to
> > detect writes beyond the end of space allocated with kmalloc. Normally,
> > the kmalloc function rounds the size to the next power of two (there is
> > exception to this rule - sizes 96 and 192). Slab debugging detects only
> > writes beyond the end of the slab object, it is unable to detect writes
> > beyond the end of kmallocated size that fit into the slab object.
> >
> > The motivation for this patch was this: There was 6 year old bug in
> > dm-crypt (d49ec52ff6ddcda178fc2476a109cf1bd1fa19ed) where the driver would
> > write beyond the end of kmallocated space, but the bug went undetected
> > because the write would fit into the power-of-two-sized slab object. Only
> > recent changes to dm-crypt made the bug show up. There is similar problem
> > in the nx-crypto driver in the function nx_crypto_ctx_init - again,
> > because kmalloc rounds the size up to the next power of two, this bug went
> > undetected.
> 
> The problem with the kmalloc array for debugging is inded that it is
> only for powers of two for efficiency purposes. In the debug
> situation we may not have the need for that efficiency. Maybe simply
> creating kmalloc arrays for each size will do the trick?

I don't know what you mean. If someone allocates 10000 objects with sizes 
from 1 to 10000, you can't have 10000 slab caches - you can't have a slab 
cache for each used size. Also - you can't create a slab cache in 
interrupt context.

> > This patch works for slab, slub and slob subsystems. The end of slab block
> > can be found out with ksize (this patch renames it to __ksize). At the end
> > of the block, we put a structure kmalloc_guard. This structure contains a
> > magic number and a real size of the block - the exact size given to
> 
> We already have a redzone structure to check for writes over the end of
> the object. Lets use that.

So, change all three slab subsystems to use that.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
