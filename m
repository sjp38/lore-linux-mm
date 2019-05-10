Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9194C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E5AB216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JCrFO6jX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E5AB216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC56D6B0287; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86C6F6B0289; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5616B6B028C; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 230796B028E
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bg6so3720846plb.8
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=XU9Fs96D15VYNAKH4I3Z102VbKRrOw9CU0TapJT0GEw=;
        b=tMqPYCyE38jxpUfrszKWSaiHxsyHU3Zk6jCWWBtO2yiFk5cw0QBhhuMBgsNOBPfvnG
         NK/nLFrnwFA59WbYwRaFnN9zDgJcU/vsKl+kFH4WWF0D7lfwJRUoa+iqJ2orUrbPw7YJ
         gU98G5Vhr2/+CMMNns4XmwShuDIAhY/88OLr8jpYd0LaI+Sf9zcnjIp1jpF5joCb4gYj
         PAUjP/ezqyS8Z8ZS3Y4WtFtgBxOAng6lXLeqi6/wVBUCkHr4QZ5S7F64I0E4jICwentw
         tI0RtqaYh2oqkUfQQbOx5u2j+k/4BJTobstPDaZT0CC/CqffNQRQue1mf2dEZ/QM/X+u
         nXsg==
X-Gm-Message-State: APjAAAWnG4GN3iB2M1R5ZJ9DU+sL0eHH+N1fD09PPQM3CzVXFvPliBHa
	hsZ8QRm/UCCsZGZLz73FQIdFj75ej1po79F0FsJy13qpSqq05MixlQ/xcmrjGjC6ND4RW+XoMQo
	0XlNKdcVgtGfaFJawhRalvlR5c58GvrfbTC3mwcblpQLho9CAcGMrC/VSwiVxaSNcuw==
X-Received: by 2002:a17:902:7c93:: with SMTP id y19mr13276413pll.268.1557496242686;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGp4WJPvmvcCoChWBTj6CwxIllfNP7RyvTrm7gagG3YLrh1VD1it8BtApDivWDL9O/ahBl
X-Received: by 2002:a17:902:7c93:: with SMTP id y19mr13276317pll.268.1557496241855;
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496241; cv=none;
        d=google.com; s=arc-20160816;
        b=lLzrjI+b7/aBMYXSg95Tgu1eFAoJzckbNzWy9HFcdkrIHJaVygHic57RQk+NjLKi6d
         8F34+cqqPeWKXW8cRGqHy+CLX0g/BiOhIrNWFynCn8dCbxpbTziBJgJz1JEN1OrA+YBc
         vaa+TlAKwrwxO2sFoRf48cp6DvDi8reW264SmoeoKJy4TX254KrznGTu3QPjLTsJMVCN
         KVWVWxdreSD4Bum6uiELjZT8JZAPEjaXxUGG4fI0btuB7ZcFkza/lL0k4NM/WCDsgT5Q
         zT8dkPDI9r0It9vS37WAWehe4+iUz06VHypR/bima1K5v38gRpVoOQH2eK0smfO6+zQL
         zE4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=XU9Fs96D15VYNAKH4I3Z102VbKRrOw9CU0TapJT0GEw=;
        b=MZbgKjy4zF7feQmZF9ScbpaFvWUv67+XK3WjU0RT97ft4pC8LD7teHHjquaxnPCzlI
         xVmjaK4Qt41dp+M4UsQSCjeVI9+OOJlTezhq8ML5C/Kylmk56shA0EMgtd3MqeJRalCo
         wsdpm/hMO/IrymBsdGLScRW1yawPJuqxSA4EakCcsAFq5EGbadlNVFqfcON7SS9zniW8
         WpGyVYgMLDhs57ImCfk7i+m8NU9p4J6hxDPJX4JNExqx1A4sHX2J0mwK8hjovxQXvOkk
         PJ6RDMeMC9x32u8JQRDaKG+QtiFFkzTP1QRBV4mQPEW/Y2h+tTgJEX6UAttjHNyWoXyJ
         VEuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JCrFO6jX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b74si7743430pfj.121.2019.05.10.06.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JCrFO6jX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XU9Fs96D15VYNAKH4I3Z102VbKRrOw9CU0TapJT0GEw=; b=JCrFO6jXYsvX7Yo755lGJ40ZY
	yaL34Vtse0UHdftfHP4ik/ak2aAHI95OqTFVGniJR7I2zFOE2+V5FxR2+ENAs+w3VouA0pi507yue
	69qX+dyR4MqdMd7JeParcKcTFmTZBL/pHQrVHnQOF1dQoVtyzL26wXcV8rz5IBY7EKjqfeS9g5ppA
	nNfENEOjqwKewRaKn8OPD49Bf9cQO32acL3ixECznJHK+YigJVvZSV4DnX+h2zG8bmerOzp3Dq+tI
	u3lEuT+7pZU9//U64ZvtLGuJk9XsMvsKmZjVs/gHpnhNKOhmzTXuvVnjI1cyFVV/9cvwG2ucppvcA
	AMc9BdE5Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004TG-2i; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 00/15] Remove 'order' argument from many mm functions
Date: Fri, 10 May 2019 06:50:23 -0700
Message-Id: <20190510135038.17129-1-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

This is a little more serious attempt than v1, since nobody seems opposed
to the concept of using GFP flags to pass the order around.  I've split
it up a bit better, and I've reversed the arguments of __alloc_pages_node
to match the order of the arguments to other functions in the same family.
alloc_pages_node() needs the same treatment, but there's about 70 callers,
so I'm going to skip it for now.

This is against current -mm.  I'm seeing a text saving of 482 bytes from
a tinyconfig vmlinux (1003785 reduced to 1003303).  There are more
savings to be had by combining together order and the gfp flags, for
example in the scan_control data structure.

I think there are also cognitive savings to be had from eliminating
some of the function variants which exist solely to take an 'order'.

Matthew Wilcox (Oracle) (15):
  mm: Remove gfp_flags argument from rmqueue_pcplist
  mm: Pass order to __alloc_pages_nodemask in GFP flags
  mm: Pass order to __alloc_pages in GFP flags
  mm: Pass order to alloc_page_interleave in GFP flags
  mm: Pass order to alloc_pages_current in GFP flags
  mm: Pass order to alloc_pages_vma in GFP flags
  mm: Pass order to __alloc_pages_node in GFP flags
  mm: Pass order to __get_free_page in GFP flags
  mm: Pass order to prep_new_page in GFP flags
  mm: Pass order to rmqueue in GFP flags
  mm: Pass order to get_page_from_freelist in GFP flags
  mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
  mm: Pass order to prepare_alloc_pages in GFP flags
  mm: Pass order to try_to_free_pages in GFP flags
  mm: Pass order to node_reclaim() in GFP flags

 arch/ia64/kernel/uncached.c       |  6 +-
 arch/ia64/sn/pci/pci_dma.c        |  4 +-
 arch/powerpc/platforms/cell/ras.c |  5 +-
 arch/x86/events/intel/ds.c        |  4 +-
 arch/x86/kvm/vmx/vmx.c            |  4 +-
 drivers/misc/sgi-xp/xpc_uv.c      |  5 +-
 include/linux/gfp.h               | 59 +++++++++++--------
 include/linux/migrate.h           |  2 +-
 include/linux/swap.h              |  2 +-
 include/trace/events/vmscan.h     | 28 ++++-----
 kernel/profile.c                  |  2 +-
 mm/filemap.c                      |  2 +-
 mm/gup.c                          |  4 +-
 mm/hugetlb.c                      |  5 +-
 mm/internal.h                     |  5 +-
 mm/khugepaged.c                   |  2 +-
 mm/mempolicy.c                    | 34 +++++------
 mm/migrate.c                      |  9 ++-
 mm/page_alloc.c                   | 98 +++++++++++++++----------------
 mm/shmem.c                        |  5 +-
 mm/slab.c                         |  3 +-
 mm/slob.c                         |  2 +-
 mm/slub.c                         |  2 +-
 mm/vmscan.c                       | 26 ++++----
 24 files changed, 157 insertions(+), 161 deletions(-)

-- 
2.20.1

