Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFC36B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 19:55:26 -0400 (EDT)
Received: by qgx61 with SMTP id 61so135544954qgx.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 16:55:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 79si18265754qhs.124.2015.09.28.16.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 16:55:25 -0700 (PDT)
Date: Mon, 28 Sep 2015 16:55:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/10] mm, page_alloc: Rename __GFP_WAIT to
 __GFP_RECLAIM
Message-Id: <20150928165523.a52facb27c7ff4c29d902b6c@linux-foundation.org>
In-Reply-To: <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
	<1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Sep 2015 11:52:38 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> __GFP_WAIT was used to signal that the caller was in atomic context and
> could not sleep.  Now it is possible to distinguish between true atomic
> context and callers that are not willing to sleep. The latter should clear
> __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> behaves differently, there is a risk that people will clear the wrong
> flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> what it does -- setting it allows all reclaim activity, clearing them
> prevents it.

We have quite a history of remote parts of the kernel using
weird/wrong/inexplicable combinations of __GFP_ flags.  I tend to think
that this is because we didn't adequately explain the interface.

And I don't think that gfp.h really improved much in this area as a
result of this patchset.  Could you go through it some time and decide
if we've adequately documented all this stuff?

GFP_ATOMIC vs GFP_NOWAIT?

GFP_USER vs GFP_HIGHUSER?

When should I use GFP_HIGHUSER_MOVABLE instead?

Why isn't there a GFP_USER_MOVABLE?

What's GFP_IOFS?

GFP_RECLAIM_MASK through GFP_SLAB_BUG_MASK are mm-internal, but look
the same as the exported interface definitions.

__GFP_MOVABLE is documented twice, the second in an odd place.

etcetera.


It's rather unclear which symbols are part of the exported interface
and which are "mm internal only".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
