Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 380DF6B0002
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 03:12:08 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so15335ieb.28
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 00:12:07 -0800 (PST)
Message-ID: <1359101516.16101.6.camel@kernel>
Subject: Re: FIX [1/2] slub: Do not dereference NULL pointer in node_match
From: Simon Jeons <simon.jeons@gmail.com>
Date: Fri, 25 Jan 2013 02:11:56 -0600
In-Reply-To: <0000013c6d200e1d-03ae09c1-6fb8-42eb-ab6c-8fcae05fdb6e-000000@email.amazonses.com>
References: <20130123214514.370647954@linux.com>
	 <0000013c695fbd30-9023bc55-f780-4d44-965f-ab4507e483d5-000000@email.amazonses.com>
	 <1358988824.3351.5.camel@kernel>
	 <0000013c6d200e1d-03ae09c1-6fb8-42eb-ab6c-8fcae05fdb6e-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis
 Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Thu, 2013-01-24 at 15:14 +0000, Christoph Lameter wrote:
> On Wed, 23 Jan 2013, Simon Jeons wrote:
> 
> > On Wed, 2013-01-23 at 21:45 +0000, Christoph Lameter wrote:
> > > The variables accessed in slab_alloc are volatile and therefore
> > > the page pointer passed to node_match can be NULL. The processing
> > > of data in slab_alloc is tentative until either the cmpxhchg
> > > succeeds or the __slab_alloc slowpath is invoked. Both are
> > > able to perform the same allocation from the freelist.
> > >
> > > Check for the NULL pointer in node_match.
> > >
> > > A false positive will lead to a retry of the loop in __slab_alloc.
> >
> > Hi Christoph,
> >
> > Since page_to_nid(NULL) will trigger bug, then how can run into
> > __slab_alloc?
> 
> page = NULL
> 
> 	 ->
> 
> node_match(NULL, xx) = 0
> 
>  	->
> 
> call into __slab_alloc.
> 
> __slab_alloc() will check for !c->page which requires the assignment of a
> new per cpu slab page.
> 

But there are dereference in page_to_nid path, function page_to_section:
return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
