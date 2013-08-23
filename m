Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 2C18B6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 11:41:33 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:41:31 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/16] slab: remove cachep in struct slab_rcu
In-Reply-To: <CAAmzW4NZHXXX08tdQitwapfi8raQ-BTRry92A0jdFQkm0vaqxw@mail.gmail.com>
Message-ID: <00000140abd66e64-21601d31-3ba2-42bd-8153-9f1d41fcc0d9-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com> <00000140a72870a6-f7c87696-ecbc-432c-9f41-93f414c0c623-000000@email.amazonses.com> <20130823065315.GG22605@lge.com>
 <00000140ab69e6be-3b2999b6-93b4-4b22-a91f-8929aee5238f-000000@email.amazonses.com> <CAAmzW4NZHXXX08tdQitwapfi8raQ-BTRry92A0jdFQkm0vaqxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 23 Aug 2013, JoonSoo Kim wrote:

> I don't get it. This patch only affect to the rcu case, because it
> change the code
> which is in kmem_rcu_free(). It doesn't touch anything in standard case.

In general this patchset moves struct slab to overlay struct page. The
design of SLAB was (at least at some point in the past) to avoid struct
page references. The freelist was kept close to struct slab so that the
contents are in the same cache line. Moving fields to struct page will add
another cacheline to be referenced.

The freelist (bufctl_t) was dimensioned in such a way as to be small
and close cache wise to struct slab. Somewhow bufctl_t grew to
unsigned int and therefore the table became a bit large. Fundamentally
these are indexes into the objects in page. They really could be sized
again to just be single bytes as also explained in the comments in slab.c:

/*
 * kmem_bufctl_t:
 *
 * Bufctl's are used for linking objs within a slab
 * linked offsets.
 *
 * This implementation relies on "struct page" for locating the cache &
 * slab an object belongs to.
 * This allows the bufctl structure to be small (one int), but limits
 * the number of objects a slab (not a cache) can contain when off-slab
 * bufctls are used. The limit is the size of the largest general cache
 * that does not use off-slab slabs.
 * For 32bit archs with 4 kB pages, is this 56.
 * This is not serious, as it is only for large objects, when it is unwise
 * to have too many per slab.
 * Note: This limit can be raised by introducing a general cache whose size
 * is less than 512 (PAGE_SIZE<<3), but greater than 256.
 */

For 56 objects the bufctl_t could really be reduced to an 8 bit integer
which would shrink the size of the table significantly and improve speed
by reducing cache footprint.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
