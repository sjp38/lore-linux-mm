Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0137D828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:49:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so140807323pfa.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 17:49:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u5si3023998pag.198.2016.06.22.17.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 17:49:40 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5N0nAVb059285
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:49:39 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23q1qph5ja-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:49:39 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Jun 2016 20:49:38 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1A7E76E804A
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:49:18 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5N0nbik9240932
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 00:49:37 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5N0nZgp014015
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:49:35 -0400
Date: Wed, 22 Jun 2016 17:49:35 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Reply-To: paulmck@linux.vnet.ibm.com
References: <CAMuHMdXc=XN4z96vr_FNcUzFb0203ovHgcfD95Q5LPebr1z0ZQ@mail.gmail.com>
 <20160615022325.GA19863@js1304-P5Q-DELUXE>
 <CAMuHMdVi-F0n-GjnUqEEd58UcWxw67g8ZJO838fvo31Ttr5E1g@mail.gmail.com>
 <20160620063942.GA13747@js1304-P5Q-DELUXE>
 <20160620131254.GO3923@linux.vnet.ibm.com>
 <20160621064302.GA20635@js1304-P5Q-DELUXE>
 <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE>
 <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622190859.GA1473@linux.vnet.ibm.com>
Message-Id: <20160623004935.GA20752@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jun 22, 2016 at 12:08:59PM -0700, Paul E. McKenney wrote:
> On Wed, Jun 22, 2016 at 05:01:35PM +0200, Geert Uytterhoeven wrote:
> > On Wed, Jun 22, 2016 at 2:52 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > Could you try below patch to check who causes the hang?
> > >
> > > And, if sysalt-t works when hang, could you get sysalt-t output? I haven't
> > > used it before but Paul could find some culprit on it. :)
> > >
> > > Thanks.
> > >
> > >
> > > ----->8-----
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 763096a..9652d38 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -964,8 +964,13 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> > >          * guaranteed to be valid until irq is re-enabled, because it will be
> > >          * freed after synchronize_sched().
> > >          */
> > > -       if (force_change)
> > > +       if (force_change) {
> > > +               if (num_online_cpus() > 1)
> > > +                       dump_stack();
> > >                 synchronize_sched();
> > > +               if (num_online_cpus() > 1)
> > > +                       dump_stack();
> > > +       }
> > 
> > I've only added the first one, as I would never see the second one. All of
> > this happens before the serial console is activated, earlycon is not supported,
> > and I only have remote access.
> > 
> > Brought up 2 CPUs
> > SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> > CPU: All CPU(s) started in SVC mode.
> > CPU: 0 PID: 1 Comm: swapper/0 Not tainted
> > 4.7.0-rc4-kzm9d-00404-g4a235e6dde4404dd-dirty #89
> > Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
> > [<c010de68>] (unwind_backtrace) from [<c010a658>] (show_stack+0x10/0x14)
> > [<c010a658>] (show_stack) from [<c02b5cf8>] (dump_stack+0x7c/0x9c)
> > [<c02b5cf8>] (dump_stack) from [<c01cfa4c>] (setup_kmem_cache_node+0x140/0x170)
> > [<c01cfa4c>] (setup_kmem_cache_node) from [<c01cfe3c>]
> > (__do_tune_cpucache+0xf4/0x114)
> > [<c01cfe3c>] (__do_tune_cpucache) from [<c01cff54>] (enable_cpucache+0xf8/0x148)
> > [<c01cff54>] (enable_cpucache) from [<c01d0190>]
> > (__kmem_cache_create+0x1a8/0x1d0)
> > [<c01d0190>] (__kmem_cache_create) from [<c01b32d0>]
> > (kmem_cache_create+0xbc/0x190)
> > [<c01b32d0>] (kmem_cache_create) from [<c070d968>] (shmem_init+0x34/0xb0)
> > [<c070d968>] (shmem_init) from [<c0700cc8>] (kernel_init_freeable+0x98/0x1ec)
> > [<c0700cc8>] (kernel_init_freeable) from [<c049fdbc>] (kernel_init+0x8/0x110)
> > [<c049fdbc>] (kernel_init) from [<c0106cb8>] (ret_from_fork+0x14/0x3c)
> > devtmpfs: initialized
> 
> I don't see anything here that would prevent grace periods from completing.
> 
> The CPUs are using the normal hotplug sequence to come online, correct?

And either way, could you please apply the patch below and then
invoke rcu_dump_rcu_sched_tree() just before the offending call to
synchronize_sched()?  That will tell me what CPUs RCU believes exist,
and perhaps also which CPU is holding it up.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
