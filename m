Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id C60F06B0038
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 13:56:23 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so3455423lab.13
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 10:56:22 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si24670269lab.124.2014.04.21.10.56.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Apr 2014 10:56:21 -0700 (PDT)
Message-ID: <53555BBE.2020804@parallels.com>
Date: Mon, 21 Apr 2014 21:56:14 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] how should we deal with dead memcgs' kmem caches?
References: <5353A3E3.4020302@parallels.com> <alpine.DEB.2.10.1404211128450.28094@gentwo.org>
In-Reply-To: <alpine.DEB.2.10.1404211128450.28094@gentwo.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, devel@openvz.org

21.04.2014 20:29, Christoph Lameter:
> On Sun, 20 Apr 2014, Vladimir Davydov wrote:
> 
>> * Way #1 - prevent dead kmem caches from caching slabs on free *
>>
>> We can modify sl[au]b implementation so that it won't cache any objects
>> on free if the kmem cache belongs to a dead memcg. Then it'd be enough
>> to drain per-cpu pools of all dead kmem caches on css offline - no new
>> slabs will be added there on further frees, and the last object will go
>> away along with the last slab.
> 
> You can call kmem_cache_shrink() to force slab allocators to drop cached
> objects after a free.

Yes, but the question is when and how often should we do that? Calling
it after each kfree would be an overkill, because there may be plenty of
objects in a dead cache. Calling it periodically or on vmpressure is the
first thing that springs to mind - that's covered by "way #2".

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
