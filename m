Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3E4436B0083
	for <linux-mm@kvack.org>; Tue, 26 May 2009 23:17:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R3HhYH014308
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 27 May 2009 12:17:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E972245DD7A
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:17:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B462A45DD74
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:17:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B76421DB8016
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:17:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E02E1DB8013
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:17:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE and not VM_SHARED in hugetlbfs
In-Reply-To: <20090527004859.GB6189@csn.ul.ie>
References: <Pine.LNX.4.64.0905262056150.958@sister.anvils> <20090527004859.GB6189@csn.ul.ie>
Message-Id: <20090527111652.688B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 27 May 2009 12:17:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, ebmunson@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > > follow_hugetlb_page
> > > 	This is checking of the zero page can be shared or not. Crap,
> > > 	this one looks like it should have been converted to VM_MAYSHARE
> > > 	as well.
> >=20
> > Now, what makes you say that?
> >=20
> > I really am eager to understand, because I don't comprehend
> > that VM_SHARED at all.=20
>=20
> I think I understand it, but I keep changing my mind on whether
> VM_SHARED is sufficient or not.
>=20
> In this specific case, the zeropage must not be used by process A where
> it's possible that process B has populated it with data. when I said "Cra=
p"
> earlier, the scenario I imagined went something like;
>=20
> o Process A opens a hugetlbfs file read/write but does not map the file
> o Process B opens the same hugetlbfs read-only and maps it
>   MAP_SHARED. hugetlbfs allows mmaps to files that have not been ftruncat=
e()
>   so it can fault pages without SIGBUS
> o Process A writes the file - currently this is impossible as hugetlbfs
>   does not support write() but lets pretend it was possible
> o Process B calls mlock() which calls into follow_hugetlb_page().
>   VM_SHARED is not set because it's a read-only mapping and it returns
>   the wrong page.
>=20
> This last step is where I went wrong. As process 2 had no PTE for that
> location, it would have faulted the page as normal and gotten the correct
> page and never considered the zero page so VM_SHARED was ok after all.
>=20
> But this is sufficiently difficult that I'm worried that there is some ot=
her
> scenario where Process B uses the zero page when it shouldn't. Testing fo=
r
> VM_MAYSHARE would prevent the zero page being used incorrectly whether th=
e
> mapping is read-only or read-write but maybe that's too paranoid.
>=20
> Kosaki, can you comment on what impact (if any) testing for VM_MAYSHARE
> would have here with respect to core-dumping?

Thank you for very kindful explanation.

Perhaps, I don't understand this issue yet. Honestly I didn't think this
issue at my patch making time.

following is my current analysis. if I'm misunderstanding anythink, please
correct me.

hugepage mlocking call make_pages_present().
above case, follow_page_page() don't use ZERO_PAGE because vma don't have
VM_SHARED.
but that's ok. make_pages_present's intention is not get struct page,
it is to make page population. in this case, we need follow_hugetlb_page() =
call
hugetlb_fault(), I think.


In the other hand, when core-dump case

=2Etext segment: open(O_RDONLY) + mmap(MAP_SHARED)
=2Edata segment: open(O_RDONLY) + mmap(MAP_PRIVATE)

it mean .text can't use ZERO_PAGE. but I think no problem. In general
=2Etext is smaller than .data. It doesn't make so slowness.



> > I believe Kosaki-san's 4b2e38ad simply
> > copied it from Linus's 672ca28e to mm/memory.c.  But even back
> > when that change was made, I confessed to having lost the plot
> > on it: so far as I can see, putting a VM_SHARED test in there
> > just happened to prevent some VMware code going the wrong way,
> > but I don't see the actual justification for it.
> >=20
>=20
> Having no idea how vmware broke exactly, I'm not sure what exactly was
> fixed. Maybe by not checking VM_SHARED, it was possible that a caller of
> get_user_pages() would not see updates made by a parallel writer.
>=20
> > So, given that I don't understand it in the first place,
> > I can't really support changing that VM_SHARED to VM_MAYSHARE.
> >=20
>=20
> Lets see what Kosaki says. If he's happy with VM_SHARED, I'll leave it
> alone.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
