Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 72CB26B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 10:41:07 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so3400022qgz.30
        for <linux-mm@kvack.org>; Wed, 21 May 2014 07:41:07 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id q20si1630562qax.103.2014.05.21.07.41.06
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 07:41:06 -0700 (PDT)
Date: Wed, 21 May 2014 09:41:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <537A4D27.1050909@parallels.com>
Message-ID: <alpine.DEB.2.10.1405210937440.8038@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org> <537A4D27.1050909@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 May 2014, Vladimir Davydov wrote:

> 3) Per cpu partial slabs. We can disable this feature for dead caches by
> adding appropriate check to kmem_cache_has_cpu_partial.

There is already a s->cpu_partial number in kmem_cache. If that is zero
then no partial cpu slabs should be kept.

> So far, everything looks very simple - it seems we don't have to modify
> __slab_free at all if we follow the instruction above.
>
> However, there is one thing regarding preemptable kernels. The problem
> is after forbidding the cache store free slabs in per-cpu/node partial
> lists by setting min_partial=0 and kmem_cache_has_cpu_partial=false
> (i.e. marking the cache as dead), we have to make sure that all frees
> that saw the cache as alive are over, otherwise they can occasionally
> add a free slab to a per-cpu/node partial list *after* the cache was
> marked dead. For instance,

Ok then lets switch off preeempt there? Preemption is not supported by
most distribution and so will have the least impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
