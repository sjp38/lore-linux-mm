Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F716C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 06:10:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 028622190F
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 06:10:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 028622190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A73E96B0003; Mon,  2 Sep 2019 02:10:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4B0B6B0006; Mon,  2 Sep 2019 02:10:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 961796B0007; Mon,  2 Sep 2019 02:10:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 72C9E6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 02:10:00 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0A632180AD7C3
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 06:10:00 +0000 (UTC)
X-FDA: 75888954960.06.soup51_57407dc3dda5b
X-HE-Tag: soup51_57407dc3dda5b
X-Filterd-Recvd-Size: 3369
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 06:09:59 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CDD63B04F;
	Mon,  2 Sep 2019 06:09:57 +0000 (UTC)
Date: Mon, 2 Sep 2019 08:09:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: =?utf-8?B?67CV7IOB7Jqw?= <sangwoo2.park@lge.com>
Cc: hannes@cmpxchg.org, arunks@codeaurora.org, guro@fb.com,
	richard.weiyang@gmail.com, glider@google.com, jannh@google.com,
	dan.j.williams@intel.com, akpm@linux-foundation.org,
	alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com,
	gregkh@linuxfoundation.org, janne.huttunen@nokia.com,
	pasha.tatashin@soleen.com, vbabka@suse.cz, osalvador@suse.de,
	mgorman@techsingularity.net, khlebnikov@yandex-team.ru,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: Re: [PATCH] mm: Add nr_free_highatomimic to fix incorrect
 watermatk routine
Message-ID: <20190902060955.GB14028@dhcp22.suse.cz>
References: <1567157153-22024-1-git-send-email-sangwoo2.park@lge.com>
 <20190830110907.GC28313@dhcp22.suse.cz>
 <OF7501D4D5.8C005EEB-ON49258469.00192B40-49258469.00192B40@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <OF7501D4D5.8C005EEB-ON49258469.00192B40-49258469.00192B40@lge.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 02-09-19 13:34:54, =EB=B0=95=EC=83=81=EC=9A=B0 wrote:
> >On Fri 30-08-19 18:25:53, Sangwoo wrote:
> >> The highatomic migrate block can be increased to 1% of Total memory.
> >> And, this is for only highorder ( > 0 order). So, this block size is
> >> excepted during check watermark if allocation type isn't alloc_harde=
r.
> >>
> >> It has problem. The usage of highatomic is already calculated at
> NR_FREE_PAGES.
> >> So, if we except total block size of highatomic, it's twice minus si=
ze of
> allocated
> >> highatomic.
> >> It's cause allocation fail although free pages enough.
> >>
> >> We checked this by random test on my target(8GB RAM).
> >>
> >>  Binder:6218_2: page allocation failure: order:0, mode:0x14200ca
> (GFP_HIGHUSER_MOVABLE), nodemask=3D(null)
> >>  Binder:6218_2 cpuset=3Dbackground mems_allowed=3D0
> >
> >How come this order-0 sleepable allocation fails? The upstream kernel
> >doesn't fail those allocations unless the process context is killed by
> >the oom killer.
>=20
> Most calltacks are zsmalloc, as shown below.

What makes those allocations special so that they fail unlike any other
normal order-0 requests? Also do you see the same problem with the
current upstream kernel? Is it possible this is an Android specific
issue?

>  Call trace:
>   dump_backtrace+0x0/0x1f0
>   show_stack+0x18/0x20
>   dump_stack+0xc4/0x100
>   warn_alloc+0x100/0x198
>   __alloc_pages_nodemask+0x116c/0x1188
>   do_swap_page+0x10c/0x6f0
>   handle_pte_fault+0x12c/0xfe0
>   handle_mm_fault+0x1d0/0x328
>   do_page_fault+0x2a0/0x3e0
>   do_translation_fault+0x44/0xa8
>   do_mem_abort+0x4c/0xd0
>   el1_da+0x24/0x84
>   __arch_copy_to_user+0x5c/0x220
>   binder_ioctl+0x20c/0x740
>   compat_SyS_ioctl+0x128/0x248
>   __sys_trace_return+0x0/0x4
--=20
Michal Hocko
SUSE Labs

