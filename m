Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B87C46B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 14:21:25 -0400 (EDT)
Date: Wed, 5 Aug 2009 19:21:22 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: SysV swapped shared memory calculated incorrectly
In-Reply-To: <1249398452.3905.268.camel@niko-laptop>
Message-ID: <Pine.LNX.4.64.0908051853120.7907@sister.anvils>
References: <1249398452.3905.268.camel@niko-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Niko Jokinen <ext-niko.k.jokinen@nokia.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 4 Aug 2009, Niko Jokinen wrote:
> 
> Tested on 2.6.28 and 2.6.31-rc4
> 
> SysV swapped shared memory is not calculated correctly
> in /proc/<pid>/smaps and also by parsing /proc/<pid>/pagemap.

smaps and pagemap are (reasonably) counting swap entries in the
page tables they're looking at.

But SysV shared memory is dealt with just like mmap of a tmpfs
file: we don't put swap entries into the page tables for that,
just as we don't put sector numbers into the page tables when
unmapping a diskfile page; the use of swapspace by that
filesystem is a lower-level detail not exposed at this level.

Well, we have had to expose "swap backed" near this level in
recent releases.  So it would be possible to recognize the
swap-backed shared vmas, and insert pte_file ptes instead
of pte_none ptes when unmapping pages from them, and adjust
the code which only expects those in nonlinear vmas, and
adjust smaps and pagemap to behave accordingly.

But I admit to having no appetite for any such change, cluttering
the main code just to touch up the anyhow rough picture that smaps
and pagemap are painting.  I much prefer to say that these areas are
backed by files, and it's a lower-level detail that those files are
backed by swap.

> Rss value decreases also when swap is disabled, so this is where I am
> lost as how shared memory is supposed to behave.

Did you check that detail on both 2.6.28 and 2.6.31-rc4?  I think
2.6.28 was unmapping the ptes from the pagetables, before the lower
level found that it had no swap to write them to; whereas a current
kernel didn't unmap them at all in my case.

> 
> I have test program which makes 32MB shared memory segment and then I
> use 'stress -m 1 --vm-bytes 120M', --vm-bytes is increased until rss
> size decreases in smaps. Swap value never increases in smaps.
> 
> On the other hand shmctl(0, SHM_INFO, ...) does show shared memory in
> swap because shm.c shm_get_stat() uses inodes to get values.

SHM-specific tools know they're dealing with tmpfs and perhaps swap,
and so can present a more tailored version of the info.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
