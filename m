Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE956B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 17:13:48 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so17139555ioe.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 14:13:48 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id j187si4536019ith.7.2016.11.22.14.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 14:13:47 -0800 (PST)
Received: by mail-io0-x236.google.com with SMTP id j65so85376629iof.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 14:13:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161122164822.GA5459@htj.duckdns.org>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz> <20161122164822.GA5459@htj.duckdns.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Nov 2016 14:13:47 -0800
Message-ID: <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue, Nov 22, 2016 at 8:48 AM, Tejun Heo <tj@kernel.org> wrote:
>
> Hello,
>
> On Tue, Nov 22, 2016 at 04:47:49PM +0100, Vlastimil Babka wrote:
> > Thanks. Makes me wonder whether we should e.g. add __GFP_NOWARN to
> > GFP_NOWAIT globally at some point.
>
> Yeah, that makes sense.  The caller is explicitly saying that it's
> okay to fail the allocation.

I'm not so convinced about the "atomic automatically means you shouldn't warn".

You'd certainly _hope_ that atomic allocations either have fallbacks
or are harmless if they fail, but I'd still rather see that
__GFP_NOWARN just to make that very much explicit.

Because as it is, atomic allocations certainly get to dig deeper into
our memory reserves, but they most definitely can fail, and I
definitely see how some code has no fallback because it thinks that
the deeper reserves mean that it will succeed.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
