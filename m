Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l16DQLQZ6418648
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 12:26:22 -0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l161SEDj231080
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 12:28:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l161OiRQ020529
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 12:24:44 +1100
Date: Tue, 6 Feb 2007 12:24:42 +1100
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: Hugepages_Rsvd goes huge in 2.6.20-rc7
Message-ID: <20070206012442.GD20123@localhost.localdomain>
References: <20070206001903.GP7953@us.ibm.com> <20070206002534.GQ7953@us.ibm.com> <20070206005547.GA5071@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206005547.GA5071@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 05, 2007 at 04:55:47PM -0800, Nishanth Aravamudan wrote:
> On 05.02.2007 [16:25:34 -0800], Nishanth Aravamudan wrote:
> > Sorry, I botched Hugh's e-mail address, please make sure to reply to the
> > correct one.
> > 
> > Thanks,
> > Nish
> > 
> > On 05.02.2007 [16:19:04 -0800], Nishanth Aravamudan wrote:
> > > Hi all,
> > > 
> > > So, here's the current state of the hugepages portion of my
> > > /proc/meminfo (x86_64, 2.6.20-rc7, will test with 2.6.20 shortly,
> > > but AFAICS, there haven't been many changes to hugepage code between
> > > the two):
> 
> Reproduced on 2.6.20, and I think I've got a means to make it more
> easily reproducible (at least on x86_64).
> 
> Please note, I found that when HugePages_Rsvd goes very large, I can
> make it return to 0 by running `make func`, but killing it before it
> gets to the sharing tests.  Rsvd returns to 0 in this case.

Um.. yeah, that may just be because it's reserving some pages, which
rolls the rsvd count back to 0.

> So, here's my means of reproducing it (as root, from the libhugetlbfs
> root directory [1]):
> 
> # make sure everything is clean, hugepages wise
> root@arkanoid# rm -rf /mnt/hugetlbfs/*
> # if /proc/meminfo is already screwed up, run `make func` and kill it
> # around when you see the mprotect testcase run, that seems to always
> # work -- I'll try to be more scientific on this in a bit, to see which
> # test causes the value to return to sanity
> 
> # run the linkshare testcase once, probably will die right away
> root@arkanoid# HUGETLB_VERBOSE=99 HUGETLB_ELFMAP=y HUGETLB_SHARE=1 LD_LIBRARY_PATH=./obj64 ./tests/obj64/xBDT.linkshare
> # you should see the testcase be killed, something like
> # "FAIL    Child 1 killed by signal: Killed"
> root@arkanoid# cat /proc/meminfo
> # and a large value in meminfo now
> 
> Seems to happen every time I do this :) Note, part of this
> reproducibility stems from a small modification to the details I gave
> before. Before doing the posix_fadvise() call, I now do an fsync() on
> the file-descriptor. Without the fsync(), it may take one or two
> invocations before the test fails, but it still will in my experience so
> far.
> 
> Also note, that I'm not trying to defend the way I'm approaching this
> problem in libhugetlbfs (I'm very open to alternatives) -- but
> regardless of what I do there, I don't think Rsvd should be
> 18446744073709551615 ...

Oh, certainly not.  Clearly we're managing to decrement it more times
than we're incrementing it somehow.  I'd check the codepath for the
madvise() thing, we may not be handling that properly.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
