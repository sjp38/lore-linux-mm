Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA176B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 20:06:47 -0400 (EDT)
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in sl[aou]b
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.1.10.0906291910130.32637@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
	 <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
	 <1246315553.21295.100.camel@calx>
	 <alpine.DEB.1.10.0906291910130.32637@gentwo.org>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 19:06:34 -0500
Message-Id: <1246320394.21295.105.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-29 at 19:19 -0400, Christoph Lameter wrote:
> On Mon, 29 Jun 2009, Matt Mackall wrote:
> 
> > This is a reasonable point, and in keeping with the design principle
> > 'callers should handle their own special cases'. However, I think it
> > would be more than a little surprising for kmem_cache_free() to do the
> > right thing, but not kmem_cache_destroy().
> 
> kmem_cache_free() must be used carefully when using SLAB_DESTROY_BY_RCU.
> The freed object can be accessed after free until the rcu interval
> expires (well sortof, it may even be reallocated within the interval).
> 
> There are special RCU considerations coming already with the use of
> kmem_cache_free().
> 
> Adding RCU operations to the kmem_cache_destroy() logic may result in
> unnecessary RCU actions for slabs where the coder is ensuring that the
> RCU interval has passed by other means.

Do we care? Cache destruction shouldn't be in anyone's fast path.
Correctness is more important and users are more liable to be correct
with this patch.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
