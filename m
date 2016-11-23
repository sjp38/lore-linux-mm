Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC6D6B0269
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 03:50:18 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so1411063wjc.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:50:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e124si1418592wme.48.2016.11.23.00.50.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 00:50:17 -0800 (PST)
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
Date: Wed, 23 Nov 2016 09:50:12 +0100
MIME-Version: 1.0
In-Reply-To: <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On 11/22/2016 11:13 PM, Linus Torvalds wrote:
> On Tue, Nov 22, 2016 at 8:48 AM, Tejun Heo <tj@kernel.org> wrote:
>>
>> Hello,
>>
>> On Tue, Nov 22, 2016 at 04:47:49PM +0100, Vlastimil Babka wrote:
>>> Thanks. Makes me wonder whether we should e.g. add __GFP_NOWARN to
>>> GFP_NOWAIT globally at some point.
>>
>> Yeah, that makes sense.  The caller is explicitly saying that it's
>> okay to fail the allocation.
>
> I'm not so convinced about the "atomic automatically means you shouldn't warn".

Right, but atomic allocations should be using GFP_ATOMIC, which allows 
to use the atomic reserves. I meant here just GFP_NOWAIT which does not 
allow reserves, for allocations that are not in atomic context, but 
still don't want to reclaim for performance or whatever reasons, and 
have a suitable fallback. It's their choice to not spend any effort on 
the allocation and thus they shouldn't spew warnings IMHO.

> You'd certainly _hope_ that atomic allocations either have fallbacks
> or are harmless if they fail, but I'd still rather see that
> __GFP_NOWARN just to make that very much explicit.

A global change to GFP_NOWAIT would of course mean that we should audit 
its users (there don't seem to be many), whether they are using it 
consciously and should not rather be using GFP_ATOMIC.

Vlastimil

> Because as it is, atomic allocations certainly get to dig deeper into
> our memory reserves, but they most definitely can fail, and I
> definitely see how some code has no fallback because it thinks that
> the deeper reserves mean that it will succeed.
>
>              Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
