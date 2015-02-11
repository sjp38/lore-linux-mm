Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 668536B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:43:26 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id c41so2744883yho.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:43:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e4si2442864qai.92.2015.02.11.13.43.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 13:43:25 -0800 (PST)
Date: Thu, 12 Feb 2015 10:43:16 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
Message-ID: <20150212104316.2d5c32ea@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1502111305520.7547@gentwo.org>
References: <20150210194804.288708936@linux.com>
	<20150210194811.902155759@linux.com>
	<20150211174817.44cc5562@redhat.com>
	<alpine.DEB.2.11.1502111305520.7547@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com

On Wed, 11 Feb 2015 13:07:24 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 11 Feb 2015, Jesper Dangaard Brouer wrote:
> 
> > > +
> > > +
> > > +	spin_lock_irqsave(&n->list_lock, flags);
> >
> > This is quite an expensive lock with irqsave.
> 
> Yes but we take it for all partial pages.

Sure, that is good, but this might be a contention point. In a micro
benchmark, this contention should be visible, but in real use-cases the
given subsystem also need to spend time to use these elements before
requesting a new batch (as long as NIC cleanup cycles don't get too
synchronized)


> > Yet another lock cost.
> 
> Yup the page access is shared but there is one per page. Contention is
> unlikely.

Yes, contention is unlikely, but every atomic operation is expensive.
On my system the measured cost is 8ns, and a lock/unlock does two, thus
16ns.  Which we then do per page freelist.


> > > +	spin_unlock_irqrestore(&n->list_lock, flags);
> > > +	return allocated;
> >
> > I estimate (on my CPU) the locking cost itself is more than 32ns, plus
> > the irqsave (which I've also found quite expensive, alone 14ns).  Thus,
> > estimated 46ns.  Single elem slub fast path cost is 18-19ns. Thus 3-4
> > elem bulking should be enough to amortized the cost, guess we are still
> > good :-)
> 
> We can require that interrupt are off when the functions are called. Then
> we can avoid the "save" part?

Yes, we could also do so with an "_irqoff" variant of the func call,
but given we are defining the API we can just require this from the
start.

I plan to use this in softirq, where I know interrupts are on, but I
can use the less-expensive "non-save" variant local_irq_{disable,enable}.

Measurements show (x86_64 E5-2695):
 *  2.860 ns cost for local_irq_{disable,enable}
 * 14.840 ns cost for local_irq_save()+local_irq_restore()

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
