Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6F0DC6B005D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2D66082C3BA
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:15:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AFobp7d-d0u1 for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 10:15:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 746AD82C3C2
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:15:21 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:59:00 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
In-Reply-To: <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0906180957030.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org>  <20090617203445.302169275@gentwo.org> <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-716562517-732232848-1245333540=:15556"
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---716562517-732232848-1245333540=:15556
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 18 Jun 2009, Pekka Enberg wrote:

> Hi Christoph,
>
> On Wed, Jun 17, 2009 at 11:33 PM, <cl@linux-foundation.org> wrote:
> > @@ -1604,9 +1595,6 @@ static void *__slab_alloc(struct kmem_ca
> > =A0 =A0 =A0 =A0void **object;
> > =A0 =A0 =A0 =A0struct page *new;
> >
> > - =A0 =A0 =A0 /* We handle __GFP_ZERO in the caller */
> > - =A0 =A0 =A0 gfpflags &=3D ~__GFP_ZERO;
> > -
>
> This should probably not be here.

Yes how did this get in there? Useless code somehow leaked in.

> > A particular problem for the dynamic dma kmalloc slab creation is that =
the
> > new percpu allocator cannot be called from an atomic context. The solut=
ion
> > adopted here for the atomic context is to track spare elements in the p=
er
> > cpu kmem_cache array for non dma kmallocs. Use them if necessary for dm=
a
> > cache creation from an atomic context. Otherwise we just fail the alloc=
ation.
>
> OK, I am confused. Isn't the whole point in separating DMA caches that
> we don't mix regular and DMA allocations in the same slab and using up
> precious DMA memory on some archs?

DMA caches exist to allocate memory in a range that can be reached by
legacy devices. F.e. some SCSI controllers can only dma below 16MB.

> So I don't think the above hunk is a good solution to this at all. We
> certainly can remove the lazy DMA slab creation (why did we add it in
> the first place?) but how hard is it to fix the per-cpu allocator to
> work in atomic contexts?

Lazy DMA creation was added to avoid having to duplicate the kmalloc array
for a few rare uses of DMA caches.

---716562517-732232848-1245333540=:15556--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
