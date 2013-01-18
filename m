Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 049E26B0005
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 19:23:20 -0500 (EST)
Message-ID: <1358468598.23211.67.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH] slub: Keep page and object in sync in
 slab_alloc_node()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 19:23:18 -0500
In-Reply-To: <1358464837.23211.66.camel@gandalf.local.home>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458996.23211.46.camel@gandalf.local.home>
	 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
	 <1358462763.23211.57.camel@gandalf.local.home>
	 <1358464245.23211.62.camel@gandalf.local.home>
	 <1358464837.23211.66.camel@gandalf.local.home>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R.
 Goncalves" <lgoncalv@redhat.com>

On Thu, 2013-01-17 at 18:20 -0500, Steven Rostedt wrote:
> 	object = c->freelist;
>  	page = c->page;

Hmm, having local_irq_restore() here is probably just as good, as object
and page were grabbed together under it. It doesn't change the condition
below any.

/me updates patch.

-- Steve

> -	if (unlikely(!object || !node_match(page, node)))
> +
> +	new_object = !object || !node_match(page, node);
> +	local_irq_restore(flags);
> +
> +	if (new_object)
>  		object = __slab_alloc(s, gfpflags, node, addr, c);
>  
>  	else {
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
