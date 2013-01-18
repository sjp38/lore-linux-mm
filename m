Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A48686B0009
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 13:29:23 -0500 (EST)
Date: Fri, 18 Jan 2013 18:29:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH v2] slub: Keep page and object in sync in
 slab_alloc_node()
In-Reply-To: <1358524501.7383.17.camel@gandalf.local.home>
Message-ID: <0000013c4eec1cbd-fb392b9f-b39e-4bcf-a043-2fa76fb8d35a-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home> <1358447864.23211.34.camel@gandalf.local.home> <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com> <1358458996.23211.46.camel@gandalf.local.home>
 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com> <1358462763.23211.57.camel@gandalf.local.home> <1358464245.23211.62.camel@gandalf.local.home> <1358464837.23211.66.camel@gandalf.local.home> <1358468598.23211.67.camel@gandalf.local.home>
 <1358468924.23211.69.camel@gandalf.local.home> <0000013c4e1ea131-b8ab56b9-bfca-44fe-b5da-f030551194c9-000000@email.amazonses.com> <1358521484.7383.8.camel@gandalf.local.home> <1358524501.7383.17.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Fri, 18 Jan 2013, Steven Rostedt wrote:

> On Fri, 2013-01-18 at 10:04 -0500, Steven Rostedt wrote:
>
> Just to be more complete:
>
> > 	CPU0			CPU1
> > 	----			----
> 			c = __this_cpu_ptr(s->cpu_slab);
> 			<migrates to CPU0>
>
> > <cpu fetches c->page>
> 			<another task>
>
> > 			updates c->tid

We can avoid the above scenario by doing a cpu local fetch.

i.e.
`	tid = this_cpu_read(s->cpu_slab->tid);


> > 			updates c->page
> > 			updates c->freelist
> > <cpu fetches c->tid>
> > <cpu fetches c->freelist>
> >
> >   node_match() succeeds even though
> >     current c->page wont
> >
>
>  <migrates back to CPU 1>
>
> >  this_cpu_cmpxchg_double() only tests
> >    the object (freelist) and tid, both which
> >    will match, but the page that was tested
> >    isn't the right one.
> >
>
> Yes, it's very unlikely, but we are in the business of dealing with the
> very unlikely. That's because in our business, the very unlikely is very
> likely. Damn, I need to buy a lotto ticket!

Well, the consequence would be that an object from another node than
desired will be allocated. Not that severe of an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
