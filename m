Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0101A6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 19:18:49 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 501F582C50B
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 19:36:53 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YzD7UApMKMFx for <linux-mm@kvack.org>;
	Mon, 29 Jun 2009 19:36:53 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1182A82C510
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 19:36:47 -0400 (EDT)
Date: Mon, 29 Jun 2009 19:19:05 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in sl[aou]b
In-Reply-To: <1246315553.21295.100.camel@calx>
Message-ID: <alpine.DEB.1.10.0906291910130.32637@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>  <alpine.DEB.1.10.0906291827050.21956@gentwo.org> <1246315553.21295.100.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jun 2009, Matt Mackall wrote:

> This is a reasonable point, and in keeping with the design principle
> 'callers should handle their own special cases'. However, I think it
> would be more than a little surprising for kmem_cache_free() to do the
> right thing, but not kmem_cache_destroy().

kmem_cache_free() must be used carefully when using SLAB_DESTROY_BY_RCU.
The freed object can be accessed after free until the rcu interval
expires (well sortof, it may even be reallocated within the interval).

There are special RCU considerations coming already with the use of
kmem_cache_free().

Adding RCU operations to the kmem_cache_destroy() logic may result in
unnecessary RCU actions for slabs where the coder is ensuring that the
RCU interval has passed by other means.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
