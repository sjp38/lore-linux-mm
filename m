Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA01798
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 20:02:01 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <199811261236.MAA14785@dax.scot.redhat.com> <Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> <199811271602.QAA00642@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 27 Nov 1998 20:58:38 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Fri, 27 Nov 1998 16:02:51 GMT"
Message-ID: <8767c0q55d.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> Looks like I have a handle on what's wrong with the 2.1.130 vm (in
> particular, its tendency to cache too much at the expense of
> swapping).
> 
> The real problem seems to be that shrink_mmap() can fail for two
> completely separate reasons.  First of all, we might fail to find a
> free page because all of the cache pages we find are recently
> referenced.  Secondly, we might fail to find a cache page at all.
> 
> The first case is an example of an overactive, large cache; the second
> is an example of a very small cache.  Currently, however, we treat
> these two cases pretty much the same.  In the second case, the correct
> reaction is to swap, and 2.1.130 is sufficiently good at swapping that
> we do so, heavily.  In the first case, high cache throughput, what we
> really _should_ be doing is to age the pages more quickly.  What we
> actually do is to swap.
> 
> On reflection, there is a completely natural way of distinguishing
> between these two cases, and that is to extend the size of the
> shrink_mmap() pass whenever we encounter many recently touched pages.
> This is easy to do: simply restricting the "count_min" accounting in
> shrink_mmap to avoid including salvageable but recently-touched pages
> will automatically cause us to age faster as we encounter more touched
> pages in the cache.
> 
> The patch below both makes sense from this perspective and seems to
> work, which is always a good sign!  Moreover, it is inherently
> self-tuning.  The more recently-accessed cache pages we encounter, the
> faster we will age the cache.
> 

Hi!

Yesterday, I was trying to understand the very same problem you're
speaking of. Sometimes kswapd decides to swapout lots of things,
sometimes not.

I applied your patch, but it didn't solve the problem.
To be honest, things are now even slightly worse. :(

Sample output of vmstat 1, while copying lots of stuff to /dev/null:

procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 1 0 23696  1656  3276 25128   0   0 6425   62  304  284  20  34  46
 2 0 1 23696  1444  3276 25344   0   0 9265    0  325  315  26  49  26
 2 0 1 23696  1384  3276 25408   0   0 10507    0  333  365  20  55  25
 3 0 1 23696  1408  3276 25388   0   0 10758    0  334  336  23  55  23
 2 0 0 23696  1672  3276 25132   0   0 9965    0  321  328  23  50  27
 3 0 1 23692  1408  3276 25384   4   0 9582    5  315  339  23  45  32
 2 0 1 23692  1400  3276 25392   0   0 9794    0  323  336  21  47  32
 4 0 1 23788  1436  3276 25460   0  96 9146   24  335  325  24  44  32
 2 0 1 23788  1152  3276 25736   0   0 9763    0  321  326  23  46  31
 1 1 1 24760  1356  3276 26504   4 976 1326  244  349  247  21  14  65
 2 0 1 25916   932  3276 28092  16 1192 1621  306  371  271  23   8  69
 1 1 1 26888   976  3276 29012  12 1056  993  264  335  289  19   9  72
 2 0 0 28208  1552  3276 29756   0 1320  750  330  380  276  10   6  84
 1 1 1 29224  1140  3276 31176   4 1040 1444  260  357  270  33  13  54
 2 0 1 30412  1200  3276 32296   8 1196 1131  304  405  274  20   8  73
 3 0 1 31412  1112  3276 33384   0 1000 1092  250  344  269  18  11  71
 2 0 1 32396   532  3276 34948   0 984 1570  246  359  242  19  11  70
 0 3 1 33504  1476  3276 35128   0 1128  197  282  314  279  15   4  81
 3 0 1 35080   648  3276 37520   0 1612 2443  403  299  325  24  13  63
 2 0 1 37116   736  3276 39468   4 2276 2077  575  314  352   8  14  78
 1 1 1 39368  1352  3276 41092   0 2300 1793  575  299  352  36  13  51
 1 1 1 41516   644  3276 43940   0 2356 3071  589  317  353  20  18  62
 1 0 2 43696  1220  3276 45544   4 2420 1848  605  321  354  20  12  68
 0 2 1 44980   532  3276 47512  16 1628 2306  407  318  328  22  14  64
 3 0 1 46512  1000  3276 48576  24 1832 1353  459  314  344  22  12  66
 2 1 0 46932  1648  3340 48284  88 888 3131  222  344  379  23  13  64
 2 1 0 46672  1656  3276 48068 108   0 6313    0  476  369  19  30  51
 3 1 0 46592 19812  3276 29840 156   0 4054    0  324  357  37  22  41


I'll do some more investigation this night.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		  So much time, and so little to do.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
