Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED006B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 12:57:47 -0500 (EST)
Date: Mon, 16 Nov 2009 17:57:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate
	fix V3
Message-ID: <20091116175739.GW29804@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <200911131004.25293.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200911131004.25293.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 10:04:21AM +0100, Frans Pop wrote:
> On Thursday 12 November 2009, Mel Gorman wrote:
> > Changelog since V2
> >   o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
> >     testing, it made latencies even worse as kswapd slept more on
> >     high-order congestion causing order-0 direct reclaims.
> >   o Added changes to how congestion_wait() works
> >   o Added a number of new patches altering the behaviour of reclaim
> 
> I have tested this series on top of .32-rc7. First impression is that it 
> does seem to improve my test case, but does not yet completely solve it.
> 
> My last gitk instance now loads more smoothly for most of the time it takes 
> to complete, but I still see a choke point where things freeze for a while 
> and where I get SKB allocation errors from my wireless.
> However, that choke point does seem to happen later and to be shorter than 
> without the patches.
> 

I haven't fully figured out why this makes a difference yet, but with
.32-rc7 and these patches, could you retry the test except beforehand do

cd /sys
for SYS in `find -name low_latency`; do
        echo 0 > $SYS
done

I believe the low_latency logic might be interfering with the number of
clean pages available for kswapd to reclaim.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
