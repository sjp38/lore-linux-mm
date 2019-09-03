Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5549C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9205A2087E
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:22:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9205A2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5826B0003; Tue,  3 Sep 2019 06:22:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15EEB6B0005; Tue,  3 Sep 2019 06:22:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 026136B0006; Tue,  3 Sep 2019 06:22:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id CF21D6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 06:22:43 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 75B136D8C
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:22:43 +0000 (UTC)
X-FDA: 75893220606.10.pie19_17bd3acc4664d
X-HE-Tag: pie19_17bd3acc4664d
X-Filterd-Recvd-Size: 3573
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:22:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2DE8FAD78;
	Tue,  3 Sep 2019 10:22:41 +0000 (UTC)
Date: Tue, 3 Sep 2019 12:22:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Park Sangwoo <sangwoo2.park@lge.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, dan.j.williams@intel.com,
	mgorman@techsingularity.net, richard.weiyang@gmail.com,
	hannes@cmpxchg.org, arunks@codeaurora.org, osalvador@suse.de,
	rppt@linux.vnet.ibm.com, alexander.h.duyck@linux.intel.com,
	glider@google.com, gregkh@linuxfoundation.org, guro@fb.com,
	jannh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: Re: Re: [PATCH] mm: Add nr_free_highatomimic to fix incorrect
 watermatk routine
Message-ID: <20190903102238.GQ14028@dhcp22.suse.cz>
References: <20190903095959.GA4458@LGEARND18B2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190903095959.GA4458@LGEARND18B2>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 18:59:59, Park Sangwoo wrote:
> >On Mon 02-09-19 13:34:54, Sangwoo=EF=BF=BD wrote:
> >>>On Fri 30-08-19 18:25:53, Sangwoo wrote:
> >>>> The highatomic migrate block can be increased to 1% of Total memor=
y.
> >>>> And, this is for only highorder ( > 0 order). So, this block size =
is
> >>>> excepted during check watermark if allocation type isn't alloc_har=
der.
> >>>>
> >>>> It has problem. The usage of highatomic is already calculated at
> >> NR_FREE_PAGES.
> >>>> So, if we except total block size of highatomic, it's twice minus =
size of
> >>allocated
> >>>> highatomic.
> >>>> It's cause allocation fail although free pages enough.
> >>>>
> >>>> We checked this by random test on my target(8GB RAM).
> >>>>
> >>>>  Binder:6218_2: page allocation failure: order:0, mode:0x14200ca
> >> (GFP_HIGHUSER_MOVABLE), nodemask=3D(null)
> >>>>  Binder:6218_2 cpuset=3Dbackground mems_allowed=3D0
> >>>
> >>>How come this order-0 sleepable allocation fails? The upstream kerne=
l
> >>>doesn't fail those allocations unless the process context is killed =
by
> >>>the oom killer.
> >>=20
> >> Most calltacks are zsmalloc, as shown below.
> >
> >What makes those allocations special so that they fail unlike any othe=
r
> >normal order-0 requests? Also do you see the same problem with the
> >current upstream kernel? Is it possible this is an Android specific
> >issue?
>=20
> There is the other case of fail order-0 fail.
> ----
> hvdcp_opti: page allocation failure: order:0, mode:0x1004000(GFP_NOWAIT=
|__GFP_COMP), nodemask=3D(null)

This is an atomic allocation and failing that one is not a problem
usually. High atomic reservations might prevent GFP_NOWAIT allocation
from suceeding but I do not see that as a problem. This is the primary
purpose of the reservation.=20
[...]
> In my test, most case are using camera. So, memory usage is increased m=
omentarily,
> it cause free page go to under low value of watermark.
> If free page is under low and 0-order fail is occured, its normal opera=
tion.
> But, although free page is higher than min, fail is occurred.
> After fix routin for checking highatomic size, it's not reproduced.

But you are stealing from the atomic reserves and thus defeating the
purpose of it.
--=20
Michal Hocko
SUSE Labs

