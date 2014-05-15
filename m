Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB206B0038
	for <linux-mm@kvack.org>; Thu, 15 May 2014 11:15:14 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so2006557qcy.39
        for <linux-mm@kvack.org>; Thu, 15 May 2014 08:15:14 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id d50si2724458qge.34.2014.05.15.08.15.13
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 08:15:14 -0700 (PDT)
Date: Thu, 15 May 2014 10:15:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg
 caches
In-Reply-To: <20140515063441.GA32113@esperanza>
Message-ID: <alpine.DEB.2.10.1405151011210.24665@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141114040.16512@gentwo.org> <20140515063441.GA32113@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 May 2014, Vladimir Davydov wrote:

> > That will significantly impact the fastpaths for alloc and free.
> >
> > Also a pretty significant change the logic of the fastpaths since they
> > were not designed to handle the full lists. In debug mode all operations
> > were only performed by the slow paths and only the slow paths so far
> > supported tracking full slabs.
>
> That's the minimal price we have to pay for slab re-parenting, because
> w/o it we won't be able to look up for all slabs of a particular per
> memcg cache. The question is, can it be tolerated or I'd better try some
> other way?

AFACIT these modifications all together will have a significant impact on
performance.

You could avoid the refcounting on free relying on the atomic nature of
cmpxchg operations. If you zap the per cpu slab then the fast path will be
forced to fall back to the slowpaths where you could do what you need to
do.

There is no tracking of full slabs without adding much more logic to the
fastpath. You could force any operation that affects tne full list into
the slow path. But that also would have an impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
