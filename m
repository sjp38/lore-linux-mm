Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C84306B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:31:31 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C0BE382C0EE
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:33:09 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vtptJI44u+5y for <linux-mm@kvack.org>;
	Mon, 26 Jan 2009 12:33:09 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CCAB482C12A
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:33:00 -0500 (EST)
Date: Mon, 26 Jan 2009 12:28:03 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090123155307.GB14517@wotan.suse.de>
Message-ID: <alpine.DEB.1.10.0901261225240.1908@qirst.com>
References: <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com> <20090116034356.GM17810@wotan.suse.de> <Pine.LNX.4.64.0901161509160.27283@quilx.com>
 <20090119061856.GB22584@wotan.suse.de> <alpine.DEB.1.10.0901211903540.18367@qirst.com> <20090123040913.GG20098@wotan.suse.de> <alpine.DEB.1.10.0901231033210.32253@qirst.com> <20090123155307.GB14517@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

n Fri, 23 Jan 2009, Nick Piggin wrote:

> According to memory policies, a task's memory policy is supposed to
> apply to its slab allocations too.

It does apply to slab allocations. The question is whether it has to apply
to every object allocation or to every page allocation of the slab
allocators.

> > Memory policies are applied in a fuzzy way anyways. A context switch can
> > result in page allocation action that changes the expected interleave
> > pattern. Page populations in an address space depend on the task policy.
> > So the exact policy applied to a page depends on the task. This isnt an
> > exact thing.
>
> There are other memory policies than just interleave though.

Which have similar issues since memory policy application is depending on
a task policy and on memory migration that has been applied to an address
range.

> > >  "the first cpu will consume more and more memory from the page allocator
> > >   whereas the second will build up huge per cpu lists"
> > >
> > > And this is wrong. There is another possible issue where every single
> > > object on the freelist might come from a different (and otherwise free)
> > > page, and thus eg 100 8 byte objects might consume 400K.
> > >
> > > That's not an invalid concern, but I think it will be quite rare, and
> > > the periodic queue trimming should naturally help this because it will
> > > cycle out those objects and if new allocations are needed, they will
> > > come from new pages which can be packed more densely.
> >
> > Well but you said that you would defer the trimming (due to latency
> > concerns). The longer you defer the larger the lists will get.
>
> But that is wrong. The lists obviously have high water marks that
> get trimmed down. Periodic trimming as I keep saying basically is
> alrady so infrequent that it is irrelevant (millions of objects
> per cpu can be allocated anyway between existing trimming interval)

Trimming through water marks and allocating memory from the page allocator
is going to be very frequent if you continually allocate on one processor
and free on another.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
