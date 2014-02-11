Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 47EFD6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:14:32 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id i4so9107358oah.11
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 04:14:31 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id kb7si9393084oeb.128.2014.02.11.04.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 04:14:31 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 11 Feb 2014 05:14:30 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C59C519D8042
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:14:27 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BCES6s8782258
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:14:28 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1BCHnwY020738
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:17:49 -0700
Date: Tue, 11 Feb 2014 04:14:26 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140211121426.GQ4250@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <52F60699.8010204@iki.fi>
 <alpine.DEB.2.10.1402101304110.17517@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402101304110.17517@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@iki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com

On Mon, Feb 10, 2014 at 01:07:58PM -0600, Christoph Lameter wrote:
> On Sat, 8 Feb 2014, Pekka Enberg wrote:
> 
> > So to be completely honest, I don't understand what is the race in (A) that
> > concerns the *memory allocator*.  I also don't what the memory allocator can
> > do in (B) and (C) which look like double-free and use-after-free,
> > respectively, to me. :-)
> 
> Well it seems to be some academic mind game to me.
> 
> Does an invocation of the allocator have barrier semantics or not?

In case (A), I don't see why the allocator should have barrier semantics
from kmalloc() to a matching kfree().  I would argue that any needed
barrier semantics must be provided by the caller.

In contrast, from kfree() to a kmalloc() returning some of the kfree()ed
memory, I believe the kfree()/kmalloc() implementation must do any needed
synchronization and ordering.  But that is a different set of examples,
for example, this one:

	CPU 0			CPU 1
	p->a = 42;		q = kmalloc(...); /* returning p */
	kfree(p);		q->a = 5;
				BUG_ON(q->a != 5);

Unlike the situation with (A), (B), and (C), in this case I believe
that it is kfree()'s and kmalloc()'s responsibility to ensure that
the BUG_ON() never triggers.

Make sense?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
