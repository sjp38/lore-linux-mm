Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F16EC3A5A2
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F16BB22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F16BB22DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BCA26B02C3; Wed, 21 Aug 2019 10:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86EB26B02C4; Wed, 21 Aug 2019 10:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783F56B02C5; Wed, 21 Aug 2019 10:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 58DE36B02C3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:53:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EB1228248ABE
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:16 +0000 (UTC)
X-FDA: 75846727992.03.fowl27_1c5954d5a1400
X-HE-Tag: fowl27_1c5954d5a1400
X-Filterd-Recvd-Size: 5892
Received: from huawei.com (szxga07-in.huawei.com [45.249.212.35])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:14 +0000 (UTC)
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id C3CF06E4B87B7D1AE8DE;
	Wed, 21 Aug 2019 22:53:06 +0800 (CST)
Received: from lhrphicprd00229.huawei.com (10.123.41.22) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.439.0; Wed, 21 Aug 2019 22:52:58 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: Keith Busch <keith.busch@intel.com>, <jglisse@redhat.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, <linuxarm@huawei.com>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 0/4 V4] ACPI: Support generic initiator proximity domains
Date: Wed, 21 Aug 2019 22:52:38 +0800
Message-ID: <20190821145242.2330-1-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.123.41.22]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch set has been sitting around for a long time without significan=
t
review.  I would appreciate it very much if anyone has time to take a loo=
k.

One outstanding question to highlight in this series is whether
we should assume all ACPI supporting architectures support Generic
Initiator domains, or whether to introduce an
ARCH_HAS_GENERIC_INITIATOR_DOMAINS entry in Kconfig.

Change since V3.
* Rebase.

Changes since RFC V2.
* RFC dropped as now we have x86 support, so the lack of guards in in the
  ACPI code etc should now be fine.
* Added x86 support.  Note this has only been tested on QEMU as I don't h=
ave
  a convenient x86 NUMA machine to play with.  Note that this fitted toge=
ther
  rather differently form arm64 so I'm particularly interested in feedbac=
k
  on the two solutions.

Since RFC V1.
* Fix incorrect interpretation of the ACPI entry noted by Keith Busch
* Use the acpica headers definitions that are now in mmotm.

It's worth noting that, to safely put a given device in a GI node, may
require changes to the existing drivers as it's not unusual to assume
you have local memory or processor core. There may be further constraints
not yet covered by this patch.

Original cover letter...

ACPI 6.3 introduced a new entity that can be part of a NUMA proximity dom=
ain.
It may share such a domain with the existing options (memory, CPU etc) bu=
t it
may also exist on it's own.

The intent is to allow the description of the NUMA properties (particular=
ly
via HMAT) of accelerators and other initiators of memory activity that ar=
e not
the host processor running the operating system.

This patch set introduces 'just enough' to make them work for arm64 and x=
86.
It should be trivial to support other architectures, I just don't suitabl=
e
NUMA systems readily available to test.

There are a few quirks that need to be considered.

1. Fall back nodes
******************

As pre ACPI 6.3 supporting operating systems do not have Generic Initiato=
r
Proximity Domains it is possible to specify, via _PXM in DSDT that anothe=
r
device is part of such a GI only node.  This currently blows up spectacul=
arly.

Whilst we can obviously 'now' protect against such a situation (see the r=
elated
thread on PCI _PXM support and the  threadripper board identified there a=
s
also falling into the  problem of using non existent nodes
https://patchwork.kernel.org/patch/10723311/ ), there is no way to  be su=
re
we will never have legacy OSes that are not protected  against this.  It =
would
also be 'non ideal' to fallback to  a default node as there may be a bett=
er
(non GI) node to pick  if GI nodes aren't available.

The work around is that we also have a new system wide OSC bit that allow=
s
an operating system to 'announce' that it supports Generic Initiators.  T=
his
allows, the firmware to us DSDT magic to 'move' devices between the nodes
dependent on whether our new nodes are there or not.

2. New ways of assigning a proximity domain for devices
*******************************************************

Until now, the only way firmware could indicate that a particular device
(outside the 'special' set of cpus etc) was to be found in a particular
Proximity Domain by the use of _PXM in DSDT.

That is equally valid with GI domains, but we have new options. The SRAT
affinity structure includes a handle (ACPI or PCI) to identify devices
with the system and specify their proximity domain that way.  If both _PX=
M
and this are provided, they should give the same answer.

For now this patch set completely ignores that feature as we don't need
it to start the discussion.  It will form a follow up set at some point
(if no one else fancies doing it).
=20

Jonathan Cameron (4):
  ACPI: Support Generic Initiator only domains
  arm64: Support Generic Initiator only domains
  x86: Support Generic Initiator only proximity domains
  ACPI: Let ACPI know we support Generic Initiator Affinity Structures

 arch/arm64/kernel/smp.c        |  8 +++++
 arch/x86/include/asm/numa.h    |  2 ++
 arch/x86/kernel/setup.c        |  1 +
 arch/x86/mm/numa.c             | 14 ++++++++
 drivers/acpi/bus.c             |  1 +
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/asm-generic/topology.h |  3 ++
 include/linux/acpi.h           |  1 +
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 11 files changed, 102 insertions(+), 1 deletion(-)

--=20
2.20.1


