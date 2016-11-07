Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9216B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 13:52:10 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 206so36940973ybz.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 10:52:10 -0800 (PST)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id s7si7001014ywg.249.2016.11.07.10.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 10:52:09 -0800 (PST)
Received: by mail-yw0-x22e.google.com with SMTP id l124so149663350ywb.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 10:52:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611031531380.13315@east.gentwo.org>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com>
 <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com>
 <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com>
 <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com> <alpine.DEB.2.20.1611031531380.13315@east.gentwo.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 7 Nov 2016 10:52:08 -0800
Message-ID: <CAJcbSZHaN8zVf4_MdpmofNCY719YfRsRq+PjLR-a+M4QGyCnGw@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB & OBJFREELIST_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Thu, Nov 3, 2016 at 1:33 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 2 Nov 2016, David Rientjes wrote:
>
>> > Christoph on the first version advised removing invalid flags on the
>> > caller and checking they are correct in kmem_cache_create. The memcg
>> > path putting the wrong flags is through create_cache but I still used
>> > this approach.
>> >
>>
>> I think this is a rather trivial point since it doesn't matter if we clear
>> invalid flags on the caller or in the callee and obviously
>> kmem_cache_create() does it in the callee.
>
> In order to be correct we need to do the following:
>
> kmem_cache_create should check for invalid flags (and that includes
> internal alloocator flgs) being set and refuse to create the slab cache.
>
> memcg needs to call kmem_cache_create without any internal flags.
>

I am not sure that is possible. kmem_cache_create currently check for
possible alias, I assume that it goes against what memcg tries to do.

Separate the changes in two patches might make sense:

 1) Fix the original bug by masking the flags passed to create_cache
 2) Add flags check in kmem_cache_create.

Does it make sense?

> I also want to make sure that there are no other callers that specify
> extraneou flags while we are at it.
>

I will review as many as I can but we might run into surprises (quick
boot on defconfig didn't show anything). That's why having two
different patches might be useful.

-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
