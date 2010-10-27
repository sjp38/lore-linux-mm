Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E31248D0002
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 19:22:39 -0400 (EDT)
Received: by iwn38 with SMTP id 38so538372iwn.14
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 16:22:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Oct 2010 08:22:38 +0900
Message-ID: <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Nazarewicz <m.nazarewicz@samsung.com>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2010 at 7:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hi, here is version 2.
>
> I only did small test and it seems to work (but I think there will be bug=
...)
> I post this now just because I'll be out of office 10/31-11/15 with ksumm=
it and
> a private trip.
>
> Any comments are welcome but please see the interface is enough for use c=
ases or
> not. =A0For example) If MAX_ORDER alignment is too bad, I need to rewrite=
 almost
> all code.

First of all, thanks for the endless your effort to embedded system.
It's time for statkeholders to review this.
Cced some guys. Maybe many people of them have to attend KS.
So I hope SAMSUNG guys review this.

Maybe they can't test this since ARM doesn't support movable zone now.
(I will look into this).
As Kame said, please, review this patch whether this patch have enough
interface and meet
your requirement.
I think this can't meet _all_ of your requirements(ex, latency and
making sure getting big contiguous memory) but I believe it can meet
NOT CRITICAL many cases, I guess.

>
> Now interface is:
>
>
> struct page *__alloc_contig_pages(unsigned long base, unsigned long end,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_pages, in=
t align_order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int node, gfp_t gfpflag, n=
odemask_t *mask)
>
> =A0* @base: the lowest pfn which caller wants.
> =A0* @end: =A0the highest pfn which caller wants.
> =A0* @nr_pages: the length of a chunk of pages to be allocated.
> =A0* @align_order: alignment of start address of returned chunk in order.
> =A0* =A0 Returned' page's order will be aligned to (1 << align_order).If =
smaller
> =A0* =A0 than MAX_ORDER, it's raised to MAX_ORDER.
> =A0* @node: allocate near memory to the node, If -1, current node is used=
