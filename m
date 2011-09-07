Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFB76B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 11:01:25 -0400 (EDT)
Date: Wed, 7 Sep 2011 10:01:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: continue to seek slab in node partial if met
 a null page
In-Reply-To: <1315363526.31737.164.camel@debian>
Message-ID: <alpine.DEB.2.00.1109070958050.9406@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <1315362396.31737.151.camel@debian> <1315363526.31737.164.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

On Wed, 7 Sep 2011, Alex,Shi wrote:

> In the per cpu partial slub, we may add a full page into node partial
> list. like the following scenario:
>
> 	cpu1     		        	cpu2
>     in unfreeze_partials	           in __slab_alloc
> 	...
>    add_partial(n, page, 1);
> 					alloced from cpu partial, and
> 					set frozen = 1.
>    second cmpxchg_double_slab()
>    set frozen = 0

This scenario cannot happen as the frozen state confers ownership to a
cpu (like the cpu slabs). The cpu partial lists are different from the per
node partial lists and a slab on the per node partial lists should never
have the frozen bit set.

> If it happen, we'd better to skip the full page and to seek next slab in
> node partial instead of jump to other nodes.

But I agree that the patch can be beneficial if acquire slab ever returns
a full page. That should not happen though. Is this theoretical or do you
have actual tests that show that this occurs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
