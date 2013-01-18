Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E903D6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 14:20:37 -0500 (EST)
Message-ID: <1358536835.7383.31.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH v3] slub: Keep page and object in sync in
 slab_alloc_node()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 18 Jan 2013 14:20:35 -0500
In-Reply-To: <1358536190.11051.573.camel@edumazet-glaptop>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458996.23211.46.camel@gandalf.local.home>
	 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
	 <1358462763.23211.57.camel@gandalf.local.home>
	 <1358464245.23211.62.camel@gandalf.local.home>
	 <1358464837.23211.66.camel@gandalf.local.home>
	 <1358468598.23211.67.camel@gandalf.local.home>
	 <1358468924.23211.69.camel@gandalf.local.home>
	 <1358521791.7383.11.camel@gandalf.local.home>
	 <0000013c4ef61783-2778b0f1-fdc1-421b-9d3e-ccd68d528115-000000@email.amazonses.com>
	 <1358536190.11051.573.camel@edumazet-glaptop>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio
 R. Goncalves" <lgoncalv@redhat.com>

On Fri, 2013-01-18 at 11:09 -0800, Eric Dumazet wrote:
> On Fri, 2013-01-18 at 18:40 +0000, Christoph Lameter wrote:
> 
> > The fetching of the tid is the only critical thing here. If the tid is
> > retrieved from the right cpu then the cmpxchg will fail if any changes
> > occured to freelist or the page variable.
> > 
> > The tid can be retrieved without disabling preemption through
> > this_cpu_read().
> 
> Strictly speaking, this_cpu_read() _does_ disable preemption.

I was thinking the same thing.

> 
> Of course, on x86, this_cpu_read() uses __this_cpu_read()


Looking at using this_cpu_read() on tid, I can't see what would break.
We still need the check for page being NULL in node_match(). I'm still
uneasy about it. Just because we can't see how it might break doesn't
mean that it wont. As we have already found a bit of bugs in the current
code. I'd feel more comfortable with the explicit preempt_disable(). And
this is coming from an -rt guy that tries to avoid preempt_disable().
But you're (Christoph) the maintainer.

I guess if you use this_cpu_read() you don't need that barrier anymore.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
