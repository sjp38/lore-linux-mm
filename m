Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51EA3C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 175A920850
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:18:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ctpsqG1k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 175A920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AEFE6B04BC; Fri, 23 Aug 2019 18:18:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB6C96B04BD; Fri, 23 Aug 2019 18:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7D146B04BE; Fri, 23 Aug 2019 18:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id B4B336B04BC
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 18:18:15 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 594C852AB
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:18:15 +0000 (UTC)
X-FDA: 75855106950.07.match98_64f85ed3f772d
X-HE-Tag: match98_64f85ed3f772d
X-Filterd-Recvd-Size: 3322
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:18:13 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d6066240001>; Fri, 23 Aug 2019 15:18:12 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 23 Aug 2019 15:18:12 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 23 Aug 2019 15:18:12 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 23 Aug
 2019 22:18:07 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 23 Aug 2019 22:18:07 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d60661e0003>; Fri, 23 Aug 2019 15:18:06 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, "Christoph
 Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 0/2] mm/hmm: two bug fixes for hmm_range_fault()
Date: Fri, 23 Aug 2019 15:17:51 -0700
Message-ID: <20190823221753.2514-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566598693; bh=Z6axOFKbUvqsjcFqMxwwOrZTql7QqKTfP0heWnYU1Z8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=ctpsqG1kNxP+YzsOTUXs7AwK5TY2o4ZmwFLtokaKLQ4zXNU31nsT4X7JyHtFGc5fe
	 O8xIorB0RJZR6/3g7TN0cjxJ0/JlP3grcpjxY6NHweE6/eyjaFRSeeYH/peSmE7G5E
	 6FiA1tTrxCHIAWyCwjMVD8eWRBvO37Z3HtCxaHyPi8tCz1GQZvv+j03ery4xJu2Nvb
	 rik3UshHudfzSfYw2qCWIlQKCR9d0zLt50+Q354r5dPupAuz4gjV8IJsaeiLwrVPAQ
	 M/0ar3v6Up8fbsIC/Ld11+CbgBG306Z+AOrZZelEg4l+GgDLY6zz0F1xBu2md0eZ1G
	 mlS04Yqu1Mb/w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I have been working on converting Jerome's hmm_dummy driver and self
tests into a stand-alone set of tests to be included in
tools/testing/selftests/vm and came across these two bug fixes in the
process. The tests aren't quite ready to be posted as a patch.
I'm posting the fixes now since I thought they shouldn't wait.
They should probably have a fixes line but with all the HMM changes,
I wasn't sure exactly which commit to use.

These are based on top of Jason's latest hmm branch.

Ralph Campbell (2):
  mm/hmm: hmm_range_fault() NULL pointer bug
  mm/hmm: hmm_range_fault() infinite loop

 mm/hmm.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

--=20
2.20.1


