Received: by zproxy.gmail.com with SMTP id 13so977650nzn
        for <linux-mm@kvack.org>; Sat, 11 Mar 2006 04:14:14 -0800 (PST)
Message-ID: <aec7e5c30603110414m1690ecd4qf2dcd545858cc8a5@mail.gmail.com>
Date: Sat, 11 Mar 2006 21:14:14 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 01/03] Unmapped: Implement two LRU:s
In-Reply-To: <Pine.LNX.4.64.0603101113210.28805@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <20060310034417.8340.49483.sendpatchset@cherry.local>
	 <Pine.LNX.4.64.0603101113210.28805@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On 3/11/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Fri, 10 Mar 2006, Magnus Damm wrote:
>
> > Use separate LRU:s for mapped and unmapped pages.
> >
> > This patch creates two instances of "struct lru" per zone, both protected by
> > zone->lru_lock. A new bit in page->flags named PG_mapped is used to determine
> > which LRU the page belongs to. The rmap code is changed to move pages to the
> > mapped LRU, while the vmscan code moves pages back to the unmapped LRU when
> > needed. Pages moved to the mapped LRU are added to the inactive list, while
> > pages moved back to the unmapped LRU are added to the active list.
>
> The swapper moves pages to the unmapped list? So the mapped LRU
> lists contains unmapped pages? That would get rid of the benefit that I
> saw from this scheme. Pretty inconsistent.

The first (non released) versions of these patches modified rmap.c to
move the pages between the LRU:s both during adding and removing
rmap:s, so the mapped LRU would in that case keep mapped pages only.
This did however introduce more overhead, because pages only mapped by
a single process would bounce between the LRU:s when a such process
starts or terminates.

The split active list implementation by Nick Piggin did however only
move pages between the active lists during vmscan (if I understood the
patch correctly), which is something that I have not tried yet.

I think it would be interesting with 3 active lists, one for unmapped
pages, one for mapped file-backed pages and one for mapped anonymous
pages. And then let the vmscan code move pages between the lists.

Thank you for the comments!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
