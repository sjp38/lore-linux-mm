Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 48CCE6B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:38:02 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 22:38:01 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E184838C8047
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:37:56 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5K2bv8E316944
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:37:57 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5K2bu27032127
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 20:37:57 -0600
Date: Wed, 19 Jun 2013 21:37:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv13 3/4] zswap: add to mm/
Message-ID: <20130620023750.GA1194@cerebellum>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org

On Mon, Jun 17, 2013 at 02:20:05PM +0800, Bob Liu wrote:
> Hi Seth,
> 
> On Tue, Jun 4, 2013 at 4:33 AM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
> > zswap is a thin backend for frontswap that takes pages that are in the process
> > of being swapped out and attempts to compress them and store them in a
> > RAM-based memory pool.  This can result in a significant I/O reduction on the
> > swap device and, in the case where decompressing from RAM is faster than
> > reading from the swap device, can also improve workload performance.
> >
> > It also has support for evicting swap pages that are currently compressed in
> > zswap to the swap device on an LRU(ish) basis. This functionality makes zswap a
> > true cache in that, once the cache is full, the oldest pages can be moved out
> > of zswap to the swap device so newer pages can be compressed and stored in
> > zswap.
> >
> > This patch adds the zswap driver to mm/
> >
> 
> Do you have any more benchmark can share with me ? To figure out that
> we can benefit from zswap.
> 
> I found zswap will cause performance drop when using mmtests-0.10 to test it.
> The config file I'm using is: config-global-dhp__parallelio-memcachetest
> 
> The result is:
> (v3.10-rc4-2G-nozswap was without zswap but the performance is better.)
> 
>                                          v3.10-rc4                   v3.10-rc4
>                                      2G-zswap-base                  2G-nozswap
> Ops memcachetest-0M               604.00 (  0.00%)           1077.00 ( 78.31%)
> Ops memcachetest-198M             630.00 (  0.00%)           1007.00 ( 59.84%)
> Ops memcachetest-430M             609.00 (  0.00%)            939.00 ( 54.19%)
> Ops memcachetest-661M             604.00 (  0.00%)            845.00 ( 39.90%)
> Ops memcachetest-893M             591.00 (  0.00%)            839.00 ( 41.96%)
> Ops memcachetest-1125M            599.00 (  0.00%)            781.00 ( 30.38%)
> Ops memcachetest-1356M            588.00 (  0.00%)            771.00 ( 31.12%)
> Ops io-duration-0M                  0.00 (  0.00%)              1.00 (-99.00%)
> Ops io-duration-198M              177.00 (  0.00%)             21.00 ( 88.14%)
> Ops io-duration-430M              168.00 (  0.00%)             25.00 ( 85.12%)
> Ops io-duration-661M              214.00 (  0.00%)             30.00 ( 85.98%)
> Ops io-duration-893M              186.00 (  0.00%)             32.00 ( 82.80%)
> Ops io-duration-1125M             175.00 (  0.00%)             42.00 ( 76.00%)
> Ops io-duration-1356M             245.00 (  0.00%)             51.00 ( 79.18%)
> Ops swaptotal-0M               487760.00 (  0.00%)         459754.00 (  5.74%)
> Ops swaptotal-198M             563581.00 (  0.00%)         485194.00 ( 13.91%)
> Ops swaptotal-430M             579472.00 (  0.00%)         500817.00 ( 13.57%)
> Ops swaptotal-661M             568086.00 (  0.00%)         524209.00 (  7.72%)
> Ops swaptotal-893M             584405.00 (  0.00%)         509846.00 ( 12.76%)
> Ops swaptotal-1125M            572992.00 (  0.00%)         534115.00 (  6.78%)
> Ops swaptotal-1356M            573259.00 (  0.00%)         529814.00 (  7.58%)
> Ops swapin-0M                  231250.00 (  0.00%)         236069.00 ( -2.08%)
> Ops swapin-198M                312259.00 (  0.00%)         239149.00 ( 23.41%)
> Ops swapin-430M                327178.00 (  0.00%)         246803.00 ( 24.57%)
> Ops swapin-661M                319575.00 (  0.00%)         273644.00 ( 14.37%)
> Ops swapin-893M                328195.00 (  0.00%)         257327.00 ( 21.59%)
> Ops swapin-1125M               317345.00 (  0.00%)         271109.00 ( 14.57%)
> Ops swapin-1356M               312858.00 (  0.00%)         266050.00 ( 14.96%)
> Ops minorfaults-0M             592150.00 (  0.00%)         646076.00 ( -9.11%)
> Ops minorfaults-198M           637339.00 (  0.00%)         676441.00 ( -6.14%)
> Ops minorfaults-430M           626228.00 (  0.00%)         684715.00 ( -9.34%)
> Ops minorfaults-661M           625089.00 (  0.00%)         670639.00 ( -7.29%)
> Ops minorfaults-893M           612877.00 (  0.00%)         669723.00 ( -9.28%)
> Ops minorfaults-1125M          624800.00 (  0.00%)         667025.00 ( -6.76%)
> Ops minorfaults-1356M          618800.00 (  0.00%)         657600.00 ( -6.27%)
> Ops majorfaults-0M              67664.00 (  0.00%)          40060.00 ( 40.80%)
> Ops majorfaults-198M            72377.00 (  0.00%)          39517.00 ( 45.40%)
> Ops majorfaults-430M            71822.00 (  0.00%)          38895.00 ( 45.85%)
> Ops majorfaults-661M            70009.00 (  0.00%)          39625.00 ( 43.40%)
> Ops majorfaults-893M            74988.00 (  0.00%)          38073.00 ( 49.23%)
> Ops majorfaults-1125M           72458.00 (  0.00%)          38206.00 ( 47.27%)
> Ops majorfaults-1356M           70549.00 (  0.00%)          37430.00 ( 46.94%)

Just made a mmtests run of my own and got very different results:

parallelio-memcachetest
                                         v3.10-rc6                   v3.10-rc6
                                              base                       zswap
Ops memcachetest-0M              7815.00 (  0.00%)           7843.00 (  0.36%)
Ops memcachetest-596M           12116.00 (  0.00%)          12158.00 (  0.35%)
Ops memcachetest-1989M           2226.00 (  0.00%)           5314.00 (138.72%)
Ops memcachetest-3382M           1910.00 (  0.00%)           4427.00 (131.78%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-596M               18.00 (  0.00%)             12.00 ( 33.33%)
Ops io-duration-1989M              82.00 (  0.00%)             57.00 ( 30.49%)
Ops io-duration-3382M              91.00 (  0.00%)             94.00 ( -3.30%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-596M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-1989M            305182.00 (  0.00%)          91508.00 ( 70.02%)
Ops swaptotal-3382M            353389.00 (  0.00%)          74932.00 ( 78.80%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-596M                     0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-1989M               131071.00 (  0.00%)          45657.00 ( 65.17%)
Ops swapin-3382M               135003.00 (  0.00%)          37245.00 ( 72.41%)
Ops minorfaults-0M            1201113.00 (  0.00%)        1201229.00 ( -0.01%)
Ops minorfaults-596M          1218437.00 (  0.00%)        1218824.00 ( -0.03%)
Ops minorfaults-1989M         1260652.00 (  0.00%)        1270762.00 ( -0.80%)
Ops minorfaults-3382M         1251389.00 (  0.00%)        1248756.00 (  0.21%)
Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-596M               34.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-1989M           16561.00 (  0.00%)           7789.00 ( 52.97%)
Ops majorfaults-3382M           17031.00 (  0.00%)           6372.00 ( 62.59%)

Basically the results show that once swapping starts (which happens even in the
0MB case in your results which is puzzling), zswap reduces swapins by around
70% (and as a result swaptotal and majorfaults) and increases memcached
throughput by over 130% compared to the normal swapping case w/o zswap.

This test illustrates a great use case for zswap.  The test is really designed
to detect suboptimal page reclaim decisions.  Ideally the memcached pages would
never reach the end of the inactive LRU and be swapped out.  However, since
there is a lot of I/O going on, if a memcached page does get put on the
inactive list, it can quickly move to the end.  In this case, zswap catches the
page and memcached has a chance to fault it back in from the compressed cache
before actual swapping to disk occurs.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
