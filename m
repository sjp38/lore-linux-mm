Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7A4B86B0069
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:08:41 -0400 (EDT)
Received: by ied10 with SMTP id 10so22963083ied.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 14:08:40 -0700 (PDT)
Date: Wed, 3 Oct 2012 14:07:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
In-Reply-To: <506AACAC.2010609@openvz.org>
Message-ID: <alpine.LSU.2.00.1210031337320.1415@eggly.anvils>
References: <50460CED.6060006@redhat.com> <20120906110836.22423.17638.stgit@zurg> <alpine.LSU.2.00.1210011418270.2940@eggly.anvils> <506AACAC.2010609@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2 Oct 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > If I boot with mem=900M (and 1G swap: either on hard disk sda, or
> > on Vertex II SSD sdb), and mmap anonymous 1000M (either MAP_PRIVATE,
> > or MAP_SHARED for a shmem object), and either cycle sequentially round
> > that making 5M touches (spaced a page apart), or make 5M random touches,
> > then here are the times in centisecs that I see (but it's only elapsed
> > that I've been worrying about).
> > 
> > 3.6-rc7 swapping to hard disk:
> >      124 user    6154 system   73921 elapsed -rc7 sda seq
> >      102 user    8862 system  895392 elapsed -rc7 sda random
> >      130 user    6628 system   73601 elapsed -rc7 sda shmem seq
> >      194 user    8610 system 1058375 elapsed -rc7 sda shmem random
> > 
> > 3.6-rc7 swapping to SSD:
> >      116 user    5898 system   24634 elapsed -rc7 sdb seq
> >       96 user    8166 system   43014 elapsed -rc7 sdb random
> >      110 user    6410 system   24959 elapsed -rc7 sdb shmem seq
> >      208 user    8024 system   45349 elapsed -rc7 sdb shmem random
> > 
> > 3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page),
> > HDD:
> >      116 user    6258 system   76210 elapsed shli sda seq
> >       80 user    7716 system  831243 elapsed shli sda random
> >      128 user    6640 system   73176 elapsed shli sda shmem seq
> >      212 user    8522 system 1053486 elapsed shli sda shmem random
> > 
> > 3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page),
> > SSD:
> >      126 user    5734 system   24198 elapsed shli sdb seq
> >       90 user    7356 system   26146 elapsed shli sdb random
> >      128 user    6396 system   24932 elapsed shli sdb shmem seq
> >      192 user    8006 system   45215 elapsed shli sdb shmem random
> > 
> > 3.6-rc7 + my patch, swapping to hard disk:
> >      126 user    6252 system   75611 elapsed hugh sda seq
> >       70 user    8310 system  871569 elapsed hugh sda random
> >      130 user    6790 system   73855 elapsed hugh sda shmem seq
> >      148 user    7734 system  827935 elapsed hugh sda shmem random
> > 
> > 3.6-rc7 + my patch, swapping to SSD:
> >      116 user    5996 system   24673 elapsed hugh sdb seq
> >       76 user    7568 system   28075 elapsed hugh sdb random
> >      132 user    6468 system   25052 elapsed hugh sdb shmem seq
> >      166 user    7220 system   28249 elapsed hugh sdb shmem random
> > 
> 
> Hmm, It would be nice to gather numbers without swapin readahead at all, just
> to see the the worst possible case for sequential read and the best for
> random.

Right, and also interesting to see what happens if we raise page_cluster
(more of an option than it was, with your or my patch scaling it down).
Run on the same machine under the same conditions:

3.6-rc7 + my patch, swapping to hard disk with page_cluster 0 (no readahead):
    136 user   34038 system  121542 elapsed hugh cluster0 sda seq
    102 user    7928 system  841680 elapsed hugh cluster0 sda random
    130 user   34770 system  118322 elapsed hugh cluster0 sda shmem seq
    160 user    7362 system  756489 elapsed hugh cluster0 sda shmem random

3.6-rc7 + my patch, swapping to SSD with page_cluster 0 (no readahead):
    138 user   32230 system   70018 elapsed hugh cluster0 sdb seq
     88 user    7296 system   25901 elapsed hugh cluster0 sdb random
    154 user   33150 system   69678 elapsed hugh cluster0 sdb shmem seq
    166 user    6936 system   24332 elapsed hugh cluster0 sdb shmem random

3.6-rc7 + my patch, swapping to hard disk with page_cluster 4 (default + 1):
    144 user    4262 system   77950 elapsed hugh cluster4 sda seq
     74 user    8268 system  863871 elapsed hugh cluster4 sda random
    140 user    4880 system   73534 elapsed hugh cluster4 sda shmem seq
    160 user    7788 system  834804 elapsed hugh cluster4 sda shmem random

3.6-rc7 + my patch, swapping to SSD with page_cluster 4 (default + 1):
    124 user    4242 system   21125 elapsed hugh cluster4 sdb seq
     72 user    7680 system   28686 elapsed hugh cluster4 sdb random
    122 user    4622 system   21387 elapsed hugh cluster4 sdb shmem seq
    172 user    7238 system   28226 elapsed hugh cluster4 sdb shmem random

I was at first surprised to see random significantly faster than sequential
on SSD with readahead off, thinking they ought to come out the same.  But
no, that's a warning on the limitations of the test: with an mmap of 1000M
on a machine with mem=900M, the page-by-page sequential is never going to
rehit cache, whereas the random has a good chance of finding in memory.

Which I presume also accounts for the lower user times throughout
for random - but then why not the same for shmem random?

I did start off measuring on the laptop with SSD, mmap 1000M mem=500M;
but once I transferred to the desktop, I rediscovered just how slow
swapping to hard disk can be, couldn't wait days, so made mem=900M.

> I'll run some tests too, especially I want to see how it works for less
> synthetic workloads.

Thank you, that would be valuable.  I expect there to be certain midway
tests on which Shaohao's patch would show up as significantly faster,
where his per-vma approach would beat the global approach; then the
global to improve with growing contention between processes.  But I
didn't devise any such test, and hoped Shaohua might have one.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
