Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C9A0C3A5A3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F9F20850
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Py/+nEgU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F9F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1252C6B04BB; Fri, 23 Aug 2019 18:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AE2E6B04BC; Fri, 23 Aug 2019 18:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8EBC6B04BD; Fri, 23 Aug 2019 18:18:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id C259D6B04BB
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 18:18:14 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 692B68243760
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:18:14 +0000 (UTC)
X-FDA: 75855106908.30.rifle72_64d16e05c5e3e
X-HE-Tag: rifle72_64d16e05c5e3e
X-Filterd-Recvd-Size: 4344
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:18:12 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d6066230001>; Fri, 23 Aug 2019 15:18:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 23 Aug 2019 15:18:11 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 23 Aug 2019 15:18:11 -0700
Received: from HQMAIL110.nvidia.com (172.18.146.15) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 23 Aug
 2019 22:18:11 +0000
Received: from HQMAIL101.nvidia.com (172.20.187.10) by hqmail110.nvidia.com
 (172.18.146.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 23 Aug
 2019 22:18:09 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 23 Aug 2019 22:18:09 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d6066210001>; Fri, 23 Aug 2019 15:18:09 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, "Christoph
 Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 2/2] mm/hmm: hmm_range_fault() infinite loop
Date: Fri, 23 Aug 2019 15:17:53 -0700
Message-ID: <20190823221753.2514-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190823221753.2514-1-rcampbell@nvidia.com>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566598691; bh=H0xCNFTKe9KT+REMj7c8+VZLGl6bVqw61h/FiyncJWs=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Transfer-Encoding:Content-Type;
	b=Py/+nEgUIjhIZbSu7cNxlYuXfEoZik6c6x3VzsIs38x5i57ELvn5JRlErcGl1DLSm
	 OPm61FMKufS0D/REIhl99DbtgwiyufGaCiuLtD8EtwBjFC2UWBQZpe9L/R3XF+LaCc
	 pQYGZc/IOqyS2G+1GlYqg8wySXYGft4IwgvkW/lneMjxIKzhvyBTvhGlLWRH96F7be
	 Fjkol1850wsIJiuiZ2VkFIBG8mjuuMqEH9je3XnpBUdEIlN96xf1lgzs2F34kKu7gW
	 AU8/C52wqkZa4aBqUpmIEWGA90tAL+iwPA08Ennyfoh6kGscOu2VY2sukBo6VVT5Uz
	 8g47hs3zUIkNw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Normally, callers to handle_mm_fault() are supposed to check the
vma->vm_flags first. hmm_range_fault() checks for VM_READ but doesn't
check for VM_WRITE if the caller requests a page to be faulted in
with write permission (via the hmm_range.pfns[] value).
If the vma is write protected, this can result in an infinite loop:
  hmm_range_fault()
    walk_page_range()
      ...
      hmm_vma_walk_hole()
        hmm_vma_walk_hole_()
          hmm_vma_do_fault()
            handle_mm_fault(FAULT_FLAG_WRITE)
            /* returns VM_FAULT_WRITE */
          /* returns -EBUSY */
        /* returns -EBUSY */
      /* returns -EBUSY */
    /* loops on -EBUSY and range->valid */
Prevent this by checking for vma->vm_flags & VM_WRITE before calling
handle_mm_fault().

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
---
 mm/hmm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 29371485fe94..4882b83aeccb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -292,6 +292,9 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsig=
ned long end,
 	hmm_vma_walk->last =3D addr;
 	i =3D (addr - range->start) >> PAGE_SHIFT;
=20
+	if (write_fault && walk->vma && !(walk->vma->vm_flags & VM_WRITE))
+		return -EPERM;
+
 	for (; addr < end; addr +=3D PAGE_SIZE, i++) {
 		pfns[i] =3D range->values[HMM_PFN_NONE];
 		if (fault || write_fault) {
--=20
2.20.1


