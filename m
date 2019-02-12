Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDF91C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97597217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97597217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38E138E0003; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33CD28E0001; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22BD78E0003; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id E79758E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:31 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id g21so613645vsq.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:50:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=DxZPcI6g3hiImAY1U1HkjxAHcnEM/pUulDFW8A2UL28=;
        b=ndT0QYJvGE7m0O4LAKsb8VFKztlO8oxerxOYFOKPKGz8lai6MNQE7OaRJdVJeacN0W
         gCimcgau2CCF2n5wA13dXhZF6t7ui7I32f/F70vhyu5Cx1Gx4RjzwisTpBGkZDWFFWS0
         vM6JyXunwDya7Nn/2Pw9Fbq5vK/lzKDgRPW9UIhx0kcxhDejb4ZVzW3gJnk8TGFcxOLh
         G3iS8SP7gMM/IKzekuKi9dhQbL6YaKQxynjdLPEqt0ev2gsN8d7V7tcC6ECgqeGwefJh
         wefsg+vVVt8T2GtcFvEblXR+JM0+eN0aNWKrD23DkzkfFYnDYQWvfQ1fQiZOctpZUJYM
         daCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAubHKsLzxGdz/UYZJ7uKvs1esQ4C9Bjj9/1o8DuSP6d4yRkYQ0x5
	mzJ1gY1eBAPb37BnwGO8BG6MAqS7MpRN8sTEtB12G07/A1tHp+87fPNzsLvbfo/wmSHKHF1oDQD
	2h3ZIFM2yl/7qZYvPefxhw8yVTZJHUi9xcOAyUEuv26gQLOpF9z9oCPPfIQpmwPRKGw==
X-Received: by 2002:a67:b003:: with SMTP id z3mr1862997vse.200.1549990231562;
        Tue, 12 Feb 2019 08:50:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYUlwtpyd/797EqeqK++sU6gZoWQSKLNXNgWZNefw3vaS8O7VogO49b/neN2blAeQdg3qh1
X-Received: by 2002:a67:b003:: with SMTP id z3mr1862969vse.200.1549990230722;
        Tue, 12 Feb 2019 08:50:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990230; cv=none;
        d=google.com; s=arc-20160816;
        b=bRbqYPfdYkGmSc64qDZ2ou88i6km1Snxgjgmo1AVM6gzzCOAmFF1zFQIAFxNRd5JQd
         zVODiqebaTOAnDYHIagAaRdTYlx06l1CG2t3Um/lKri2Km+NmjWlgiIlo4ghm6fr/1RL
         HDLb/q3islG2AGYxBde8v0wQALD7jKCP+6LxeE2/RBqVhHxK4FuBSU58zdzHYeSDQbgJ
         dM6CtydCDesf3vDYQiucq3LtSu43HlC+Xj96gMgT/D8eClHYxNMyca6YDUtZ5FmOJvzQ
         vBkg2zjYaeKyVmYOf3pefVLx3ixtqJrvk2mu8YCxmWltuvofAOnYXSUhVtpGkaE+RdE8
         lz0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=DxZPcI6g3hiImAY1U1HkjxAHcnEM/pUulDFW8A2UL28=;
        b=IqvSUYg/87sSTmTOM1uuVsaiBCeeSkiePxG0Ikk7kKbpyovOrxOR1rK0WiWmCbfKnh
         LuZiaf5FORZXca/PINxBU572q7s7AM/c5RGMwHSkO6csOf2iUtusWrsPyrharakrMFZ0
         dboV9sKr7RZPXTUXw0d1SrSYekNkZ68JuNoeVn/9sqv15xRWHgWp6AHveQPNQ6HxV6ar
         KMGwD02pQJaCHdlvv5qF7jfQQscybxWSYbaYmAbljqgR0FkS2Uu3b/8jPW451vOZV/Xs
         JzBGxRGgAcU92UTcxJhEMbL/dwgWBkBtYy7rWQXJiznxToQQApX33QNayLweRtYonL4g
         v7DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id g4si967671vsq.229.2019.02.12.08.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:50:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id B9FF6C2F53D8B5932EBF;
	Wed, 13 Feb 2019 00:50:26 +0800 (CST)
Received: from j00421895-HPW10.huawei.com (10.202.226.61) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Wed, 13 Feb 2019 00:50:16 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <jonathan.cameron@huawei.com>, <linux-mm@kvack.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <linuxarm@huawei.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Keith Busch <keith.busch@intel.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, Michal Hocko <mhocko@kernel.org>,
	<jcm@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [RFC PATCH 0/3] ACPI: Support generic initiator proximity domains
Date: Tue, 12 Feb 2019 16:49:23 +0000
Message-ID: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ACPI 6.3 introduced a new entity that can be part of a NUMA proximity domain.
It may share such a domain with the existing options (memory, cpu etc) but it
may also exist on it's own.

The intent is to allow the description of the NUMA properties (particulary
via HMAT) of accelerators and other initiators of memory activity that are not
the host processor running the operating system.

To illustrate one use case for this feature.

A multiqueue high performance ethernet adaptor is connected to a pair
of SoCs via an appropriate interconnect. The system memory is attached to
the two SoCs. The ethernet adaptor driver wants to load balance the location
of it's memory buffers between the two different SoCs to avoid saturating
the interconnect.  Under current models the ethernet adaptor must be assigned
to an existing NUMA domain (via _PXM).  None of these are able to indicate
that the ethernet adaptor is equidistant from two separate memory / processor
nodes. By assigning it to a node with none of the traditional elements, we can
represent this and the driver is able to load balance between the nodes
improving performance.   We have hardware where 5-10% performance
improvement may be easily achieved using this approach.  As CCIX and similar
interconnects become common, this situation will occur more often.

This patch set introduces 'just enough' to make them work for arm64.
It should be trivial to support other architectures, I just don't suitable
NUMA systems readily available to test.

There are a few quirks that need to be considered.

1. Fall back nodes
******************

As pre ACPI 6.3 supporting operating systems do not have Generic Initiator
Proximity Domains it is possible to specify, via _PXM in DSDT that another
device is part of such a GI only node.  This currently blows up spectacularly
in Linux.

Whilst we can obviously 'now' protect against such a situation (see the related
thread on PCI _PXM support and the  threadripper board identified there as
also falling into the  problem of using non existent nodes
https://patchwork.kernel.org/patch/10723311/ ), there is no way to  be sure
we will never have legacy OSes that are not protected  against this.  It would
also be 'non ideal' to fallback to  a default node as there may be a better
(non GI) node to pick  if GI nodes aren't available.

The work around is that we also have a new system wide OSC bit that allows
an operating system to 'annouce' that it supports Generic Initiators.  This
allows, the firmware to us DSDT magic to 'move' devices between the nodes
dependent on whether our new nodes are there or not.

2. New ways of assigning a proximity domain for devices
*******************************************************

Until now, the only way firmware could indicate that a particular device
(outside the 'special' set of cpus etc) was to be found in a particular
Proximity Domain by the use of _PXM in DSDT.

That is equally valid with GI domains, but we have new options. The SRAT
affinity structure includes a handle (ACPI or PCI) to identify devices
with the system and specify their proximity domain that way.  If both _PXM
and this are provided, they should give the same answer.

For now this patch set completely ignores that feature as we don't need
it to start the discussion.  It will form a follow up set at some point
(if no one else fancies doing it).

acpica-tools patches will go via the normal route to there.

Bits of the headers are here in order to have this stand on it's own.

Jonathan Cameron (3):
  ACPI: Support Generic Initator only domains
  arm64: Support Generic Initiator only domains
  ACPI: Let ACPI know we support Generic Initiator Affinity Structures

 arch/arm64/kernel/smp.c        |  8 +++++
 drivers/acpi/bus.c             |  1 +
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/acpi/actbl3.h          | 37 +++++++++++++++++++-
 include/asm-generic/topology.h |  3 ++
 include/linux/acpi.h           |  1 +
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 9 files changed, 121 insertions(+), 2 deletions(-)

-- 
2.18.0


