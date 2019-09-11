Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 180FDC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD2A52085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OTq660Rj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD2A52085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63DD56B027F; Wed, 11 Sep 2019 18:28:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ECC46B0280; Wed, 11 Sep 2019 18:28:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5030A6B0281; Wed, 11 Sep 2019 18:28:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDB76B027F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:28:50 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B70571E097
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:49 +0000 (UTC)
X-FDA: 75924080778.03.eyes79_870cb2023b91d
X-HE-Tag: eyes79_870cb2023b91d
X-Filterd-Recvd-Size: 4198
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:47 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7975230000>; Wed, 11 Sep 2019 15:28:51 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 11 Sep 2019 15:28:46 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 11 Sep 2019 15:28:46 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 11 Sep
 2019 22:28:43 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 11 Sep 2019 22:28:43 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d79751a0003>; Wed, 11 Sep 2019 15:28:42 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, "Christoph
 Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 0/4] HMM tests and minor fixes
Date: Wed, 11 Sep 2019 15:28:25 -0700
Message-ID: <20190911222829.28874-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568240931; bh=Dh8YksJO7otMqlUqvnlcy89p09JxR+sFwxCtiGvsYNU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=OTq660RjB6dzpe60fOzoY+lzAEtGvMCTtmZoIVWmV8sMmeiCyqSIkhLfThszuvYzb
	 Ha0CoERgf0L/6cb34YwFmnwIJZEjBTERV3ek1H/GBmMBbY4vlY71RzAZYn7aqaf2qV
	 kPH8Wdz/cA/lZBTpiO1DK+kfQb8eq3uoVSBW2P/Q+8fNaiT6POn7oxnFh0GpJOAcR3
	 NvejJ2Bw/bSaL44yDphjMPYhLgDhLt7wqqxU5n+bGJ5Id7ueYMWoUKMmfyQ/mhJQDt
	 k6+ohnisBrTSSEzHZq0olTXV+Hc1p/35HLmSUfBpwcQRpHOZQwniQdCNWncl7t+pgb
	 cpAhUMgiRHdww==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These changes are based on Jason's latest hmm branch.
Patch 1 was previously posted here [1] but was dropped from the orginal
series. Hopefully, the tests will reduce concerns about edge conditions.
I'm sure more tests could be usefully added but I thought this was a good
starting point.

[1] https://lore.kernel.org/linux-mm/20190726005650.2566-6-rcampbell@nvidia=
.com/

Ralph Campbell (4):
  mm/hmm: make full use of walk_page_range()
  mm/hmm: allow snapshot of the special zero page
  mm/hmm: allow hmm_range_fault() of mmap(PROT_NONE)
  mm/hmm/test: add self tests for HMM

 MAINTAINERS                            |    3 +
 drivers/char/Kconfig                   |   11 +
 drivers/char/Makefile                  |    1 +
 drivers/char/hmm_dmirror.c             | 1504 ++++++++++++++++++++++++
 include/Kbuild                         |    1 +
 include/uapi/linux/hmm_dmirror.h       |   74 ++
 mm/hmm.c                               |  117 +-
 tools/testing/selftests/vm/.gitignore  |    1 +
 tools/testing/selftests/vm/Makefile    |    3 +
 tools/testing/selftests/vm/config      |    3 +
 tools/testing/selftests/vm/hmm-tests.c | 1304 ++++++++++++++++++++
 tools/testing/selftests/vm/run_vmtests |   16 +
 tools/testing/selftests/vm/test_hmm.sh |  105 ++
 13 files changed, 3079 insertions(+), 64 deletions(-)
 create mode 100644 drivers/char/hmm_dmirror.c
 create mode 100644 include/uapi/linux/hmm_dmirror.h
 create mode 100644 tools/testing/selftests/vm/hmm-tests.c
 create mode 100755 tools/testing/selftests/vm/test_hmm.sh

--=20
2.20.1


