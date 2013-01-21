Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4D25B6B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 20:48:09 -0500 (EST)
Date: Mon, 21 Jan 2013 01:48:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH v2] slub: Keep page and object in sync in
 slab_alloc_node()
In-Reply-To: <1358535129.7383.25.camel@gandalf.local.home>
Message-ID: <0000013c5aca8571-a7262239-40b0-401e-982f-29d2e5ad4416-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home> <1358447864.23211.34.camel@gandalf.local.home> <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com> <1358458996.23211.46.camel@gandalf.local.home>
 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com> <1358462763.23211.57.camel@gandalf.local.home> <1358464245.23211.62.camel@gandalf.local.home> <1358464837.23211.66.camel@gandalf.local.home> <1358468598.23211.67.camel@gandalf.local.home>
 <1358468924.23211.69.camel@gandalf.local.home> <0000013c4e1ea131-b8ab56b9-bfca-44fe-b5da-f030551194c9-000000@email.amazonses.com> <1358521484.7383.8.camel@gandalf.local.home> <1358524501.7383.17.camel@gandalf.local.home>
 <0000013c4eec1cbd-fb392b9f-b39e-4bcf-a043-2fa76fb8d35a-000000@email.amazonses.com> <1358535129.7383.25.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Fri, 18 Jan 2013, Steven Rostedt wrote:

> I'm curious to why not just add the preempt disable? It's rather quick
> and avoids all this complex trickery, which is just prone to bugs. It
> would make it much easier for others to review as well, and also keeps
> the setting of page, objects and cpu_slab consistent with everything
> else (which is assigned under preempt(irq)_disable).

Because this_cpu_read does not need the code to do a preempt disable on
x86 and on any other arch that will support this_cpu_read. this_cpu_read()
is implementable on many platform with a register  / offset in the same
way as on x86.

> > Well, the consequence would be that an object from another node than
> > desired will be allocated. Not that severe of an issue.
>
> Yes, it's not that severe of an issue, but it is still incorrect code.
> Why not just allocate on whatever node you want then? Why bother with
> the check at all?

The check so far has worked correctly for all tests.
Just because a rare race condition has been detected that may cause an
incorrect allocation does not mean that the check has no purpose at all.
And of course it needs to be fixed.

My patch with the check for page = NULL is enough to fix the potential
NULL pointer deref (which also is another case of a rare race that has
survived lots of tests so far).

The other issue with the wrong node needs some more thought and some tests
on the impact on the instruction overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
