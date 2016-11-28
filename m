Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 696016B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:19:10 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id d187so141509732ywe.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:19:10 -0800 (PST)
Received: from mail-yb0-x243.google.com (mail-yb0-x243.google.com. [2607:f8b0:4002:c09::243])
        by mx.google.com with ESMTPS id k65si15037786ybc.309.2016.11.28.09.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 09:19:09 -0800 (PST)
Received: by mail-yb0-x243.google.com with SMTP id d128so198436ybh.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:19:09 -0800 (PST)
Date: Mon, 28 Nov 2016 12:19:07 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161128171907.GA14754@htj.duckdns.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

Hello,

On Wed, Nov 23, 2016 at 09:50:12AM +0100, Vlastimil Babka wrote:
> > You'd certainly _hope_ that atomic allocations either have fallbacks
> > or are harmless if they fail, but I'd still rather see that
> > __GFP_NOWARN just to make that very much explicit.
> 
> A global change to GFP_NOWAIT would of course mean that we should audit its
> users (there don't seem to be many), whether they are using it consciously
> and should not rather be using GFP_ATOMIC.

A while ago, I thought about something like, say, GFP_MAYBE which is
combination of NOWAIT and NOWARN but couldn't really come up with
scenarios where one would want to use NOWAIT w/o NOWARN.  If an
allocation is important enough to warn the user of its failure, it
better be dipping into the atomic reserve pool; otherwise, it doesn't
make sense to make noise.

Maybe we can come up with a better name which signifies that this is
likely to fail every now and then but I still think it'd be beneficial
to make it quiet by default.  Linus, do you still think NOWARN should
be explicit?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
