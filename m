Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH]
Date: Wed, 15 Aug 2001 20:26:48 +0200
References: <Pine.LNX.4.33.0108151036350.2407-100000@penguin.transmeta.com>
In-Reply-To: <Pine.LNX.4.33.0108151036350.2407-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010815182028Z16364-1234+100@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>
Cc: alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 15, 2001 07:40 pm, Linus Torvalds wrote:
> On Wed, 15 Aug 2001, Ben LaHaise wrote:
> >
> > The patch below enables vma merging for a couple of additional cases with
> > anon mmaps as glibc has a habit of passing in differing flags for some
> > cases (ie memory remapping, extending specific malloc blocks, etc).  This
> > is to help Mozilla which ends up with thousands of vma's that are
> > sequential and anonymous, but unmerged.  There may still be issues with
> > mremap, but I think this is a step in the right direction.
> 
> Good catch.
> 
> However, I really think we should just mask those bits out in general:
> we've already used them up by this time, and they make no sense at all to
> maintain in the VMA either, so it looks like it would be a cleaner (and
> shorter) patch to just do
> 
> 	/* get rid of mmap-time-only flags */
> 	vm_flags &= ~(MAP_NORESERVE | MAP_FIXED);
> 
> just after we've checked the MAP_NORESERVE bit, and just before we check
> whether we can expand an old mapping. That way the (now meaningless) bits
> don't end up as noise in the vma->vm_flags, AND we guarantee that merging
> doesn't merge two fields that have different "noise" in their vm_flags.

Another one in that category is BH_New which we use only immediately after
*_get_block, afterwards it dangles meaninglessly.  Not a bug, but
misleading.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
