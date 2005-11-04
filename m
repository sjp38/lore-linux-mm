Date: Fri, 4 Nov 2005 09:38:33 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051104093833.0db634f0.akpm@osdl.org>
In-Reply-To: <325200000.1131117596@[10.10.2.4]>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
	<20051103205202.4417acf4.akpm@osdl.org>
	<20051103213538.7f037b3a.pj@sgi.com>
	<20051103214807.68a3063c.akpm@osdl.org>
	<20051103224239.7a9aee29.pj@sgi.com>
	<20051103231019.488127a6.akpm@osdl.org>
	<325200000.1131117596@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: pj@sgi.com, bron@bronze.corp.sgi.com, pbadari@gmail.com, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, mingo@elte.hu, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@mbligh.org> wrote:
>
> > Seriously, it does appear that doing it per-task is adequate for your
> > needs, and it is certainly more general.
> > 
> > 
> > 
> > I cannot understand why you decided to count only the number of
> > direct-reclaim events, via a "digitally filtered, constant time based,
> > event frequency meter".
> > 
> > a) It loses information.  If we were to export the number of pages
> >    reclaimed from the mm, filtering can be done in userspace.
> > 
> > b) It omits reclaim performed by kswapd and by other tasks (ok, it's
> >    very cpuset-specific).
> > 
> > c) It only counts synchronous try_to_free_pages() attempts.  What if an
> >    attempt only freed pagecache, or didbn't manage to free anything?
> > 
> > d) It doesn't notice if kswapd is swapping the heck out of your
> >    not-allocating-any-memory-now process.
> > 
> > 
> > I think all the above can be addressed by exporting per-task (actually
> > per-mm) reclaim info.  (I haven't put much though into what info that
> > should be - page reclaim attempts, mmapped reclaims, swapcache reclaims,
> > etc)
> 
> I've been looking at similar things. When we page out / free something from 
> a shared library that 10 tasks have mapped, who does that count against
> for pressure?

Count pte unmappings and minor faults and account them against the
mm_struct, I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
