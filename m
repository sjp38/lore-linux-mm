Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92B136B0038
	for <linux-mm@kvack.org>; Sun, 10 May 2015 06:34:49 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so86714938pab.3
        for <linux-mm@kvack.org>; Sun, 10 May 2015 03:34:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id t17si13826535pdi.227.2015.05.10.03.34.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 May 2015 03:34:48 -0700 (PDT)
Date: Sun, 10 May 2015 13:34:29 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150510103429.GA17628@esperanza>
References: <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
 <20150429043536.GB11486@blaptop>
 <20150429091248.GD1694@esperanza>
 <20150430082531.GD21771@blaptop>
 <20150430145055.GB17640@esperanza>
 <20150504031722.GA2768@blaptop>
 <20150504094938.GB4197@esperanza>
 <20150504105459.GA19384@blaptop>
 <20150508095604.GO31732@esperanza>
 <20150509151031.GA24141@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150509151031.GA24141@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux-foundation.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Sun, May 10, 2015 at 12:12:38AM +0900, Minchan Kim wrote:
> On Fri, May 08, 2015 at 12:56:04PM +0300, Vladimir Davydov wrote:
> > On Mon, May 04, 2015 at 07:54:59PM +0900, Minchan Kim wrote:
> > > So, I guess once below compiler optimization happens in __page_set_anon_rmap,
> > > it could be corrupt in page_refernced.
> > > 
> > > __page_set_anon_rmap:
> > >         page->mapping = (struct address_space *) anon_vma;
> > >         page->mapping = (struct address_space *)((void *)page_mapping + PAGE_MAPPING_ANON);
> > > 
> > > Because page_referenced checks it with PageAnon which has no memory barrier.
> > > So if above compiler optimization happens, page_referenced can pass the anon
> > > page in rmap_walk_file, not ramp_walk_anon. It's my theory. :)
> > 
> > FWIW
> > 
> > If such splits were possible, we would have bugs all over the kernel
> > IMO. An example is do_wp_page() vs shrink_active_list(). In do_wp_page()
> > we can call page_move_anon_rmap(), which sets page->mapping in exactly
> > the same fashion as above-mentioned __page_set_anon_rmap():
> > 
> > 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > 	page->mapping = (struct address_space *) anon_vma;
> > 
> > The page in question may be on an LRU list, because nowhere in
> > do_wp_page() we remove it from the list, neither do we take any LRU
> > related locks. The page is locked, that's true, but shrink_active_list()
> > calls page_referenced() on an unlocked page, so according to your logic
> > they can race with the latter receiving a page with page->mapping equal
> > to anon_vma w/o PAGE_MAPPING_ANON bit set:
> > 
> > CPU0				CPU1
> > ----				----
> > do_wp_page			shrink_active_list
> >  lock_page			 page_referenced
> > 				  PageAnon->yes, so skip trylock_page
> >  page_move_anon_rmap
> >   page->mapping = anon_vma
> > 				  rmap_walk
> > 				   PageAnon->no
> > 				   rmap_walk_file
> > 				    BUG
> >   page->mapping = page->mapping+PAGE_MAPPING_ANON
> > 
> > However, this does not happen.
> 
> Good spot.
> 
> However, it doesn't mean it's right so you are okay to rely on it.
> Normally, store tearing is not common and such race would be hard to hit
> but I want to call it as BUG.

But then we should call atomic64_set/atomic_long_set a big fat bug,
because it does not use ACCESS_ONCE/volatile stuff on its argument, so
it is prone to write tearing and therefore it is not atomic at all.

> 
> Rik wrote the code and commented out.
> 
>         "Protected against the rmap code by the page lock"
> 
> But unfortunately, page_referenced in shrink_active_list doesn't hold
> a page lock so isn't it a bug? Rik?
> 
> Please, read store tearing section in Documentation/memory-barrier.txt.
> If you get confused due to aligned memory, please read this link.
> 
>         https://lkml.org/lkml/2014/7/16/262

I've read it. It describes tearing of

	p = 0x00010002;

to

	*(u16 *)&p = 0x2;
	*((u16 *)&p+1) = 0x1

to avoid computation of 0x00010002 by using two 16-bit immediate-store.

AFAIU that isn't nearly the case in __page_set_anon_rmap:

	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
	page->mapping = (struct address_space *) anon_vma;

The compiler doesn't know the value of anon_vma so there is absolutely
no benefit in tearing it - it would only result in two vs one store. I
admit we cannot rule out that some mad compiler can do that, but IMO
that would be a compiler bug, which would result in the kernel tearing
apart.

> 
> Other quote from Paul in https://lkml.org/lkml/2015/5/1/229
> "
> ..
> If the thing read/written does fit into a machine word and if the location
> read/written is properly aligned, I would be quite surprised if either
> READ_ONCE() or WRITE_ONCE() resulted in any sort of tearing.
> "
> 
> I parsed it as that "even store tearing can happen machine word at
> alinged address and that's why WRITE_ONCE is there to prevent it"

That's a sort of reading between the lines, I can't see it's written here.

> 
> If you want to claim GCC doesn't do it, please read below links
> 
>         https://lkml.org/lkml/2015/4/16/527
>         http://yarchive.net/comp/linux/ACCESS_ONCE.html
> 
> Quote from Linus
> "
> The thing is, you can't _prove_ that the compiler won't do it, especially
> if you end up changing the code later (without thinking about the fact
> that you're loading things without locking).
> 
> So the rule is: if you access unlocked values, you use ACCESS_ONCE(). You
> don't say "but it can't matter". Because you simply don't know.
> "

You took this citation from the context, which has nothing to do with
read/store tearing. It's about the value consistency in some statement.
E.g. in the following statement

	int i = x;
	if (i > y)
		y = i;

we do need ACCESS_ONCE around x, because the compiler is free to fetch
its value twice, in the comparison and the assignment. But it's not
about read/write tearing.

> 
> Yeb, I might be paranoid but my point is it might work now on most of
> arch but it seem to be buggy/fragile/subtle because we couldn't prove
> all arch/compiler don't make any trouble. So, intead of adding more
> logics based on fragile, please use right lock model. If lock becomes
> big trouble by overhead, let's fix it(for instance, use WRITE_ONCE for
> update-side and READ_ONCE  for read-side) if I don't miss something.

IMO, locking would be an overkill. READ_ONCE is OK, because it has no
performance implications, but I would prefer to be convinced that it is
100% necessary before adding it just in case.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
