Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419ABC3A59E
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 01:31:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ECEC22DD3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 01:31:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ECEC22DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C43A6B02C5; Wed, 21 Aug 2019 21:31:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94D806B02C6; Wed, 21 Aug 2019 21:31:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8149F6B02C7; Wed, 21 Aug 2019 21:31:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6CD6B02C5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:31:07 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F22C6180AD7C3
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 01:31:06 +0000 (UTC)
X-FDA: 75848335332.07.roll49_43d24e05ceb40
X-HE-Tag: roll49_43d24e05ceb40
X-Filterd-Recvd-Size: 3404
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 01:31:05 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A3BE710F23EC;
	Thu, 22 Aug 2019 01:31:04 +0000 (UTC)
Received: from localhost (ovpn-12-48.pek2.redhat.com [10.72.12.48])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C02EA3DB3;
	Thu, 22 Aug 2019 01:31:03 +0000 (UTC)
Date: Thu, 22 Aug 2019 09:31:00 +0800
From: Baoquan He <bhe@redhat.com>
To: Qian Cai <cai@lca.pw>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Dave Jiang <dave.jiang@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
Message-ID: <20190822013100.GC2588@MiWiFi-R3L-srv>
References: <1565991345.8572.28.camel@lca.pw>
 <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
 <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw>
 <CAPcyv4h9Y7wSdF+jnNzLDRobnjzLfkGLpJsML2XYLUZZZUPsQA@mail.gmail.com>
 <E7A04694-504D-4FB3-9864-03C2CBA3898E@lca.pw>
 <CAPcyv4gofF-Xf0KTLH4EUkxuXdRO3ha-w+GoxgmiW7gOdS2nXQ@mail.gmail.com>
 <0AC959D7-5BCB-4A81-BBDC-990E9826EB45@lca.pw>
 <1566421927.5576.3.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1566421927.5576.3.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.66]); Thu, 22 Aug 2019 01:31:04 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/21/19 at 05:12pm, Qian Cai wrote:
> > > Does disabling CONFIG_RANDOMIZE_BASE help? Maybe that workaround ha=
s
> > > regressed. Effectively we need to find what is causing the kernel t=
o
> > > sometimes be placed in the middle of a custom reserved memmap=3D ra=
nge.
> >=20
> > Yes, disabling KASLR works good so far. Assuming the workaround, i.e.=
,
> > f28442497b5c
> > (=E2=80=9Cx86/boot: Fix KASLR and memmap=3D collision=E2=80=9D) is co=
rrect.
> >=20
> > The only other commit that might regress it from my research so far i=
s,
> >=20
> > d52e7d5a952c ("x86/KASLR: Parse all 'memmap=3D' boot option entries=E2=
=80=9D)
> >=20
>=20
> It turns out that the origin commit f28442497b5c (=E2=80=9Cx86/boot: Fi=
x KASLR and
> memmap=3D collision=E2=80=9D) has a bug that is unable to handle "memma=
p=3D" in
> CONFIG_CMDLINE instead of a parameter in bootloader because when it (as=
 well as
> the commit d52e7d5a952c) calls get_cmd_line_ptr() in order to run
> mem_avoid_memmap(), "boot_params" has no knowledge of CONFIG_CMDLINE. O=
nly later
> in setup_arch(), the kernel will deal with parameters over there.

Yes, we didn't consider CONFIG_CMDLINE during boot compressing stage. It
should be a generic issue since other parameters from CONFIG_CMDLINE coul=
d
be ignored too, not only KASLR handling. Would you like to cast a patch
to fix it? Or I can fix it later, maybe next week.

Thanks
Baoquan

