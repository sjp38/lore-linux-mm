Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 222B7900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 04:32:19 -0400 (EDT)
Subject: Re: [PATCH 2/2] slub: continue to seek slab in node partial if met
 a null page
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1109070958050.9406@router.home>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>  <1315362396.31737.151.camel@debian>
	 <1315363526.31737.164.camel@debian>
	 <alpine.DEB.2.00.1109070958050.9406@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 08 Sep 2011 16:38:03 +0800
Message-ID: <1315471083.31737.284.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>

On Wed, 2011-09-07 at 23:01 +0800, Christoph Lameter wrote:
> On Wed, 7 Sep 2011, Alex,Shi wrote:
> 
> > In the per cpu partial slub, we may add a full page into node partial
> > list. like the following scenario:
> >
> > 	cpu1     		        	cpu2
> >     in unfreeze_partials	           in __slab_alloc
> > 	...
> >    add_partial(n, page, 1);
> > 					alloced from cpu partial, and
> > 					set frozen = 1.
> >    second cmpxchg_double_slab()
> >    set frozen = 0
> 
> This scenario cannot happen as the frozen state confers ownership to a
> cpu (like the cpu slabs). The cpu partial lists are different from the per
> node partial lists and a slab on the per node partial lists should never
> have the frozen bit set.

oh, sorry, I am wrong here. 
Firstly, since unfreeze_partials only drain self cpu partial slabs, and
__slab_alloc also only check self cpu partial. So, above scenario won't
happen.  
Secondly, add_partial mean got the node list_lock already, so if
__slab_alloc try to alloc from the node partial, it won't get the
list_lock before cmpxchg finished. 

> 
> > If it happen, we'd better to skip the full page and to seek next slab in
> > node partial instead of jump to other nodes.
> 
> But I agree that the patch can be beneficial if acquire slab ever returns
> a full page. That should not happen though. Is this theoretical or do you
> have actual tests that show that this occurs?

I didn't find a real case for this now. So, do you still like to pick up
this as a defense for future more lockless usage? 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
