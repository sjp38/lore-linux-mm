Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 331A96B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 01:22:44 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9D5Mciw016787
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 22:22:38 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by hpaq13.eem.corp.google.com with ESMTP id p9D5JQKD027624
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 22:22:36 -0700
Received: by pzd13 with SMTP id 13so3243977pzd.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 22:22:36 -0700 (PDT)
Date: Wed, 12 Oct 2011 22:22:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <4E966564.5030902@redhat.com>
Message-ID: <alpine.DEB.2.00.1110122210030.7572@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com>
 <alpine.DEB.2.00.1110111343070.29761@chino.kir.corp.google.com> <4E959292.9060301@redhat.com> <alpine.DEB.2.00.1110121316590.7646@chino.kir.corp.google.com> <4E966564.5030902@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 13 Oct 2011, Rik van Riel wrote:

> > I suggested a patch from BFS that would raise kswapd to the same priority
> > of the task that triggered it (not completely up to rt, but the highest
> > possible in that case) and I'm waiting to hear if that helps for Satoru's
> > test case before looking at alternatives.  We could also extend the patch
> > to raise the priority of an already running kswapd if a higher priority
> > task calls into the page allocator's slowpath.
> 
> This has the distinct benefit of making kswapd most active right
> at the same time the application is most active, which returns
> us to your first objection to the extra free kbytes patch (apps
> will suffer from kswapd cpu use).
> 

Not necessarily, it only raises the priority of kswapd to be the same as 
the application, although it'll never raise it to be realtime, that kicks 
it in the page allocator's slowpath.  If the application has a nice level 
of 0, it's a no-op.  That's very different from extra_free_kbytes which 
causes kswapd to do extra work regardless of the priority of the 
application that is allocating memory.  Raising the priority of kswapd for 
rt threads makes sense if they are going to deplete all memory, it makes 
no sense to allow a rt thread to allocate tons of memory and not even give 
kswapd a chance to compete.

> Furthermore, I am not sure that giving kswapd more CPU time is
> going to help, because kswapd could be stuck on some lock, held
> by a lower priority (or sleeping) context.
> 
> I agree that the BFS patch would be worth a try, and would be
> very pleasantly surprised if it worked, but I am not very
> optimistic about it...
> 

It may require a combination of Con's patch, increasing the priority of 
kswapd if a higher priority task kicks it in the page allocator, and an 
extra bonus on top of the high watermark if it was triggered by a 
rt-thread -- similar to ALLOC_HARDER but instead reclaiming to 
(high * 1.25).

If we're going to go with extra_free_kbytes, then I'd like to see the test 
case posted with a mathematical formula to show me what I should tune it 
to be depending on my machine's memory capacity and amount of free RAM 
when started (and I can use mem= to test it for various capacities).  For 
this to be merged, there should be a clear expression that shows what the 
ideal setting of the tunable should be rather than asking for trial-and-
error to see what works and what doesn't.  If such an expression doesn't 
exist, then it's clear that the necessary setting will vary significantly 
as the implementation changes from kernel to kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
