Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D4D676B0036
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 15:08:38 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id n15so7353301lbi.13
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 12:08:37 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c1si13663015lbp.128.2014.04.15.12.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Apr 2014 12:08:36 -0700 (PDT)
Message-ID: <534D83AB.6040107@parallels.com>
Date: Tue, 15 Apr 2014 23:08:27 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/4] memcg, slab: do not schedule cache destruction
 when last page goes away
References: <cover.1397054470.git.vdavydov@parallels.com> <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com> <20140415021614.GC7969@cmpxchg.org> <534CD08F.30702@parallels.com> <alpine.DEB.2.10.1404151016400.11231@gentwo.org>
In-Reply-To: <alpine.DEB.2.10.1404151016400.11231@gentwo.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mhocko@suse.cz, glommer@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi Christoph,

15.04.2014 19:17, Christoph Lameter:
> On Tue, 15 Apr 2014, Vladimir Davydov wrote:
>
>> 2) When freeing an object of a dead memcg cache, initiate thorough check
>> if the cache is really empty and destroy it then. That could be
>> implemented by poking the reaping thread on kfree, and actually does not
>> require the schedule_work in memcg_release_pages IMO.
>
> There is already logic in both slub and slab that does that on cache
> close.

Yeah, but here the question is when we should close caches left after 
memcg offline. Obviously we should do it after all objects of such a 
cache have gone, but when exactly? Do it immediately after the last 
kfree (have to count objects per cache then AFAIU) or may be check 
periodically (or on vmpressure) that the cache is empty by issuing 
kmem_cache_shrink and looking if memcg_params::nr_pages = 0?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
