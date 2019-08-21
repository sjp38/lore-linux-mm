Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F02B7C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9D8A2332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:07:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XA6UfrA6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9D8A2332A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A5626B0291; Wed, 21 Aug 2019 00:07:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5963C6B0293; Wed, 21 Aug 2019 00:07:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45D496B0292; Wed, 21 Aug 2019 00:07:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 261EF6B028F
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:07:36 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D0D61180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:07:35 +0000 (UTC)
X-FDA: 75845100870.07.hate96_423c6d5af3218
X-HE-Tag: hate96_423c6d5af3218
X-Filterd-Recvd-Size: 4023
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:07:34 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5cc3860000>; Tue, 20 Aug 2019 21:07:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 20 Aug 2019 21:07:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 20 Aug 2019 21:07:33 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 04:07:33 +0000
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 04:07:33 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 21 Aug 2019 04:07:33 +0000
Received: from blueforge.nvidia.com (Not Verified[10.110.48.28]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d5cc3850001>; Tue, 20 Aug 2019 21:07:33 -0700
From: John Hubbard <jhubbard@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v2 0/3] mm/gup: introduce vaddr_pin_pages_remote(), FOLL_PIN
Date: Tue, 20 Aug 2019 21:07:24 -0700
Message-ID: <20190821040727.19650-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566360454; bh=uyVhqp7Iikhfj8344qx1VFzWIkbM3pJSNZmFd7x5l5o=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=XA6UfrA6lFoTPSUjqbFZI3a7dNJUvP4CdrK9ripJXyx9Yo5DzDH2Ay5MuUMu/41bO
	 UqbpMDmfE8WaZzqd0s7Rmu0ypulWp9E5jo4whaTYp4kzsjysPkDaHu0dv4wCZ/5MJW
	 U+eZCd4rdUDs5YiwGb7sXgpjJaMxf0qLGrM6Ozaeqi+IyQpB+McIltnVdPR0/C7YtD
	 GJh1pCKjVIyNwAnCzbFs8/Tt8eeP8K2SkobKCy4zpcxotj/8Gycw3s+Kkl4bqHwvu/
	 n8G6roBAp/PtxA5N5rNvRJRl7nhZhRRCDjFON1+QnBJz0Jrf9EhKrx0nbzM81maDvz
	 w3/7lG5eZmwAg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ira,

This is for your tree. I'm dropping the RFC because this aspect is
starting to firm up pretty well.

I've moved FOLL_PIN inside the vaddr_pin_*() routines, and moved
FOLL_LONGTERM outside, based on our recent discussions. This is
documented pretty well within the patches.

Note that there are a lot of references in comments and commit
logs, to vaddr_pin_pages(). We'll want to catch all of those if
we rename that. I am pushing pretty hard to rename it to
vaddr_pin_user_pages().

v1 of this may be found here:
https://lore.kernel.org/r/20190812015044.26176-1-jhubbard@nvidia.com

John Hubbard (3):
  For Ira: tiny formatting tweak to kerneldoc
  mm/gup: introduce FOLL_PIN flag for get_user_pages()
  mm/gup: introduce vaddr_pin_pages_remote(), and invoke it

 drivers/infiniband/core/umem.c |  1 +
 include/linux/mm.h             | 61 ++++++++++++++++++++++++++++++----
 mm/gup.c                       | 40 ++++++++++++++++++++--
 mm/process_vm_access.c         | 23 +++++++------
 4 files changed, 106 insertions(+), 19 deletions(-)

--=20
2.22.1


