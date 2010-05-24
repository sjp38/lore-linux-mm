Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50B776B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 03:33:07 -0400 (EDT)
Date: Mon, 24 May 2010 17:32:59 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 3/3] mm: Swap checksum
Message-ID: <20100524073259.GW2516@laptop>
References: <4BF81D87.6010506@cesarb.net>
 <1274551731-4534-3-git-send-email-cesarb@cesarb.net>
 <4BF94792.5030405@redhat.com>
 <4BF97AC2.1040505@cesarb.net>
 <4BFA1F92.2080802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BFA1F92.2080802@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 09:41:22AM +0300, Avi Kivity wrote:
> On 05/23/2010 09:58 PM, Cesar Eduardo Barros wrote:
> >Em 23-05-2010 12:19, Avi Kivity escreveu:
> >>On 64-bit, we may be able to store the checksum in the pte, if the swap
> >>device is small enough.
> >
> >Which pte?
> 
> All of them.
> 
> >Correct me if I am wrong, but I do not think all pages written to
> >the swap have exactly one pte pointing to them. And I have not
> >looked at the shmem.c code yet, but does it even use ptes?
> 
> Well, the ptes need the swap address written into them, so they are
> already found and updated somehow.  All that's needed is to update
> the value written to also include the checksum.
> 
> >It might be possible (find all ptes and write the 32-bit checksum
> >to them, do something else for shmem, have two different code
> >paths for small/large swapfiles), but I do not know if the memory
> >savings are worth the extra complexity (especially the need for
> >two separate code paths).
> 
> Certainly not at first, but later it may be worthwhile.
> 
> >
> >>If we take the trouble to touch the page, we may as well compare it
> >>against zero, and if so drop it instead of swapping it out.
> >
> >The problem with this is that the page is touched deep inside the
> >crc32c code, which might even be using hardware instructions
> >(crc32c-intel). So we would need to read it two times to compare
> >against zero.
> 
> The second read is very cheap since the page is already in cache.
> Also, we fail early when any word is nonzero, so usually the compare
> exits quickly.

For a page being written back from pagecache to disk, or for a
page being swapped out, the contents are likely cache cold and
likely not to be used in future either. Therefore a crc routine
for that would do well to minimise cache pollution.


> >One possibility could be to compare the full page against zero
> >only if its crc is a specific value (the crc32c of a page full of
> >zeros). This would not be too slow (we would be wasting time only
> >when we have a very high probability of saving much more time),
> >and not need to touch the crc32c code at all. I would only have to
> >look at how this messes up the state tracking (i.e. how to make it
> >track the fact that, instead of getting written out, this is now a
> >zeroed page).
> 
> Instead of returning a swap pte to be written to the page tables,
> return a zeroed pte.

A pte_none pte, to be precise.

I wonder, though. If we no longer trust block devices to give the
correct data back, should we provide a meta block device to do error
detection? No production filesystem on Linux has checksums (well, ext4
has a few). Of the ones that add checksumming, I'd say most will not do
data checksumming (and for direct IO it is not done).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
