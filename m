Date: Fri, 14 Jan 2005 22:36:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050114213207.GK8709@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0501142217590.3109-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Kanoj Sarcar <kanojsarcar@yahoo.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2005, Andrea Arcangeli wrote:
> > 
> > You could have asked even before breaking mainline ;).

Sorry (but check your mailbox for 3rd October -
I'd hoped the patch would be more provocative than a question!)

> > The rmb serializes the read of truncate_count with the read of
> > inode->i_size.

Yes, that's a clearer way of putting it, thank you.

> > The rmb is definitely required, and I would leave it an
> > atomic op to be sure gcc doesn't outsmart unmap_mapping_range_list (gcc
> > can see the internals of unmap_mapping_range_list). I mean just in case.
> > We must increase that piece of ram before we truncate the ptes and after
> > we updated the i_size.

I don't follow your argument for atomic there - "just in case"?
I still see its atomic ops as serving no point (and it was
tiresome to extend their use in the patches that followed).

> > Infact it seems to me right now that we miss a smp_wmb() right before
> > atomic_inc(&mapping->truncate_count): the spin_lock has inclusive
> > semantics on ia64, and in turn the i_size update could happen after the
> > atomic_inc without a smp_wmb().

That's interesting, and I'm glad my screwup has borne some good fruit.
And an smp_rmb() in one place makes more sense to me if there's an
smp_wmb() in the complementary place (though I've a suspicion that
"making sense to me" is not the prime consideration here ;)

> > So please backout the buggy changes and add the smp_wmb() to fix this
> > ia64 altix race.

Will do, though not today.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
