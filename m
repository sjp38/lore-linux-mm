Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 638476B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:26:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so565450834pfk.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:26:35 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id v5si52239988pgi.224.2016.12.28.21.26.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 21:26:34 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id n5so17806297pgh.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:26:34 -0800 (PST)
Date: Thu, 29 Dec 2016 15:26:15 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting
 for a page bit
Message-ID: <20161229152615.2dad5402@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFxGz8R8J9jLvKpLUgyhWVYcgtObhbHBP7eZzZyc05AODw@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com>
	<20161225030030.23219-3-npiggin@gmail.com>
	<CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
	<20161226111654.76ab0957@roar.ozlabs.ibm.com>
	<CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
	<20161227211946.3770b6ce@roar.ozlabs.ibm.com>
	<CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
	<20161228135358.59f47204@roar.ozlabs.ibm.com>
	<CA+55aFz-evT+NiZY0GhO719M+=u==TbCqxTJTjp+pJevhDnRrw@mail.gmail.com>
	<20161229140837.5fff906d@roar.ozlabs.ibm.com>
	<CA+55aFxGz8R8J9jLvKpLUgyhWVYcgtObhbHBP7eZzZyc05AODw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Wed, 28 Dec 2016 20:16:56 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 28, 2016 at 8:08 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > Okay. The name could be a bit better though I think, for readability.
> > Just a BUILD_BUG_ON if it is not constant and correct bit numbers?  
> 
> I have a slightly edited patch - moved the comments around and added
> some new comments (about both the sign bit, but also about how the
> smp_mb() shouldn't be necessary even for the non-atomic fallback).

That's a good point -- they're in the same byte, so all architectures
will be able to avoid the extra barrier regardless of how the
primitives are implemented. Good.

> 
> I also did a BUILD_BUG_ON(), except the other way around - keeping it
> about the sign bit in the byte, just just verifying that yes,
> PG_waiters is that sign bit.

Yep. I still don't like the name, but now you've got PG_waiters
commented there at least. I'll have to live with it.

If we get more cases that want to use a similar function, we might make
a more general primitive for architectures that can optimize these multi
bit ops better than x86. Actually even x86 would prefer to do load ;
cmpxchg rather than bitop ; load for the cases where condition code can't
be used to check result.

> 
> > BTW. I just notice in your patch too that you didn't use "nr" in the
> > generic version.  
> 
> And I fixed that too.
> 
> Of course, I didn't test the changes (apart from building it). But
> I've been running the previous version since yesterday, so far no
> issues.

It looks good to me.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
