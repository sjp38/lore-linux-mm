Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 611846B020C
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 18:45:51 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o34MjnJV004184
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 5 Apr 2010 07:45:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2645545DE4E
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:45:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 01FFE45DE4C
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:45:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D6178E08001
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:45:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 81ACAE08002
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:45:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
In-Reply-To: <h2rd6200be21004021759x4ae83403i4daa206d47b7d523@mail.gmail.com>
References: <20100402094805.GA12886@csn.ul.ie> <h2rd6200be21004021759x4ae83403i4daa206d47b7d523@mail.gmail.com>
Message-Id: <20100405010442.7E08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon,  5 Apr 2010 07:45:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Arve =?ISO-8859-1?Q?Hj=F8nnev=E5g?= <arve@android.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, TAO HU <tghk48@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi

> >> "mm: Add min_free_order_shift tunable." seems makes zero sense. I don'=
t think this patch
> >> need to be merge.
> >
> > It makes a marginal amount of sense. Basically what it does is allowing
> > high-order allocations to go much further below their watermarks than i=
s
> > currently allowed. If the platform in question is doing a lot of high-o=
rder
> > allocations, this patch could be seen to "fix" the problem but you woul=
dn't
> > touch mainline with it with a barge pole. It would be more stable to fi=
x
> > the drivers to not use high order allocations or use a mempool.
>=20
> The high order allocation that caused problems was the first level
> page table for each process. Each time a new process started the
> kernel would empty the entire page cache to create contiguous free
> memory. With the reserved pageblock mostly full (fixed by the second
> patch) this contiguous memory would then almost immediately get used
> for low order allocations, so the same problem starts again when the
> next process starts. I agree this patch does not fix the problem, but
> it does improve things when the problem hits. I have not seen a device
> in this situation with the second patch applied, but I did not remove
> the first patch in case the reserved pageblock fills up.

I would like to merge the second patch at first. If the same problem still =
occur, please
post bug report. (and please cc arm folks if it is arm pagetable related)


> > It is inconceivable this patch is related to the problem though.
> >
> >> but "mm: Check if any page in a pageblock is reserved before marking i=
t MIGRATE_RESERVE"
> >> treat strange hardware correctly, I think. If Mel ack this, I hope mer=
ge it.
> >> Mel, Can we hear your opinion?
> >>
> >
> > This patch is interesting and I am surprised it is required. Is it real=
ly the
> > case that page blocks near the start of a zone are dominated with PageR=
eserved
> > pages but the first one happen to be free? I guess it's conceivable on =
ARM
> > where memmap can be freed at boot time.
>=20
> I think this happens by default on arm. The kernel starts at offset
> 0x8000 to leave room for boot parameters, and in recent kernel
> versions (>~2.6.26-29) this memory is freed.
>=20
> >
> > There is a theoritical problem with the patch but it is easily resolved.
> > A PFN walker like this must call pfn_valid_within() before calling
> > pfn_to_page(). If they do not, it's possible to get complete garbage
> > for the page and result in a bad dereference. In this particular case,
> > it would be a kernel oops rather than memory corruption though.
> >
> > If that was fixed, I'd see no problem with Acking the patch.
> >
>=20
> I can fix this if you want the patch in mainline. I was not sure it
> was acceptable since will slow down boot on all systems, even where it
> is not needed.

bootup code is not fast path. then, small slowdown is ok, I think.
So, I'm looking for your new version patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
