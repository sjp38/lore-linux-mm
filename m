Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B48FA6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:21:41 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so25984655wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:21:41 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id p3si10183921wjp.160.2016.03.17.06.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 06:21:40 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id l124so8969699wmf.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160317125736.GT14143@nuc-i3427.alporthouse.com>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
	<CACZ9PQX+E2LscOGyVQ4xZNK3qdYYotq4HiyGc8o+YwoNi-w1Hg@mail.gmail.com>
	<20160317125736.GT14143@nuc-i3427.alporthouse.com>
Date: Thu, 17 Mar 2016 14:21:40 +0100
Message-ID: <CACZ9PQWMr4bU3ao46MF6dab2fhTDwL7g59iR0AcpbSPm91qD4g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/vmap: Add a notifier for when we run out of vmap
 address space
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Roman Peniaev <r.peniaev@gmail.com>, intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Mar 17, 2016 at 1:57 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> On Thu, Mar 17, 2016 at 01:37:06PM +0100, Roman Peniaev wrote:
>> > +       freed = 0;
>> > +       blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);
>>
>> It seems to me that alloc_vmap_area() was designed not to sleep,
>> at least on GFP_NOWAIT path (__GFP_DIRECT_RECLAIM is not set).
>>
>> But blocking_notifier_call_chain() might sleep.
>
> Indeed, I had not anticipated anybody using GFP_ATOMIC or equivalently
> restrictive gfp_t for vmap and yes there are such callers.
>
> Would guarding the notifier with gfp & __GFP_DIRECT_RECLAIM and
> !(gfp & __GFP_NORETRY) == be sufficient? Is that enough for GFP_NOFS?

I would use gfpflags_allow_blocking() for that purpose.

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
