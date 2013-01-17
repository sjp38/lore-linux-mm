Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 934626B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 13:37:46 -0500 (EST)
Message-ID: <1358447864.23211.34.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the
 node_match check
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 13:37:44 -0500
In-Reply-To: <1358446258.23211.32.camel@gandalf.local.home>
References: <1358446258.23211.32.camel@gandalf.local.home>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio
 R. Goncalves" <lgoncalv@redhat.com>

On Thu, 2013-01-17 at 13:10 -0500, Steven Rostedt wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 2d9511a..85b95d5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2399,7 +2399,7 @@ redo:
>  
>  	object = c->freelist;
>  	page = c->page;
> -	if (unlikely(!object || !node_match(page, node)))
> +	if (unlikely(!object || !page || !node_match(page, node)))

I'm still trying to see if c->freelist != NULL and c->page == NULL isn't
a bug. The cmpxchg_doubles are a little confusing. If it's not expected
that page is NULL but freelist isn't than we need to figure out why it
happened.

-- Steve

>  		object = __slab_alloc(s, gfpflags, node, addr, c);
>  
>  	else {
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
