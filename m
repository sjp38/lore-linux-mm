Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D6316B0026
	for <linux-mm@kvack.org>; Mon,  2 May 2011 09:50:09 -0400 (EDT)
Date: Mon, 2 May 2011 21:49:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110502134953.GA12281@localhost>
References: <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
 <20110502132958.GA9690@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110502132958.GA9690@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Mon, May 02, 2011 at 09:29:58PM +0800, Wu Fengguang wrote:
> > > +                     if (preferred_zone &&
> > > +                         zone_watermark_ok_safe(preferred_zone, sc->order,
> > > +                                     high_wmark_pages(preferred_zone),
> > > +                                     zone_idx(preferred_zone), 0))
> > > +                             goto out;
> > > +             }
> > 
> > As I said, I think direct reclaim path sould be fast if possbile and
> > it should not a function of min_free_kbytes.
> 
> It can be made not a function of min_free_kbytes by simply changing
> high_wmark_pages() to low_wmark_pages() in the above chunk, since
> direct reclaim is triggered when ALLOC_WMARK_LOW cannot be satisfied,
> ie. it just dropped below low_wmark_pages().
> 
> But still, it costs 62ms reclaim latency (base kernel is 29ms).

I got new findings: the CPU schedule delays are much larger than
reclaim delays. It does make the "direct reclaim until low watermark
OK" latency less a problem :)

1000 dd test case:
                RECLAIM delay   CPU delay       nr_alloc_fail   CAL (last CPU)
base kernel     29ms            244ms           14586           218440
patched         62ms            215ms           5004            325

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
