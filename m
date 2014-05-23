Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 772846B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 13:45:52 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so8540388qge.40
        for <linux-mm@kvack.org>; Fri, 23 May 2014 10:45:52 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id t2si4366260qae.64.2014.05.23.10.45.51
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 10:45:51 -0700 (PDT)
Date: Fri, 23 May 2014 12:45:48 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140523152642.GD3147@esperanza>
Message-ID: <alpine.DEB.2.10.1405231241250.22913@gentwo.org>
References: <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org> <537A4D27.1050909@parallels.com> <alpine.DEB.2.10.1405210937440.8038@gentwo.org>
 <20140521150408.GB23193@esperanza> <alpine.DEB.2.10.1405211912400.4433@gentwo.org> <20140522134726.GA3147@esperanza> <alpine.DEB.2.10.1405221422390.15766@gentwo.org> <20140523152642.GD3147@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 May 2014, Vladimir Davydov wrote:

> On Thu, May 22, 2014 at 02:25:30PM -0500, Christoph Lameter wrote:
> > slab_free calls __slab_free which can release slabs via
> > put_cpu_partial()/unfreeze_partials()/discard_slab() to the page
> > allocator. I'd rather have preemption enabled there.
>
> Hmm, why? IMO, calling __free_pages with preempt disabled won't hurt
> latency, because it proceeds really fast. BTW, we already call it for a
> bunch of pages from __slab_free() -> put_cpu_partial() ->
> unfreeze_partials() with irqs disabled, which is harder. FWIW, SLAB has
> the whole obj free path executed under local_irq_save/restore, and it
> doesn't bother enabling irqs for freeing pages.
>
> IMO, the latency improvement we can achieve by enabling preemption while
> calling __free_pages is rather minor, and it isn't worth complicating
> the code.

If you look at the end of unfreeze_partials() you see that we release
locks and therefore enable preempt before calling into the page allocator.

You never know what other new features they are going to be adding to the
page allocator. I'd rather be safe than sorry on this one. We have had
some trouble in the past with some debugging logic triggering.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
