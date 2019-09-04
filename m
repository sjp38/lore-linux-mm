Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FAKE_REPLY_C,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4434C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1BCE22CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:55:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1BCE22CED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lge.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64DAD6B0006; Wed,  4 Sep 2019 02:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FEF26B0007; Wed,  4 Sep 2019 02:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 540736B0008; Wed,  4 Sep 2019 02:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4596B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:55:01 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C048FA2BF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:55:00 +0000 (UTC)
X-FDA: 75896325960.25.chair85_e839c1b67d27
X-HE-Tag: chair85_e839c1b67d27
X-Filterd-Recvd-Size: 4571
Received: from lgeamrelo11.lge.com (lgeamrelo11.lge.com [156.147.23.51])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:54:59 +0000 (UTC)
Received: from unknown (HELO lgeamrelo04.lge.com) (156.147.1.127)
	by 156.147.23.51 with ESMTP; 4 Sep 2019 15:54:57 +0900
X-Original-SENDERIP: 156.147.1.127
X-Original-MAILFROM: sangwoo2.park@lge.com
Received: from unknown (HELO LGEARND18B2) (10.168.178.132)
	by 156.147.1.127 with ESMTP; 4 Sep 2019 15:54:57 +0900
X-Original-SENDERIP: 10.168.178.132
X-Original-MAILFROM: sangwoo2.park@lge.com
Date: Wed, 4 Sep 2019 15:54:57 +0900
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
Subject: Re: Re: Re: Re: [PATCH] mm: Add nr_free_highatomimic to fix
 incorrect watermatk routine
Message-ID: <20190904065457.GA19826@LGEARND18B2>
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

> On Tue 03-09-19 18:59:59, Park Sangwoo wrote:
> > On Mon 02-09-19 13:34:54, Sangwoo=EF=BF=BD wrote:
> >>> On Fri 30-08-19 18:25:53, Sangwoo wrote:
> >>>> The highatomic migrate block can be increased to 1% of Total memor=
y.
> >>>> And, this is for only highorder ( > 0 order). So, this block size =
is
> >>>> excepted during check watermark if allocation type isn't alloc_har=
der.
> >>>>
> >>>> It has problem. The usage of highatomic is already calculated at
> >>> NR_FREE_PAGES.
> >>>>> So, if we except total block size of highatomic, it's twice minus=
 size of
> >>> allocated
> >>>>> highatomic.
> >>>>> It's cause allocation fail although free pages enough.
> >>>>>
> >>>>> We checked this by random test on my target(8GB RAM).
> >>>>>
> >>>>>  Binder:6218_2: page allocation failure: order:0, mode:0x14200ca
> >>> (GFP_HIGHUSER_MOVABLE), nodemask=3D(null)
> >>>>>  Binder:6218_2 cpuset=3Dbackground mems_allowed=3D0
> >>>>
> >>>> How come this order-0 sleepable allocation fails? The upstream ker=
nel
> >>>> doesn't fail those allocations unless the process context is kille=
d by
> >>>> the oom killer.
> >>>=20
> >>> Most calltacks are zsmalloc, as shown below.
> >>
> >> What makes those allocations special so that they fail unlike any ot=
her
> >> normal order-0 requests? Also do you see the same problem with the
> >> current upstream kernel? Is it possible this is an Android specific
> >> issue?
> >
> > There is the other case of fail order-0 fail.
> > ----
> > hvdcp_opti: page allocation failure: order:0, mode:0x1004000(GFP_NOWA=
IT|__GFP_COMP), nodemask=3D(null)
>=20
> This is an atomic allocation and failing that one is not a problem
> usually. High atomic reservations might prevent GFP_NOWAIT allocation
> from suceeding but I do not see that as a problem. This is the primary
> purpose of the reservation.=20

Thanks, your answer helped me. However, my suggestion is not to modify th=
e use and management of the high atomic region,
but to calculate the exact free size of the highatomic so that fail does =
not occur for previously shared cases.

In __zone_water_mark_ok(...) func, if it is not atomic allocation, high a=
tomic size is excluded.

bool __zone_watermark_ok(struct zone *z,
...
{
    ...
    if (likely(!alloc_harder)) {
        free_pages -=3D z->nr_reserved_highatomic;
    ...
}

However, free_page excludes the size already allocated by hiahtomic.
If highatomic block is small(Under 4GB RAM), it could be no problem.
But, the larger the memory size, the greater the chance of problems.
(Becasue highatomic size can be increased up to 1% of memory)

> [...]
> > In my test, most case are using camera. So, memory usage is increased=
 momentarily,
> > it cause free page go to under low value of watermark.
> > If free page is under low and 0-order fail is occured, its normal ope=
ration.
> > But, although free page is higher than min, fail is occurred.
> > After fix routin for checking highatomic size, it's not reproduced.
>=20
> But you are stealing from the atomic reserves and thus defeating the
> purpose of it.


