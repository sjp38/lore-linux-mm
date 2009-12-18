Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED6D6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:39:42 -0500 (EST)
Date: Fri, 18 Dec 2009 20:39:11 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Swap on flash SSDs
Message-ID: <20091218193911.GA6153@elte.hu>
References: <patchbomb.1261076403@v2.random>
 <alpine.DEB.2.00.0912171352330.4640@router.home>
 <4B2A8D83.30305@redhat.com>
 <alpine.DEB.2.00.0912171402550.4640@router.home>
 <20091218051210.GA417@elte.hu>
 <alpine.DEB.2.00.0912181227290.26947@router.home>
 <1261161677.27372.1629.camel@nimitz>
 <4B2BD55A.10404@sgi.com>
 <1261164487.27372.1735.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261164487.27372.1735.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Fri, 2009-12-18 at 11:17 -0800, Mike Travis wrote:
>
> > Interesting discussion about SSD's.  I was under the impression that with 
> > the finite number of write cycles to an SSD, that unnecessary writes were 
> > to be avoided?
> 
> I'm no expert, but my impression was that this was a problem with other 
> devices and with "bare" flash, and mostly when writing to the same place 
> over and over.
> 
> Modern, well-made flash SSDs and other flash devices have wear-leveling 
> built in so that they wear all of the flash cells evenly.  There's still a 
> discrete number of writes that they can handle over their life, but it 
> should be high enough that you don't notice.
> 
> http://en.wikipedia.org/wiki/Solid-state_drive

A quality SDD is supposed to wear off in continuous non-stop write traffic 
after its Mean Time Between Failures. (Obviously it will take a few years for 
drives to gather that kind of true physical track record - right now what we 
have is the claims of manufacturers and 1-2 years of a track record.)

And even when a cell does go bad and all the spares are gone, the failure mode 
is not catastrophic like with a hard disk, but that particular cell goes 
read-only and you can still recover the info and use the remaining cells.

Sidenote: i think we should make the Linux swap code resilient against write 
IO errors of that fashion and reallocate the swap entry to a free slot. Right 
now in mm/page_io.c's end_swap_bio_write() we do this:

                /*
                 * We failed to write the page out to swap-space.
                 * Re-dirty the page in order to avoid it being reclaimed.
                 * Also print a dire warning that things will go BAD (tm)
                 * very quickly.
                 *
                 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
                 */
                set_page_dirty(page);
                printk(KERN_ALERT "Write-error on swap-device (%u:%u:%Lu)\n",
                                imajor(bio->bi_bdev->bd_inode),
                                iminor(bio->bi_bdev->bd_inode),
                                (unsigned long long)bio->bi_sector);
                ClearPageReclaim(page);

We could be more intelligent than printing a scary error: we could clear that 
page from the swap map [permanently] and retry. It will still have a long-term 
failure mode when all swap pages are depleted - but that's still quite a slow 
failure mode and it is actionable via servicing.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
