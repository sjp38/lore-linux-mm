Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 394EF6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:55:16 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id r10so557264igi.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 11:55:16 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id m4si8120466iod.50.2015.01.26.11.55.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 11:55:15 -0800 (PST)
Date: Mon, 26 Jan 2015 13:55:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
In-Reply-To: <20150126194838.GB2660@esperanza>
Message-ID: <alpine.DEB.2.11.1501261353480.16786@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260949150.15849@gentwo.org> <20150126170418.GC28978@esperanza> <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
 <20150126194838.GB2660@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> Hmm, why? The return value has existed since this function was
> introduced, but nobody seems to have ever used it outside the slab core.
> Besides, this check is racy, so IMO we shouldn't encourage users of the
> API to rely on it. That said, I believe we should drop the return value
> for now. If anybody ever needs it, we can reintroduce it.

The check is only racy if you have concurrent users. It is not racy if a
subsystem shuts down access to the slabs and then checks if everything is
clean before closing the cache.

Slab creation and destruction are not serialized. It is the responsibility
of the subsystem to make sure that there are no concurrent users and that
there are no objects remaining before destroying a slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
