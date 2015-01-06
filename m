Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EEFCF6B00DA
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 12:02:33 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so30792522pdi.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 09:02:33 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id xr7si90050286pab.168.2015.01.06.09.02.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 09:02:31 -0800 (PST)
Message-ID: <1420563737.24290.7.camel@stgolabs.net>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 06 Jan 2015 09:02:17 -0800
In-Reply-To: <20150106080948.GA18346@js1304-P5Q-DELUXE>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1420513392.24290.2.camel@stgolabs.net>
	 <20150106080948.GA18346@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Tue, 2015-01-06 at 17:09 +0900, Joonsoo Kim wrote:
> On Mon, Jan 05, 2015 at 07:03:12PM -0800, Davidlohr Bueso wrote:
> > On Mon, 2015-01-05 at 10:36 +0900, Joonsoo Kim wrote:
> > > -	preempt_disable();
> > > -	c = this_cpu_ptr(s->cpu_slab);
> > > +	do {
> > > +		tid = this_cpu_read(s->cpu_slab->tid);
> > > +		c = this_cpu_ptr(s->cpu_slab);
> > > +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> > > +	barrier();
> > 
> > I don't see the compiler reodering the object/page stores below, since c
> > is updated in the loop anyway. Is this really necessary (same goes for
> > slab_free)? The generated code by gcc 4.8 looks correct without it.
> > Additionally, the implied barriers for preemption control aren't really
> > the same semantics used here (if that is actually the reason why you are
> > using them).
> 
> Hello,
> 
> I'd like to use tid as a pivot so it should be fetched before fetching
> anything on c. Is it impossible even if !CONFIG_PREEMPT without
> barrier()?

You'd need a smp_wmb() in between tid and c in the loop then, which
looks quite unpleasant. All in all disabling preemption isn't really
that expensive, and you should redo your performance number if you go
this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
