Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8ADD46B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 09:44:57 -0500 (EST)
Date: Fri, 18 Jan 2013 14:44:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH v2] slub: Keep page and object in sync in
 slab_alloc_node()
In-Reply-To: <1358468924.23211.69.camel@gandalf.local.home>
Message-ID: <0000013c4e1ea131-b8ab56b9-bfca-44fe-b5da-f030551194c9-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home> <1358447864.23211.34.camel@gandalf.local.home> <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com> <1358458996.23211.46.camel@gandalf.local.home>
 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com> <1358462763.23211.57.camel@gandalf.local.home> <1358464245.23211.62.camel@gandalf.local.home> <1358464837.23211.66.camel@gandalf.local.home> <1358468598.23211.67.camel@gandalf.local.home>
 <1358468924.23211.69.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Thu, 17 Jan 2013, Steven Rostedt wrote:

> In slab_alloc_node(), after the cpu_slab is assigned, if the task is
> preempted and moves to another CPU, there's nothing keeping the page and
> object in sync. The -rt kernel crashed because page was NULL and object
> was not, and the node_match() dereferences page. Even though the crash
> happened on -rt, there's nothing that's keeping this from happening on
> mainline.
>
> The easiest fix is to disable interrupts for the entire time from
> acquiring the current CPU cpu_slab and assigning the object and page.
> After that, it's fine to allow preemption.

Its easiest to just check for the NULL pointer as initally done. The call
to __slab_alloc can do what the fastpath does.

And the fastpath will verify that the c->page pointer was not changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
