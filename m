Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C3D706B0044
	for <linux-mm@kvack.org>; Tue,  8 May 2012 15:22:16 -0400 (EDT)
Date: Tue, 8 May 2012 14:22:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: sl[auo]b: Use atomic bit operations to update
 page-flags.
In-Reply-To: <1336504276.3752.2600.camel@edumazet-glaptop>
Message-ID: <alpine.DEB.2.00.1205081417120.27713@router.home>
References: <1336503339-18722-1-git-send-email-pshelar@nicira.com> <1336504276.3752.2600.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Tue, 8 May 2012, Eric Dumazet wrote:

> On Tue, 2012-05-08 at 11:55 -0700, Pravin B Shelar wrote:
> > Transparent huge pages can change page->flags (PG_compound_lock)
> > without taking Slab lock. So sl[auo]b need to use atomic bit
> > operation while changing page->flags.
> > Specificly this patch fixes race between compound_unlock and slab
> > functions which does page-flags update. This can occur when
> > get_page/put_page is called on page from slab object.
>
>
> But should get_page()/put_page() be called on a page own by slub ?

Can occur in slab allocators if the slab memory is used for DMA. I dont
like the performance impact of the atomics. In particular slab_unlock() in
slub is or used to be a hot path item. It is still hot on arches that do
not support this_cpu_cmpxchg_double. With the cmpxchg_double only the
debug mode is affected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
