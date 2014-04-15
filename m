Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC5F56B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 15:32:21 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id f73so9853316yha.13
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 12:32:21 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id k49si20128159yhg.175.2014.04.15.12.32.20
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 12:32:21 -0700 (PDT)
Date: Tue, 15 Apr 2014 14:32:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/4] memcg, slab: do not schedule cache destruction
 when last page goes away
In-Reply-To: <534D83AB.6040107@parallels.com>
Message-ID: <alpine.DEB.2.10.1404151431400.29234@gentwo.org>
References: <cover.1397054470.git.vdavydov@parallels.com> <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com> <20140415021614.GC7969@cmpxchg.org> <534CD08F.30702@parallels.com> <alpine.DEB.2.10.1404151016400.11231@gentwo.org>
 <534D83AB.6040107@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mhocko@suse.cz, glommer@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue, 15 Apr 2014, Vladimir Davydov wrote:

> > There is already logic in both slub and slab that does that on cache
> > close.
>
> Yeah, but here the question is when we should close caches left after memcg
> offline. Obviously we should do it after all objects of such a cache have
> gone, but when exactly? Do it immediately after the last kfree (have to count
> objects per cache then AFAIU) or may be check periodically (or on vmpressure)
> that the cache is empty by issuing kmem_cache_shrink and looking if
> memcg_params::nr_pages = 0?

Guess check once in a while if you have no other way to determine this. A
hook in kfree() would impact all users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
