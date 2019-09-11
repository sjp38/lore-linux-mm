Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27564C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D56832085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="EHV8pR7V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D56832085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0F5A6B0282; Wed, 11 Sep 2019 18:28:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 973586B0283; Wed, 11 Sep 2019 18:28:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885FD6B0284; Wed, 11 Sep 2019 18:28:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 53BC46B0283
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:28:52 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DFF189990
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:51 +0000 (UTC)
X-FDA: 75924080862.07.leg90_87841f19bfe58
X-HE-Tag: leg90_87841f19bfe58
X-Filterd-Recvd-Size: 3899
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:51 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7975230000>; Wed, 11 Sep 2019 15:28:51 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 11 Sep 2019 15:28:49 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 11 Sep 2019 15:28:49 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 11 Sep
 2019 22:28:46 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 11 Sep 2019 22:28:46 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d79751e0002>; Wed, 11 Sep 2019 15:28:46 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, "Christoph
 Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 3/4] mm/hmm: allow hmm_range_fault() of mmap(PROT_NONE)
Date: Wed, 11 Sep 2019 15:28:28 -0700
Message-ID: <20190911222829.28874-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190911222829.28874-1-rcampbell@nvidia.com>
References: <20190911222829.28874-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568240931; bh=F20+CtE96DKxf8E9hC0a2S8wRPS9i4pdaXNv/ANnE1k=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=EHV8pR7Vx2o54VOBe9IiUlPWtdqX1Bc/1/UKUEx3gpEMFs7hfOIwd/89RCnmdNqV/
	 JxxnSfJKv+Lv+A9hv5TtPCiEQ7UeRyHgPP165+7aebwpPZ/iuE5m1lagJtleznsAgb
	 RHcAoxNlxawV83OHZC8z8vwpSD7eV3fSD9HWbJry61FPhtIbRFOvFpre4bIrcVubvC
	 GxD2YwE9TkX0WYagYzw0Ma0JO1W415YxmhSJPW4Tmhkep2I5j2pnJF1VDhbJCdi4RH
	 Y6nNbO/Sh8DurJ3DJPCtvHqf0hRlvIlYyO3ePZLlK2KWMZB9DFAUWRK0HXg3ozACcV
	 KiOoYgiwY9dHQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allow hmm_range_fault() to return success (0) when the range has no access
(!(vma->vm_flags & VM_READ)). The range->pfns[] array will be filled with
range->values[HMM_PFN_NONE] in this case.
This allows the caller to get a snapshot of a range without having to
lookup the vma before calling hmm_range_fault().
If the call to hmm_range_fault() is not a snapshot, the caller can still
check that pfns have the desired access permissions.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 7217912bef13..16c834e5d1c0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -795,7 +795,9 @@ static int hmm_vma_walk_test(unsigned long start,
 	 */
 	if (!(vma->vm_flags & VM_READ)) {
 		(void) hmm_pfns_fill(start, end, range, HMM_PFN_NONE);
-		return -EPERM;
+
+		/* Skip this vma and continue processing the next vma. */
+		return 1;
 	}
=20
 	return 0;
--=20
2.20.1


