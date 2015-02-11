Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9F56C6B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:06:52 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so2505786yha.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:06:52 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id hu8si2572028qcb.26.2015.02.11.14.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 14:06:51 -0800 (PST)
Date: Wed, 11 Feb 2015 16:06:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
In-Reply-To: <20150212104316.2d5c32ea@redhat.com>
Message-ID: <alpine.DEB.2.11.1502111604510.15061@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.902155759@linux.com> <20150211174817.44cc5562@redhat.com> <alpine.DEB.2.11.1502111305520.7547@gentwo.org> <20150212104316.2d5c32ea@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Thu, 12 Feb 2015, Jesper Dangaard Brouer wrote:

> > > This is quite an expensive lock with irqsave.
> >
> > Yes but we take it for all partial pages.
>
> Sure, that is good, but this might be a contention point. In a micro
> benchmark, this contention should be visible, but in real use-cases the
> given subsystem also need to spend time to use these elements before
> requesting a new batch (as long as NIC cleanup cycles don't get too
> synchronized)

Yes definitely it will be a contention point. There is no way around it.

> > Yup the page access is shared but there is one per page. Contention is
> > unlikely.
>
> Yes, contention is unlikely, but every atomic operation is expensive.
> On my system the measured cost is 8ns, and a lock/unlock does two, thus
> 16ns.  Which we then do per page freelist.

Not sure what we can do about this.

> > We can require that interrupt are off when the functions are called. Then
> > we can avoid the "save" part?
>
> Yes, we could also do so with an "_irqoff" variant of the func call,
> but given we are defining the API we can just require this from the
> start.

Allright. Lets do that then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
