Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 61FFA6B00AE
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:01:41 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so3244360pab.27
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:01:41 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:01:38 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] slab: restrict the number of objects in a slab
In-Reply-To: <1381989797-29269-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7cb668b-1e2528ea-ce87-4380-a0dd-e5be9384cd84-000000@email.amazonses.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com> <1381989797-29269-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

n Thu, 17 Oct 2013, Joonsoo Kim wrote:

> To prepare to implement byte sized index for managing the freelist
> of a slab, we should restrict the number of objects in a slab to be less
> or equal to 256, since byte only represent 256 different values.
> Setting the size of object to value equal or more than newly introduced
> SLAB_MIN_SIZE ensures that the number of objects in a slab is less or
> equal to 256 for a slab with 1 page.

Ok so that results in a mininum size object size of 2^(12 - 8) = 2^4 ==
16 bytes on x86. This is not true for order 1 pages (which SLAB also
supports) where we need 32 bytes.

Problems may arise on PPC or IA64 where the page size may be larger than
64K. With 64K we have a mininum size of 2^(16 - 8) = 256 bytes. For those
arches we may need 16 bit sized indexes. Maybe make that compile time
determined base on page size? > 64KByte results in 16 bit sized indexes?

Otherwise I like this approach. Simplifies a lot and its very cache
friendly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
