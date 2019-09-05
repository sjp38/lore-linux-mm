Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4E31C3A5A9
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:46:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7311E21881
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:46:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7311E21881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lge.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21BB6B0003; Wed,  4 Sep 2019 21:46:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB216B0005; Wed,  4 Sep 2019 21:46:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C98AE6B0006; Wed,  4 Sep 2019 21:46:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0247.hostedemail.com [216.40.44.247])
	by kanga.kvack.org (Postfix) with ESMTP id A22E16B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:46:29 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4CCD234A4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:46:29 +0000 (UTC)
X-FDA: 75899177298.03.brick11_8fccc9afe6b10
X-HE-Tag: brick11_8fccc9afe6b10
X-Filterd-Recvd-Size: 5223
Received: from lgeamrelo11.lge.com (lgeamrelo11.lge.com [156.147.23.51])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:46:27 +0000 (UTC)
Received: from unknown (HELO lgemrelse6q.lge.com) (156.147.1.121)
	by 156.147.23.51 with ESMTP; 5 Sep 2019 10:46:24 +0900
X-Original-SENDERIP: 156.147.1.121
X-Original-MAILFROM: sangwoo2.park@lge.com
Received: from unknown (HELO LGEARND18B2) (10.168.178.132)
	by 156.147.1.121 with ESMTP; 5 Sep 2019 10:46:24 +0900
X-Original-SENDERIP: 10.168.178.132
X-Original-MAILFROM: sangwoo2.park@lge.com
Date: Thu, 5 Sep 2019 10:46:24 +0900
From: Park Sangwoo <sangwoo2.park@lge.com>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, arunks@codeaurora.org, guro@fb.com,
	richard.weiyang@gmail.com, glider@google.com, jannh@google.com,
	dan.j.williams@intel.com, akpm@linux-foundation.org,
	alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com,
	gregkh@linuxfoundation.org, janne.huttunen@nokia.com,
	pasha.tatashin@soleen.com, vbabka@suse.cz, osalvador@suse.de,
	mgorman@techsingularity.net, khlebnikov@yandex-team.ru,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH] mm: Add nr_free_highatomimic to fix incorrect watermatk
 routine
Message-ID: <20190905014624.GA25551@LGEARND18B2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed 04-09-19 15:54:57, Park Sangwoo wrote:
> > On Tue 03-09-19 18:59:59, Park Sangwoo wrote:
> > > On Mon 02-09-19 13:34:54, Sangwoo=EF=BF=BD wrote:
> > >>> On Fri 30-08-19 18:25:53, Sangwoo wrote:
> > >>>> The highatomic migrate block can be increased to 1% of Total mem=
ory.
> > >>>> And, this is for only highorder ( > 0 order). So, this block siz=
e is
> > >>>> excepted during check watermark if allocation type isn't alloc_h=
arder.
> > >>>>
> > >>>> It has problem. The usage of highatomic is already calculated at
> > >>> NR_FREE_PAGES.
> > >>>>> So, if we except total block size of highatomic, it's twice min=
us size of
> > >>> allocated
> > >>>>> highatomic.
> > >>>>> It's cause allocation fail although free pages enough.
> > >>>>>
> > >>>>> We checked this by random test on my target(8GB RAM).
> > >>>>>
> > >>>>>  Binder:6218_2: page allocation failure: order:0, mode:0x14200c=
a
> > >>> (GFP_HIGHUSER_MOVABLE), nodemask=3D(null)
> > >>>>>  Binder:6218_2 cpuset=3Dbackground mems_allowed=3D0
> > >>>>
> > >>>> How come this order-0 sleepable allocation fails? The upstream k=
ernel
> > >>>> doesn't fail those allocations unless the process context is kil=
led by
> > >>>> the oom killer.
> > >>>=20
> > > >>> Most calltacks are zsmalloc, as shown below.
> > > >>
> > > >> What makes those allocations special so that they fail unlike an=
y other
> > > >> normal order-0 requests? Also do you see the same problem with t=
he
> > > >> current upstream kernel? Is it possible this is an Android speci=
fic
> > > >> issue?
> > > >
> > > > There is the other case of fail order-0 fail.
> > > > ----
> > > > hvdcp_opti: page allocation failure: order:0, mode:0x1004000(GFP_=
NOWAIT|__GFP_COMP), nodemask=3D(null)
> > >=20
> > > This is an atomic allocation and failing that one is not a problem
> > > usually. High atomic reservations might prevent GFP_NOWAIT allocati=
on
> > > from suceeding but I do not see that as a problem. This is the prim=
ary
> > > purpose of the reservation.=20
> >=20
> > Thanks, your answer helped me. However, my suggestion is not to modif=
y the use and management of the high atomic region,
> > but to calculate the exact free size of the highatomic so that fail d=
oes not occur for previously shared cases.
> >=20
> > In __zone_water_mark_ok(...) func, if it is not atomic allocation, hi=
gh atomic size is excluded.
> >=20
> > bool __zone_watermark_ok(struct zone *z,
> > ...
> > {
> >     ...
> >     if (likely(!alloc_harder)) {
> >         free_pages -=3D z->nr_reserved_highatomic;
> >     ...
> > }
> >=20
> > However, free_page excludes the size already allocated by hiahtomic.
> > If highatomic block is small(Under 4GB RAM), it could be no problem.
> > But, the larger the memory size, the greater the chance of problems.
> > (Becasue highatomic size can be increased up to 1% of memory)
>=20
> I still do not understand. NR_FREE_PAGES should include the amount of
> hhighatomic reserves, right. So reducing the free_pages for normal
> allocations just makes sense. Or what do I miss?

You are right. But z->nr_reserved_highatomic value is total size of
highatomic migrate type per zone.

nr_reserved_highatomic =3D (# of allocated of highatomic) + (# of free li=
st of highatomic).

And (# of allocated of hiagatomic) is already excluded at NR_FREE_PAGES.
So, if reducing nr_reserved_highatomic at NR_FREE_PAGES,
the (# of allocated of highatomic) is double reduced.

So I proposal that only (# of free list of highatomic) is reduced at NR_F=
REE_PAGE.

    if (likely(!alloc_harder)) {
-       free_pages -=3D z->nr_reserved_highatomic;
+       free_pages -=3D zone_page_state(z, NR_FREE_HIGHATOMIC_PAGES);
    } else {

>=20
> I am sorry but I find your reasoning really hard to follow.


