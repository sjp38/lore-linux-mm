Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9906B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:50:20 -0400 (EDT)
Received: by qkdm188 with SMTP id m188so35612853qkd.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 09:50:20 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 145si8124212qhb.22.2015.06.15.09.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 09:50:19 -0700 (PDT)
Date: Mon, 15 Jun 2015 11:50:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/7] slab: infrastructure for bulk object allocation and
 freeing
In-Reply-To: <557F013F.5080104@gmail.com>
Message-ID: <alpine.DEB.2.11.1506151148160.20941@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155156.18824.35187.stgit@devil> <557F013F.5080104@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org

On Mon, 15 Jun 2015, Alexander Duyck wrote:

> So I can see the motivation behind bulk allocation, but I cannot see the
> motivation behind bulk freeing.  In the case of freeing the likelihood of the
> memory regions all belonging to the same page just isn't as high.

The likelyhood is high if the object are allocated in batch as well. In
that case SLUB ensures that all objects from the same page are first
allocated.

> I don't really see the reason why you should be populating arrays. SLUB uses a
> linked list and I don't see this implemented for SLOB or SLAB so maybe you
> should look at making this into a linked list. Also as I stated in the other
> comment maybe you should not do bulk allocation if you don't support it in
> SLAB/SLOB and instead change this so that you return a count indicating that
> only 1 value was allocated in this pass.

It is extremely easy to just take the linked list off a page or a per cpu
structure. Basically we would have constant cycle count for taking N
objects available in a slab page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
