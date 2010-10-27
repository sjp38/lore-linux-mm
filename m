Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 807006B009B
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 15:14:14 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o9RJEBrT008935
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 12:14:12 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq1.eem.corp.google.com with ESMTP id o9RJDupf017528
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 12:14:10 -0700
Received: by qyk10 with SMTP id 10so1147747qyk.5
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 12:14:06 -0700 (PDT)
Date: Wed, 27 Oct 2010 12:13:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
In-Reply-To: <AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com> <4CC869F5.2070405@redhat.com> <AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com> <AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="380388936-1837877089-1288206844=:5039"
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--380388936-1837877089-1288206844=:5039
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 27 Oct 2010, Nick Piggin wrote:
> On Wed, Oct 27, 2010 at 12:22 PM, Nick Piggin <npiggin@gmail.com> wrote:
> > On Wed, Oct 27, 2010 at 12:05 PM, Rik van Riel <riel@redhat.com> wrote:
> >> On 10/27/2010 01:21 PM, Ying Han wrote:
> >>>
> >>> kswapd's use case of hardware PTE accessed bit is to approximate page=
 LRU.
> >>> =A0The
> >>> ActiveLRU demotion to InactiveLRU are not base on accessed bit, while=
 it
> >>> is only
> >>> used to promote when a page is on inactive LRU list. =A0All of the st=
ate
> >>> transitions
> >>> are triggered by memory pressure and thus has weak relationship with
> >>> respect to
> >>> time. =A0In addition, hardware already transparently flush tlb whenev=
er CPU
> >>> context
> >>> switch processes and given limited hardware TLB resource, the time pe=
riod
> >>> in
> >>> which a page is accessed but not yet propagated to struct page is ver=
y
> >>> small
> >>> in practice. With the nature of approximation, kernel really don't ne=
ed to
> >>> flush TLB
> >>> for changing PTE's access bit. =A0This commit removes the flush opera=
tion
> >>> from it.

It should at least add a comment there in page_referenced_one(), that
a TLB flush ought to be done, but is now judged not worth the effort.

(I'd expect architectures to differ on whether it's worth the effort.)

> >>>
> >>> Signed-off-by: Ying Han<yinghan@google.com>
> >>> Singed-off-by: Ken Chen<kenchen@google.com>

Hey, Ken, switch off those curling tongs :)

> However, it's a scary change -- higher chance of reclaiming a TLB covered=
 page.

Yes, I was often tempted to make such a change in the past;
but ran away when it appeared to be in danger of losing the pte
referenced bit of precisely the most intensively referenced pages.

Ying's point (about what the pte referenced bit is being used for in our
current implementation) is interesting, and might have tipped the balance;
but that's not clear to me - and the flush is only done when mm is on CPU.

>=20
> I had a vague memory of this problem biting someone when this flush wasn'=
t
> actually done properly... maybe powerpc.
>=20
> But anyway, same solution could be possible, by flushing every N pages sc=
anned.

Yes, batching seems safer.

Hugh
--380388936-1837877089-1288206844=:5039--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
