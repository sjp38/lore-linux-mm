Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F01A6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:12:26 -0400 (EDT)
Received: by qgev79 with SMTP id v79so140974838qge.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 00:12:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si19740840qhx.90.2015.09.29.00.12.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 00:12:25 -0700 (PDT)
Date: Tue, 29 Sep 2015 09:12:19 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Message-ID: <20150929091219.40d1e217@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1509281129100.30876@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon>
	<20150928122629.15409.69466.stgit@canyon>
	<alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
	<20150928175114.07e85114@redhat.com>
	<alpine.DEB.2.20.1509281129100.30876@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com


On Mon, 28 Sep 2015 11:30:00 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > Not knowing SLUB as well as you, it took me several hours to realize
> > init_object() didn't overwrite the freepointer in the object.  Thus, I
> > think these comments make the reader aware of not-so-obvious
> > side-effects of SLAB_POISON and SLAB_RED_ZONE.
> 
> From the source:
> 
> /*
>  * Object layout:
>  *
>  * object address
>  *      Bytes of the object to be managed.
>  *      If the freepointer may overlay the object then the free
>  *      pointer is the first word of the object.
>  *
>  *      Poisoning uses 0x6b (POISON_FREE) and the last byte is
>  *      0xa5 (POISON_END)
>  *
>  * object + s->object_size
>  *      Padding to reach word boundary. This is also used for Redzoning.
>  *      Padding is extended by another word if Redzoning is enabled and
>  *      object_size == inuse.
>  *
>  *      We fill with 0xbb (RED_INACTIVE) for inactive objects and with
>  *      0xcc (RED_ACTIVE) for objects in use.
>  *
>  * object + s->inuse
>  *      Meta data starts here.
>  *
>  *      A. Free pointer (if we cannot overwrite object on free)
>  *      B. Tracking data for SLAB_STORE_USER
>  *      C. Padding to reach required alignment boundary or at mininum
>  *              one word if debugging is on to be able to detect writes
>  *              before the word boundary.

Okay, I will remove the comment.

The best doc on SLUB and SLAB layout comes from your slides titled:
 "Slab allocators in the Linux Kernel: SLAB, SLOB, SLUB"

Lets gracefully add a link to the slides here:
 http://events.linuxfoundation.org/sites/events/files/slides/slaballocators.pdf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
