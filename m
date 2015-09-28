Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 14D096B025B
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:30:02 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so59737922igb.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 09:30:01 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id gb2si12411492igd.93.2015.09.28.09.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 28 Sep 2015 09:30:01 -0700 (PDT)
Date: Mon, 28 Sep 2015 11:30:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
In-Reply-To: <20150928175114.07e85114@redhat.com>
Message-ID: <alpine.DEB.2.20.1509281129100.30876@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122629.15409.69466.stgit@canyon> <alpine.DEB.2.20.1509281011250.30332@east.gentwo.org> <20150928175114.07e85114@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> Not knowing SLUB as well as you, it took me several hours to realize
> init_object() didn't overwrite the freepointer in the object.  Thus, I
> think these comments make the reader aware of not-so-obvious
> side-effects of SLAB_POISON and SLAB_RED_ZONE.

>From the source:

/*
 * Object layout:
 *
 * object address
 *      Bytes of the object to be managed.
 *      If the freepointer may overlay the object then the free
 *      pointer is the first word of the object.
 *
 *      Poisoning uses 0x6b (POISON_FREE) and the last byte is
 *      0xa5 (POISON_END)
 *
 * object + s->object_size
 *      Padding to reach word boundary. This is also used for Redzoning.
 *      Padding is extended by another word if Redzoning is enabled and
 *      object_size == inuse.
 *
 *      We fill with 0xbb (RED_INACTIVE) for inactive objects and with
 *      0xcc (RED_ACTIVE) for objects in use.
 *
 * object + s->inuse
 *      Meta data starts here.
 *
 *      A. Free pointer (if we cannot overwrite object on free)
 *      B. Tracking data for SLAB_STORE_USER
 *      C. Padding to reach required alignment boundary or at mininum
 *              one word if debugging is on to be able to detect writes
 *              before the word boundary.
 *
 *      Padding is done using 0x5a (POISON_INUSE)
 *
 * object + s->size
 *      Nothing is used beyond s->size.
 *
 * If slabcaches are merged then the object_size and inuse boundaries are
mostly
 * ignored. And therefore no slab options that rely on these boundaries
 * may be used with merged slabcaches.
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
