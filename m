Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E51D6B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 04:33:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A8YL7I027891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Jun 2009 17:34:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E53745DD72
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 17:34:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3122945DD79
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 17:34:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D9111DB801A
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 17:34:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF590E08005
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 17:34:20 +0900 (JST)
Date: Wed, 10 Jun 2009 17:32:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-Id: <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090610081132.GA27519@localhost>
References: <20090609190128.GA1785@cmpxchg.org>
	<20090609193702.GA2017@cmpxchg.org>
	<20090610050342.GA8867@localhost>
	<20090610074508.GA1960@cmpxchg.org>
	<20090610081132.GA27519@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jun 2009 16:11:32 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Wed, Jun 10, 2009 at 03:45:08PM +0800, Johannes Weiner wrote:
> > Hi Fengguang,
> > 
> > On Wed, Jun 10, 2009 at 01:03:42PM +0800, Wu Fengguang wrote:
> > > On Wed, Jun 10, 2009 at 03:37:02AM +0800, Johannes Weiner wrote:
> > > > On Tue, Jun 09, 2009 at 09:01:28PM +0200, Johannes Weiner wrote:
> > > > > [resend with lists cc'd, sorry]
> > > > 
> > > > [and fixed Hugh's email.  crap]
> > > > 
> > > > > Hi,
> > > > > 
> > > > > here is a new iteration of the virtual swap readahead.  Per Hugh's
> > > > > suggestion, I moved the pte collecting to the callsite and thus out
> > > > > ouf swap code.  Unfortunately, I had to bound page_cluster due to an
> > > > > array of that many swap entries on the stack, but I think it is better
> > > > > to limit the cluster size to a sane maximum than using dynamic
> > > > > allocation for this purpose.
> > > 
> > > Hi Johannes,
> > > 
> > > When stress testing your patch, I found it triggered many OOM kills.
> > > Around the time of last OOMs, the memory usage is:
> > > 
> > >              total       used       free     shared    buffers     cached
> > > Mem:           474        468          5          0          0        239
> > > -/+ buffers/cache:        229        244
> > > Swap:         1023        221        802
> > 
> > Wow, that really confused me for a second as we shouldn't read more
> > pages ahead than without the patch, probably even less under stress.
> 
> Yup - swap readahead is much more challenging than sequential readahead,
> in that it must be accurate enough given some really obscure patterns.
> 
> > So the problem has to be a runaway reading.  And indeed, severe
> > stupidity here:
> > 
> > +       window = cluster << PAGE_SHIFT;
> > +       min = addr & ~(window - 1);
> > +       max = min + cluster;
> > +       /*
> > +        * To keep the locking/highpte mapping simple, stay
> > +        * within the PTE range of one PMD entry.
> > +        */
> > +       limit = addr & PMD_MASK;
> > +       if (limit > min)
> > +               min = limit;
> > +       limit = pmd_addr_end(addr, max);
> > +       if (limit < max)
> > +               max = limit;
> > +       limit = max - min;
> > 
> > The mistake is at the initial calculation of max.  It should be
> > 
> > 	max = min + window;
> > 
> > The resulting problem is that min could get bigger than max when
> > cluster is bigger than PMD_SHIFT.  Did you use page_cluster == 5?
> 
> No I use the default 3.
> 
> btw, the mistake reflects bad named variables. How about rename
>         cluster => pages
>         window  => bytes
> ?
> 
> > The initial min is aligned to a value below the PMD boundary and max
> > based on it with a too small offset, staying below the PMD boundary as
> > well.  When min is rounded up, this becomes a bit large:
> > 
> > 	limit = max - min;
> > 
> > So if my brain is already functioning, fixing the initial max should
> > be enough because either
> > 
> > 	o window is smaller than PMD_SIZE, than we won't round down
> > 	below a PMD boundary in the first place or
> > 
> > 	o window is bigger than PMD_SIZE, than we can round down below
> > 	a PMD boundary but adding window to that is garuanteed to
> > 	cross the boundary again
> > 
> > and thus max is always bigger than min.
> > 
> > Fengguang, does this make sense?  If so, the patch below should fix
> > it.
> 
> Too bad, a quick test of the below patch freezes the box..
> 

+	window = cluster << PAGE_SHIFT;
+	min = addr & ~(window - 1);
+	max = min + cluster;

max = min + window; # this is fixed. then,

+	/*
+	 * To keep the locking/highpte mapping simple, stay
+	 * within the PTE range of one PMD entry.
+	 */
+	limit = addr & PMD_MASK;
+	if (limit > min)
+		min = limit;
+	limit = pmd_addr_end(addr, max);
+	if (limit < max)
+		max = limit;
+	limit = max - min;

limit = (max - min) >> PAGE_SHIFT;  

+	ptep = pte_offset_map_lock(mm, pmd, min, &ptl);
+	for (i = nr = 0; i < limit; i++)
+		if (is_swap_pte(ptep[i]))
+			entries[nr++] = pte_to_swp_entry(ptep[i]);
+	pte_unmap_unlock(ptep, ptl);

Cheer!,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
