Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B69BC6B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 19:20:28 -0400 (EDT)
Date: Tue, 9 Jun 2009 01:30:06 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Probablem with dropping caches
Message-ID: <20090608233006.GA2420@cmpxchg.org>
References: <20090604062122.GA8126@untroubled.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604062122.GA8126@untroubled.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[adding Ccs]

On Thu, Jun 04, 2009 at 12:21:22AM -0600, Bruce Guenter wrote:
> Hello.
> 
> I am having a problem with a system that appears to be spontaneously
> dropping large parts of its caches.  The work load on this system is
> primarily I/O bound (it's a mailbox server), and as such the loss of
> cache memory is causing severe performance degradation.
> 
> For example, here is some output from vmstat 1:
> 
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  1  1      0  87164 683212 1069748    0    0   544   164  856  730  3  2 91  4
>  0  1      0  81124 689100 1069508    0    0  5880   104 1070  834  2  1 74 23
>  0  1      0  89956 691588 1057408    0    0  5288     0 1163  915  0  2 72 25
>  0  1      0 138020 690652 1012444    0    0  5724     0 1136  831  2  0 75 23
>  0  0      0 243384 690460 906500    0    0  4716     0 1282  844  0  2 61 36
>  0  1      0 294704 690152 854232    0    0  1108   428 1123 1093  2  2 81 15
>  0  0      0 285984 690380 854504    0    0   252     0  721  671  3  1 92  3
>  0  1      0 426844 690780 722408    0    0  3096  1748 1197  846  1  2 84 13
>  0  1      0 579684 691232 568344    0    0  4228   156 1300 1083  2  2 69 27
>  1  1      0 676312 691832 467244    0    0  5256     0 1072  741  0  2 75 23
> 
> As far as I can tell from df and similar reporting, there are not
> hundreds of MB of files being deleted, which would have similar
> behavior.  It is not swapping, nor is memory actually leaking (since
> free memory + cache is nearly constant).  All of the active programs run
> with small memory ulimits and as such are not consuming and then
> releasing hundreds of MB of memory.
> 
> There are also intervals where the system is reading several MB per
> second but the caches do not grow significantly:
> 
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  0 35      0 960396 749544  62416    0    0  7396     0 1424 1154  2  2  0 96
>  1 34      0 963868 750536  62252    0    0  8596   208 1695 1463  4  3  0 93
>  0 38      0 967452 752800  62980    0    0  7176    20 1378  972  4  1  0 95
>  0 38      0 968100 751308  61400    0    0  7260   180 1423 1109  3  2  0 95
>  2 42      0 966252 751540  61872    0    0  8196     0 1404 1328  1  1  0 97
>  0 43      0 955440 751956  60520    0    0  8692     0 1846 1925  5  3  0 92
>  2 49      0 943644 752836  61412    0    0  9324   200 1783 1582  5  3  0 92
>  1 39      0 959368 751892  62104    0    0  7836    64 1874 1855  9  5  0 86
> 
> This system has 2GB RAM and 4 72GB drives in a 3Ware RAID10 array.  The
> active filesystem is ext4 with the following mount options:
> 
> 	noatime,nodiratime,data=journal
> 
> The data=journal option comes from benchmarking I did a while back that
> indicated it was best for sync+unlink heavy work loads such as this one
> has.  I have remounted with data=ordered but that did not solve the
> problem.
> 
> The kernel (as of now) is 2.6.29.4 compiled with gcc 3.4.6 on Gentoo.
> 
> I also have another system, which is similarly configured but is using
> the ext3 filesystem.  It does not exhibit this behavior which leads me
> to suspect some difference between ext3 and ext4 is causing the problem.
> I however have no other evidence to point a finger at ext4, and am at a
> loss as to what else to investigate.
> 
> Has anybody else seen this behavior before?  What other details can I
> investigate to figure out what is causing this problem?  What other information
> would be useful to diagnose this?
> 
> Thank you.
> 
> -- 
> Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
