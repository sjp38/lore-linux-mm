Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id B914E6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:07:26 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so6586832igb.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:07:26 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id i200si1264440ioi.11.2015.02.11.11.07.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 11:07:26 -0800 (PST)
Date: Wed, 11 Feb 2015 13:07:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
In-Reply-To: <20150211174817.44cc5562@redhat.com>
Message-ID: <alpine.DEB.2.11.1502111305520.7547@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.902155759@linux.com> <20150211174817.44cc5562@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Wed, 11 Feb 2015, Jesper Dangaard Brouer wrote:

> > +
> > +
> > +	spin_lock_irqsave(&n->list_lock, flags);
>
> This is quite an expensive lock with irqsave.

Yes but we take it for all partial pages.

> Yet another lock cost.

Yup the page access is shared but there is one per page. Contention is
unlikely.

> > +	spin_unlock_irqrestore(&n->list_lock, flags);
> > +	return allocated;
>
> I estimate (on my CPU) the locking cost itself is more than 32ns, plus
> the irqsave (which I've also found quite expensive, alone 14ns).  Thus,
> estimated 46ns.  Single elem slub fast path cost is 18-19ns. Thus 3-4
> elem bulking should be enough to amortized the cost, guess we are still
> good :-)

We can require that interrupt are off when the functions are called. Then
we can avoid the "save" part?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
