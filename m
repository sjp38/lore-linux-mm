Date: Mon, 17 Dec 2007 11:24:57 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-Id: <20071217112457.d7940c63.randy.dunlap@oracle.com>
In-Reply-To: <20071216215519.GA7710@csn.ul.ie>
References: <47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
	<20071213142935.47ff19d9.akpm@linux-foundation.org>
	<20071215010940.GB28613@csn.ul.ie>
	<20071214180206.e0325503.akpm@linux-foundation.org>
	<20071216215519.GA7710@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, jens.axboe@oracle.com, liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sun, 16 Dec 2007 21:55:20 +0000 Mel Gorman wrote:

> > > Just using cp to read the file is enough to cause problems but I included
> > > a very basic program below that produces the BUG_ON checks. Is this a known
> > > issue or am I using the interface incorrectly?
> > 
> > I'd say you're using it correctly but you've found a hitherto unknown bug. 
> > On i386 highmem machines with CONFIG_HIGHPTE (at least) pte_offset_map()
> > takes kmap_atomic(), so pagemap_pte_range() can't do copy_to_user() as it
> > presently does.
> > 
> > Drat.
> > 
> > Still, that shouldn't really disrupt the testing which you're doing.  You
> > could disable CONFIG_HIGHPTE to shut it up.
> > 
> 
> Yes, that did the trick. Using pagemap, it was trivial to show that the
> 2.6.24-rc5-mm1 kernel was placing pages in reverse physical order like
> the following output shows
> 
> b:  32763 v:   753091 p:    65559 . 65558 contig: 1
> b:  32764 v:   753092 p:    65558 . 65557 contig: 1
> b:  32765 v:   753093 p:    65557 . 65556 contig: 1
> b:  32766 v:   753094 p:    65556 . 65555 contig: 1
> b:  32767 v:   753095 p:    65555 . 65555 contig: 1
> 
> p: is the PFN of the page v: is the page offset within an anonymous
> mapping and b: is the number of non-contiguous blocks in the anonymous
> mapping. With the patch applied, it looks more like;
> 
> b:   1232 v:   752964 p:    58944 ................ 87328 contig: 15
> b:   1233 v:   752980 p:    87328 ................ 91200 contig: 15
> b:   1234 v:   752996 p:    91200 ................ 40272 contig: 15
> b:   1235 v:   753012 p:    40272 ................ 85664 contig: 15
> b:   1236 v:   753028 p:    85664 ................ 87312 contig: 15
> 
> so mappings are using contiguous pages again. This was the final test
> program I used in case it's of any interest.
> 
> Thanks
> 
> /*
>  * showcontiguous.c
>  *
>  * Use the /proc/pid/pagemap interface to give an indication of how contiguous
>  * physical memory is in an anonymous virtual memory mapping
>  */

Matt,
Did you ever make your python pagemap scripts available?
If not, would you?

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
