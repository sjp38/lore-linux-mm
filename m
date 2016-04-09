Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id EB4666B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 05:11:39 -0400 (EDT)
Received: by mail-qk0-f180.google.com with SMTP id r184so53183459qkc.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 02:11:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si4510275qkj.18.2016.04.09.02.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 02:11:39 -0700 (PDT)
Date: Sat, 9 Apr 2016 11:11:32 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160409111132.781a11b6@redhat.com>
In-Reply-To: <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com

Hi Eric,

On Thu, 07 Apr 2016 08:18:29 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-04-07 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> > (Topic proposal for MM-summit)
> >=20
> > Network Interface Cards (NIC) drivers, and increasing speeds stress
> > the page-allocator (and DMA APIs).  A number of driver specific
> > open-coded approaches exists that work-around these bottlenecks in the
> > page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> > allocating larger pages and handing-out page "fragments".
> >=20
> > I'm proposing a generic page-pool recycle facility, that can cover the
> > driver use-cases, increase performance and open up for zero-copy RX.
> >=20
> >=20
> > The basic performance problem is that pages (containing packets at RX)
> > are cycled through the page allocator (freed at TX DMA completion
> > time).  While a system in a steady state, could avoid calling the page
> > allocator, when having a pool of pages equal to the size of the RX
> > ring plus the number of outstanding frames in the TX ring (waiting for
> > DMA completion). =20
>=20
>=20
> We certainly used this at Google for quite a while.
>=20
> The thing is : in steady state, the number of pages being 'in tx queues'
> is lower than number of pages that were allocated for RX queues.

That was also my expectation, thanks for confirming my expectation.

> The page allocator is hardly hit, once you have big enough RX ring
> buffers. (Nothing fancy, simply the default number of slots)
>=20
> The 'hard coded=C2=B4 code is quite small actually
>=20
> if (page_count(page) !=3D 1) {
>     free the page and allocate another one,=20
>     since we are not the exclusive owner.
>     Prefer __GFP_COLD pages btw.
> }
> page_ref_inc(page);

Above code is okay.  But do you think we also can get away with the same
trick we do with the SKB refcnf?  Where we avoid an atomic operation if
refcnt=3D=3D1.

void kfree_skb(struct sk_buff *skb)
{
	if (unlikely(!skb))
		return;
	if (likely(atomic_read(&skb->users) =3D=3D 1))
		smp_rmb();
	else if (likely(!atomic_dec_and_test(&skb->users)))
		return;
	trace_kfree_skb(skb, __builtin_return_address(0));
	__kfree_skb(skb);
}
EXPORT_SYMBOL(kfree_skb);


--=20
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
