Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7E66B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:59:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 37so3347486qkq.23
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:59:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y76si5700600qky.318.2017.03.29.01.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 01:59:37 -0700 (PDT)
Date: Wed, 29 Mar 2017 10:59:28 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi()
Message-ID: <20170329105928.609bc581@redhat.com>
In-Reply-To: <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
References: <20170323144347.1e6f29de@redhat.com>
	<20170323145133.twzt4f5ci26vdyut@techsingularity.net>
	<779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
	<1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
	<2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
	<20170327105514.1ed5b1ba@redhat.com>
	<20170327143947.4c237e54@redhat.com>
	<20170327141518.GB27285@bombadil.infradead.org>
	<20170327171500.4beef762@redhat.com>
	<20170327165817.GA28494@bombadil.infradead.org>
	<20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, brouer@redhat.com

On Wed, 29 Mar 2017 10:12:19 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Mar 27, 2017 at 09:58:17AM -0700, Matthew Wilcox wrote:
> > On Mon, Mar 27, 2017 at 05:15:00PM +0200, Jesper Dangaard Brouer wrote:=
 =20
> > > And I also verified it worked:
> > >=20
> > >   0.63 =E2=94=82       mov    __preempt_count,%eax
> > >        =E2=94=82     free_hot_cold_page():
> > >   1.25 =E2=94=82       test   $0x1f0000,%eax
> > >        =E2=94=82     =E2=86=93 jne    1e4
> > >=20
> > > And this simplification also made the compiler change this into a
> > > unlikely branch, which is a micro-optimization (that I will leave up =
to
> > > the compiler). =20
> >=20
> > Excellent!  That said, I think we should define in_irq_or_nmi() in
> > preempt.h, rather than hiding it in the memory allocator.  And since we=
're
> > doing that, we might as well make it look like the other definitions:
> >=20
> > diff --git a/include/linux/preempt.h b/include/linux/preempt.h
> > index 7eeceac52dea..af98c29abd9d 100644
> > --- a/include/linux/preempt.h
> > +++ b/include/linux/preempt.h
> > @@ -81,6 +81,7 @@
> >  #define in_interrupt()		(irq_count())
> >  #define in_serving_softirq()	(softirq_count() & SOFTIRQ_OFFSET)
> >  #define in_nmi()		(preempt_count() & NMI_MASK)
> > +#define in_irq_or_nmi()		(preempt_count() & (HARDIRQ_MASK | NMI_MASK))
> >  #define in_task()		(!(preempt_count() & \
> >  				   (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
> >   =20
>=20
> No, that's horrible. Also, wth is this about? A memory allocator that
> needs in_nmi()? That sounds beyond broken.

It is the other way around. We want to exclude NMI and HARDIRQ from
using the per-cpu-pages (pcp) lists "order-0 cache" (they will
fall-through using the normal buddy allocator path).

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
