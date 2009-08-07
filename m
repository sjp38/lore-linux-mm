Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4789A6B005C
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 04:09:07 -0400 (EDT)
Subject: Re: SysV swapped shared memory calculated incorrectly
From: Niko Jokinen <ext-niko.k.jokinen@nokia.com>
Reply-To: ext-niko.k.jokinen@nokia.com
In-Reply-To: <Pine.LNX.4.64.0908051853120.7907@sister.anvils>
References: <1249398452.3905.268.camel@niko-laptop>
	 <Pine.LNX.4.64.0908051853120.7907@sister.anvils>
Content-Type: text/plain
Date: Fri, 07 Aug 2009 11:08:57 +0300
Message-Id: <1249632537.3905.296.camel@niko-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ext Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-08-05 at 20:21 +0200, ext Hugh Dickins wrote:
> On Tue, 4 Aug 2009, Niko Jokinen wrote:
> > 
> > Tested on 2.6.28 and 2.6.31-rc4
> > 
> > SysV swapped shared memory is not calculated correctly
> > in /proc/<pid>/smaps and also by parsing /proc/<pid>/pagemap.
> 
> smaps and pagemap are (reasonably) counting swap entries in the
> page tables they're looking at.
> 
> But SysV shared memory is dealt with just like mmap of a tmpfs
> file: we don't put swap entries into the page tables for that,
> just as we don't put sector numbers into the page tables when
> unmapping a diskfile page; the use of swapspace by that
> filesystem is a lower-level detail not exposed at this level.
> 
> Well, we have had to expose "swap backed" near this level in
> recent releases.  So it would be possible to recognize the
> swap-backed shared vmas, and insert pte_file ptes instead
> of pte_none ptes when unmapping pages from them, and adjust
> the code which only expects those in nonlinear vmas, and
> adjust smaps and pagemap to behave accordingly.
> 
> But I admit to having no appetite for any such change, cluttering
> the main code just to touch up the anyhow rough picture that smaps
> and pagemap are painting.  I much prefer to say that these areas are
> backed by files, and it's a lower-level detail that those files are
> backed by swap.
> 

This issue is originally from our performance team and they cannot
accurately measure per application memory usage if shared memory is
used. 
I guess workaround is to assume that following is true for shared memory
segments: Size-Rss = Swapped. (Since the issue below is fixed).

> > Rss value decreases also when swap is disabled, so this is where I am
> > lost as how shared memory is supposed to behave.
> 
> Did you check that detail on both 2.6.28 and 2.6.31-rc4?  I think
> 2.6.28 was unmapping the ptes from the pagetables, before the lower
> level found that it had no swap to write them to; whereas a current
> kernel didn't unmap them at all in my case.
> 

You are correct, tested on 2.6.31-rc5 and rss does not decrease anymore.

Br,
Niko Jokinen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
