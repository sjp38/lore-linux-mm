Received: by wproxy.gmail.com with SMTP id 37so1246942wra
        for <linux-mm@kvack.org>; Sun, 12 Mar 2006 19:05:39 -0800 (PST)
Message-ID: <aec7e5c30603121905n675a6be4t34b2b98342065d8c@mail.gmail.com>
Date: Mon, 13 Mar 2006 12:05:39 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <1142111295.2928.14.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <1141993351.8165.10.camel@twins>
	 <aec7e5c30603100538v4942f9dbnfcc962f1a5bde190@mail.gmail.com>
	 <1142111295.2928.14.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/12/06, Peter Zijlstra <peter@programming.kicks-ass.net> wrote:
> On Fri, 2006-03-10 at 14:38 +0100, Magnus Damm wrote:
> > On 3/10/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> > > Breaking the LRU in two like this breaks the page ordering, which makes
> > > it possible for pages to stay resident even though they have much less
> > > activity than pages that do get reclaimed.
> >
> > Yes, true. But this happens already with a per-zone LRU. LRU pages
> > that happen to end up in the DMA zone will probably stay there a
> > longer time than pages in the normal zone. That does not mean it is
> > right to break the page ordering though, I'm just saying it happens
> > already and the oldest piece of data in the global system will not be
> > reclaimed first - instead there are priorities such as unmapped pages
> > will be reclaimed over mapped and so on. (I strongly feel that there
> > should be per-node LRU:s, but that's another story)
>
> If reclaim works right* there is equal pressure on each zone
> (proportional to their size) and hence each page will have an equal life
> time expectancy.
>
> (*) this is of course not possible for all workloads, however
> balance_pgdat and the page allocator take pains to make it as true as
> possible.

In shrink_zone(), there is +1 logic that adds at least one to
nr_scan_active/nr_scan_inactive, and resets them to zero when they
have reached sc->swap_cluster_max (32 or higher in some cases).

So nr_scan_active/nr_scan_inactive will in most cases be 16
(SWAP_CLUSTER_MAX / 2), regardless of the size of the zone. So, a
total of 256 calls to shrink_zone() on a zone with 4096 pages will
likely scan through 100% of the pages on both LRU lists, while 256
calls to shrink_zone() on a zone with say 8096 pages will result in
around 50% of the pages on the lists are scanned through.

Maybe not entirely true, but the bottom line is that the +1 logic will
scan though smaller zones faster than large ones.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
