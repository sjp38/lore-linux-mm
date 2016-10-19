Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D56D6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:16:32 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so73352643oig.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:16:32 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id q63si16414321oig.33.2016.10.19.11.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:16:31 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id i127so2051692oia.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:16:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 19 Oct 2016 11:16:30 -0700
Message-ID: <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed, Oct 19, 2016 at 10:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> These patches make the radix tree code explicitely support and track
> such special entries, to eliminate the subtleties and to restore the
> thrash detection for single-page files.

Ugh. I'm not a huge fan. The patches may be good and be a cleanup in
one respect, but they make one of my least favorite parts of the radix
tree code worse.

The radix tree "tag" thing is really horribly confusing, and part of
it is that there are two totally different "tags": the externally
visible tags (separate array), and the magical internal tags (low bits
of the node pointers that tag the pointers as internal or exceptional
entries).

And I think this series actually makes things even *more* complicated,
because now the radix tree itself uses one magical entry in the
externally visible tags for its own internal logic. So now it's
*really* messed up - the external tags aren't entirely external any
more.

Maybe I'm mis-reading it, and I'm just confused by the radix tree
implementation? But if so, it's just another sign of just how
confusing things are.

The external tag array itself is also somewhat nasty, in that it
spreads out the tag bits for one entry maximally (ie different bits
are in different words) so you can't even clear them together. I know
why - it makes both iterating over a specific tag and any_tag_set()
simpler, but it does seem confusing to me how we spread out the data
almost maximally.

I really would love to see somebody take a big look at the two
different tagging methods. If nothing else, explain it to me.

Because maybe this series is all great, and my objection is just that
it makes it even harder for me to understand the code.

For example, could we do this simplification:

 - get rid of RADIX_TREE_TAG_LONGS entirely
 - get rid of CONFIG_BASE_SMALL entirely
 - just say that the tag bitmap is one unsigned long
 - so RADIX_TREE_MAP_SIZE is just BITS_PER_LONG

and then at least we'd get rid of the double array and the confusion
about loops that are actually almost never loops. Because right now
RADIX_TREE_TAG_LONGS is usually 1, but is 2 if you're a 32-bit
platform with !CONFIG_BASE_SMALL. So you need those loops, but it all
looks almost entirely pointless.

I just get the feeling that we have already have unnecessary
complexity here, and that this patch series makes the code even more
impenetrable.

Comments?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
