Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3P13R7w026803
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 21:03:27 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3P13Rrd191466
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 19:03:27 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3P13Qwp010265
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 19:03:26 -0600
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <462EA46E.8000307@shadowen.org>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>
	 <20070424132740.e4bdf391.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>
	 <20070424134325.f71460af.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
	 <20070424141826.952d2d32.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0704241429240.13904@schroedinger.engr.sgi.com>
	 <20070424143635.cdff71de.akpm@linux-foundation.org>
	 <462E7AB6.8000502@shadowen.org>  <462E9DDC.40700@shadowen.org>
	 <1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
	 <462EA46E.8000307@shadowen.org>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 18:03:51 -0700
Message-Id: <1177463032.1281.15.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-25 at 01:44 +0100, Andy Whitcroft wrote:
> Badari Pulavarty wrote:
> > On Wed, 2007-04-25 at 01:16 +0100, Andy Whitcroft wrote:
> >> Andy Whitcroft wrote:
> >>> Andrew Morton wrote:
> >>>> On Tue, 24 Apr 2007 14:30:16 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> >>>>
> >>>>> On Tue, 24 Apr 2007, Andrew Morton wrote:
> >>>>>
> >>>>>>> Could we get a .config?
> >>>>>> test.kernel.org configs are subtly hidden on the front page.  Go to
> >>>>>> test.kernel.org, click on the "amd64" or "numaq" links in the title row
> >>>>>> there.
> >>>>>>
> >>>>>> The offending machine is elm3b6.
> >>>>> My x86_64 box boots fine with the indicated .config.
> >>>> So do both of mine.
> >>>>
> >>>>> Hardware related?
> >>>> Well it's AMD64, presumably real NUMA.  Maybe try numa=fake=4?
> >>> Yep real NUMA box.  Will try and get hold of the box to test.
> >>>
> >>> -apw
> >> git bisect points to:
> >>
> >>     quicklist-support-for-x86_64
> >>
> >> Reverting just this patch sorts this problem on the x86_64.
> > 
> > Hmm.. I narrowed it further down to ..
> > 
> > quicklists-for-page-table-pages-avoid-useless-virt_to_page-
> > conversion.patch
> > 
> > Andy, can you try backing out only this and enable QUICK_LIST
> > on your machine ?
> 
> Yep confirmed that reverting that one is enough to fix this machine.
> 
> -apw


Here is the patch to fix it (against -mm) ? 
Works on my machine :)

Thanks,
Badari

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
 include/linux/quicklist.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.21-rc7/include/linux/quicklist.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/quicklist.h	2007-04-24 19:10:09.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/quicklist.h	2007-04-24 19:10:57.000000000 -0700
@@ -61,7 +61,8 @@ static inline void __quicklist_free(int 
 	if (unlikely(nid != numa_node_id())) {
 		if (dtor)
 			dtor(p);
-		free_hot_page(page);
+		if (put_page_testzero(page))
+			free_hot_page(page);
 		return;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
