Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B3DAE6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 07:55:13 -0400 (EDT)
Date: Mon, 22 Mar 2010 11:55:08 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322115508.GE30031@ZenIV.linux.org.uk>
References: <20100322053937.GA17637@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322053937.GA17637@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 04:39:37PM +1100, Nick Piggin wrote:
> It's ugly and lazy that we do these default aops in case it has not
> been filled in by the filesystem.
> 
> A NULL operation should always mean either: we don't support the
> operation; we don't require any action; or a bug in the filesystem,
> depending on the context.
> 
> In practice, if we get rid of these fallbacks, it will be clearer
> what operations are used by a given address_space_operations struct,
> reduce branches, reduce #if BLOCK ifdefs, and should allow us to get
> rid of all the buffer_head knowledge from core mm and fs code.
> 
> We could add a patch like this which spits out a recipe for how to fix
> up filesystems and get them all converted quite easily.

Um.  Seeing that part of that is for methods absent in mainline (->release(),
->sync()), I'd say that making it mandatory at that point is a bad idea.

As for the rest...  We have 90 instances of address_space_operations
in the kernel.  Out of those:
	28 have ->releasepage != NULL
	27 have ->set_page_dirty != NULL
	25 have ->invalidatepage != NULL

So I'm not even sure that adding that much boilerplate makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
