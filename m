Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55531C0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1394F208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JPKkluHX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1394F208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA41D6B0005; Wed, 14 Aug 2019 03:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55406B0006; Wed, 14 Aug 2019 03:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A496B0007; Wed, 14 Aug 2019 03:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0125.hostedemail.com [216.40.44.125])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1D16B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:59:40 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E3F9C8248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:39 +0000 (UTC)
X-FDA: 75820284078.02.pets33_544d7b8b28547
X-HE-Tag: pets33_544d7b8b28547
X-Filterd-Recvd-Size: 3080
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=JVLupnHp/2HEL1nOJxPMzcGzWGTuwVGtB/+M404XJkE=; b=JPKkluHXANV3awUUpuvJcS5NT
	5awHaFSwZn1/i0TJJtE3fi/qxiLHwIVJg48wdR8sIbS4qLVhXATdFK9VMQs4cbxoXMHMhxIyzbTUW
	0KENQgeMZoxmA8wU4/XAyAYaABLnh5rNbE/HUxdzRZz6CSQRGkDRkDXwDWabLnEcXkLaW+l6V4Yoz
	iLKh8dBjzqUKUouq8fpd863K42hkg5zIJasXrCRyFOWrbQRYdR/zDvHLaOuRyPks+RztFhMjOfdiS
	w8QfISAZRlHzyPnXoWix4EEZp+XuxvvVxVkdvGQYuWDO3lYQqJlfIAs5ZQg2P7JkByBv8Ib0+w3Ry
	P4J23sxPA==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoBu-0007vG-RS; Wed, 14 Aug 2019 07:59:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: turn hmm migrate_vma upside down v3
Date: Wed, 14 Aug 2019 09:59:18 +0200
Message-Id: <20190814075928.23766-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi J=C3=A9r=C3=B4me, Ben and Jason,

below is a series against the hmm tree which starts revamping the
migrate_vma functionality.  The prime idea is to export three slightly
lower level functions and thus avoid the need for migrate_vma_ops
callbacks.

Diffstat:

    7 files changed, 282 insertions(+), 614 deletions(-)

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git migrate_vma-cleanup.3

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/migra=
te_vma-cleanup.3


Changes since v2:
 - don't unmap pages when returning 0 from nouveau_dmem_migrate_to_ram
 - minor style fixes
 - add a new patch to remove CONFIG_MIGRATE_VMA_HELPER

Changes since v1:
 - fix a few whitespace issues
 - drop the patch to remove MIGRATE_PFN_WRITE for now
 - various spelling fixes
 - clear cpages and npages in migrate_vma_setup
 - fix the nouveau_dmem_fault_copy_one return value
 - minor improvements to some nouveau internal calling conventions

