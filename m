Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id E2FC46B0035
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:06:04 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id c11so1506463lbj.3
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:06:04 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id sz4si19244853lbb.225.2014.04.18.09.06.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 09:06:03 -0700 (PDT)
Message-ID: <53514D66.1010607@parallels.com>
Date: Fri, 18 Apr 2014 20:05:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC -mm v2 1/3] memcg, slab: do not schedule cache destruction
 when last page goes away
References: <cover.1397804745.git.vdavydov@parallels.com> <e929fb6cc3a10ce1a9dcee0440e6995bdf427090.1397804745.git.vdavydov@parallels.com> <20140418134122.GB26283@cmpxchg.org>
In-Reply-To: <20140418134122.GB26283@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/18/2014 05:41 PM, Johannes Weiner wrote:
>> Thus we have a piece of code that works only when we explicitly call
>> kmem_cache_shrink, but complicates the whole picture a lot. Moreover,
>> it's racy in fact. For instance, kmem_cache_shrink may free the last
>> slab and thus schedule cache destruction before it finishes checking
>> that the cache is empty, which can lead to use-after-free.
>
> Can't this still happen when the last object free races with css
> destruction?

AFAIU, yes, it still can happen, but we have less places to fix now. I'm
planning to sort this out by rearranging operations inside
kmem_cache_free so that we do not touch the cache after we've
decremented memcg_cache_params::nr_pages and made the cache potentially
destroyable.

Or, if we could reparent individual slabs as you proposed earlier, we
wouldn't have to bother about it at all any more as well as about per
memcg cache destruction.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
