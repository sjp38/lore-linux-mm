Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 022F16B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:22:19 -0500 (EST)
Date: Thu, 17 Jan 2013 21:22:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the node_match
 check
In-Reply-To: <1358446258.23211.32.camel@gandalf.local.home>
Message-ID: <0000013c4a64146b-68cd6f7d-f7e2-460b-9ee5-d931714ce062-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Thu, 17 Jan 2013, Steven Rostedt wrote:

> Anyway, looking at where this crashed, it seems that the page variable
> can be NULL when passed to the node_match() function (which does not
> check if it is NULL). When this happens we get the above panic.
>
> As page is only used in slab_alloc() to check if the node matches, if
> it's NULL I'm assuming that we can say it doesn't and call the
> __slab_alloc() code. Is this a correct assumption?

c->page should only be NULL when c->freelist == NULL but obviously there
are race conditions where c->freelist may not have been zapped but c->page
was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
