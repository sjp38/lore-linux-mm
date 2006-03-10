Received: by pproxy.gmail.com with SMTP id i49so331070pyi
        for <linux-mm@kvack.org>; Fri, 10 Mar 2006 05:38:08 -0800 (PST)
Message-ID: <aec7e5c30603100538v4942f9dbnfcc962f1a5bde190@mail.gmail.com>
Date: Fri, 10 Mar 2006 14:38:08 +0100
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <1141993351.8165.10.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <1141993351.8165.10.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/10/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Fri, 2006-03-10 at 12:44 +0900, Magnus Damm wrote:
> > Unmapped patches - Use two LRU:s per zone.
> >
> > These patches break out the per-zone LRU into two separate LRU:s - one for
> > mapped pages and one for unmapped pages. The patches also introduce guarantee
> > support, which allows the user to set how many percent of all pages per node
> > that should be kept in memory for mapped or unmapped pages. This guarantee
> > makes it possible to adjust the VM behaviour depending on the workload.
> >
> > Reasons behind the LRU separation:
> >
> > - Avoid unnecessary page scanning.
> >   The current VM implementation rotates mapped pages on the active list
> >   until the number of mapped pages are high enough to start unmap and page out.
> >   By using two LRU:s we can avoid this scanning and shrink/rotate unmapped
> >   pages only, not touching mapped pages until the threshold is reached.
> >
> > - Make it possible to adjust the VM behaviour.
> >   In some cases the user might want to guarantee that a certain amount of
> >   pages should be kept in memory, overriding the standard behaviour. Separating
> >   pages into mapped and unmapped LRU:s allows guarantee with low overhead.
> >
> > I've performed many tests on a Dual PIII machine while varying the amount of
> > RAM available. Kernel compiles on a 64MB configuration gets a small speedup,
> > but the impact on other configurations and workloads seems to be unaffected.
> >
> > Apply on top of 2.6.16-rc5.
> >
> > Comments?
>
> I'm not convinced of special casing mapped pages, nor of tunable knobs.

I think it makes sense to treat mapped pages separately because only
mapped pages require clearing of young-bits in pte:s. The logic for
unmapped pages could be driven entirely from mark_page_access(), no
scanning required. At least in my head that is. =)

Also, what might be an optimal page replacement policy for for
unmapped pages might be suboptimal for mapped pages.

> I've been working on implementing some page replacement algorithms that
> have neither.

Yeah, I know that. =) I think your ClockPRO work looks very promising.
I would really like to see some better page replacement policy than
LRU merged.

> Breaking the LRU in two like this breaks the page ordering, which makes
> it possible for pages to stay resident even though they have much less
> activity than pages that do get reclaimed.

Yes, true. But this happens already with a per-zone LRU. LRU pages
that happen to end up in the DMA zone will probably stay there a
longer time than pages in the normal zone. That does not mean it is
right to break the page ordering though, I'm just saying it happens
already and the oldest piece of data in the global system will not be
reclaimed first - instead there are priorities such as unmapped pages
will be reclaimed over mapped and so on. (I strongly feel that there
should be per-node LRU:s, but that's another story)

> I have a serious regression somewhere, but will post as soon as we've
> managed to track it down.
>
> If you're interrested, the work can be found here:
>   http://programming.kicks-ass.net/kernel-patches/page-replace/

I'm definitely interested, but I also believe that the page reclaim
code is hairy as hell, and that complicated changes to the "stable"
2.6-tree are hard to merge. So I see my work as a first step (or just
something that starts a discussion if no one is interested), and in
the end a page replacement policy implementation such as yours will be
accepted.

Thanks!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
