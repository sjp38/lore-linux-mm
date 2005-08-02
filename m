Message-ID: <42EECC1F.9000902@yahoo.com.au>
Date: Tue, 02 Aug 2005 11:27:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

>
>Instead, I'd suggest changing the logic for "lookup_write". Make it 
>require that the page table entry is _dirty_ (not writable), and then 
>remove the line that says:
>
>	lookup_write = write && !force;
>
>and you're now done. A successful mm fault for write _should_ always have 
>marked the PTE dirty (and yes, part of testing this would be to verify 
>that this is true - but since architectures that don't have HW dirty 
>bits depend on this anyway, I'm pretty sure it _is_ true).
>
>Ie something like the below (which is totally untested, obviously, but I 
>think conceptually is a lot more correct, and obviously a lot simpler).
>
>

Surely this introduces integrity problems when `force` is not set?
Security holes? Perhaps not, but I wouldn't guarantee it.

However: I like your idea. And getting rid of the lookup_write logic is
a good thing.

I don't much like that it changes the semantics of follow_page for
write on a readonly pte, and that is where your problem is introduced.
I think to go down this route you'd at least need a follow_page check
that is distinct from 'write'. 'writeable', maybe.

Then, having a 'writeable' flag lets you neatly "comment" your idea of
what might constitute a writeable pte, as opposed to the current code
which basically looks like black magic to a reader, and gives no indication
of how it satisfies the get_user_pages requirements.

A minor issue: I don't much like the proliferation of __follow_page flags
either. Why not make __follow_page take a bitmask, and be used directly by
get_user_pages, which would also allow removal of the 'write' argument from
follow_page.

I would cook you some patches, but I'm not in front of the source tree.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
