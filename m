Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85D66C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B01D20866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B01D20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60CF56B026E; Wed,  5 Jun 2019 21:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56F1D6B026F; Wed,  5 Jun 2019 21:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C1BC6B0270; Wed,  5 Jun 2019 21:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFDA16B026E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o12so492515pll.17
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=SiVuCCtbEhK11erFASlOXyacFc4syf2JNqRU0DHNw+A=;
        b=k870URFiCMI6hXvwyOFvdbD4c+QqPZh42Ac4V8Si0iQKyD1Nk/0xzjfxx3+Gl1aM6m
         cP53d96KCMWNnWb2BQslQFZgneDjVZs8Xeym5QawBVQxA8W4HMCyNIxKZ+rqh39m0kOs
         lZhUoLoHMiSYDEt7OaIJm8RkgBX4CpV9oAVbgcAJq+aL58LMhDlAu+a6fX5qFaCxgTI6
         zE1EJYBvnQfUy5e6/7skoaW3t1Wr3kigbRsSKWJUMgwBZ7ppONUT4DfSl3/MgJ+CVwfB
         RsYgnXlDMHnhjah4Irr9hNuQOBpv/4v+4p2SOJQBAAbHNWAkPjsLXLx4WMhaNwMn4Eu0
         uaIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYNDAzEjyLpcabNQVhj4CRGpu7vtf+F2F7iXlduBRYEeitFV8Z
	/86gfe/rlFWwQpjDdmd270gQudCin7cb3e+Qvxe3+oSTcVo5q/u6zmgAwvAXSzSO5CdvHYlYH1B
	+IrGuuvgVk+i7kWsBNt/xCBNobRumXh9KsgSmKXwie/VFFCqgjvs6mUWJb3I1I2xCGw==
X-Received: by 2002:a63:f813:: with SMTP id n19mr789985pgh.273.1559785510546;
        Wed, 05 Jun 2019 18:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydaWFJjG4fpe55byX2jIe4sSnd7IThyPzC04iYMvKY010D47HYUdcjCQGYDlm9byDwWJmp
X-Received: by 2002:a63:f813:: with SMTP id n19mr789911pgh.273.1559785509288;
        Wed, 05 Jun 2019 18:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785509; cv=none;
        d=google.com; s=arc-20160816;
        b=khTr19gqf3NG9kSQMcleUP+NeBorXWp0IWdQt3bwI8SHI/C88SaZaagVjtbBaIhUWf
         d5okYTbuFgq8Ffb0EQpMVfKw2gcZ6TJdqAuez1cB3g8qechzzgi/rZTwNNyoS6aa5BB+
         px2dQFQ/xLdU2e2RD+4pN+7bWF3Ta4XORTTJOWbocIJiUjiAowYGVrBljYj+4RHnFRZN
         /sXt7V0godmX3dc10Fvz2TH4J8RiJ2U5UwIWUVmokpbnoqg8jzYz/nWVPAh5jp6WbMkY
         g3sCYn6Efp0+7Tj+198GeCkSY3KjTNJcs1IzZeSKExy73TvrXc1sykcgn/Esle7Xjh/q
         r0gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=SiVuCCtbEhK11erFASlOXyacFc4syf2JNqRU0DHNw+A=;
        b=jpu5dCPOT3oprXI1t0I083gLSMI9+ICdyKQ3GwvBoTBZhk9qeof9Um+U1dNGmGL0kc
         Yhv2Di+BFWsFEdsRKZPbvu9WbzTpyBVLu/cg68n49I0pJJPUi49JYNtYP9vguAc08YN5
         dovmjvu8UlvWqIwtwk8nSMrTt8tR50Vk4LFB5jQZd/G53f7nytnjgbnWrugrsMgLkcbK
         32xxicKji7p/xN66zGZ6ZZIBQuEQk1F5KEv2wJfzuJuHf4EPyw44IQZ0c+196t5b8NB2
         ZKK5x0kxO5WMQBtPpgDq7CAT/Z+sZyiC8F4RKacyOICGkAkwC2SrwvrtDjmSB9m9RVCV
         x06g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:08 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:06 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Date: Wed,  5 Jun 2019 18:45:33 -0700
Message-Id: <20190606014544.8339-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

... V1,000,000   ;-)

Pre-requisites:
	John Hubbard's put_user_pages() patch series.[1]
	Jan Kara's ext4_break_layouts() fixes[2]

Based on the feedback from LSFmm and the LWN article which resulted.  I've
decided to take a slightly different tack on this problem.

The real issue is that there is no use case for a user to have RDMA pinn'ed
memory which is then truncated.  So really any solution we present which:

A) Prevents file system corruption or data leaks
...and...
B) Informs the user that they did something wrong

Should be an acceptable solution.

Because this is slightly new behavior.  And because this is gonig to be
specific to DAX (because of the lack of a page cache) we have made the user
"opt in" to this behavior.

The following patches implement the following solution.

1) The user has to opt in to allowing GUP pins on a file with a layout lease
   (now made visible).
2) GUP will fail (EPERM) if a layout lease is not taken
3) Any truncate or hole punch operation on a GUP'ed DAX page will fail.
4) The user has the option of holding the layout lease to receive a SIGIO for
   notification to the original thread that another thread has tried to delete
   their data.  Furthermore this indicates that if the user needs to GUP the
   file again they will need to retake the Layout lease before doing so.


NOTE: If the user releases the layout lease or if it has been broken by another
operation further GUP operations on the file will fail without re-taking the
lease.  This means that if a user would like to register pieces of a file and
continue to register other pieces later they would be advised to keep the
layout lease, get a SIGIO notification, and retake the lease.

NOTE2: Truncation of pages which are not actively pinned will succeed.  Similar
to accessing an mmap to this area GUP pins of that memory may fail.


A general overview follows for background.

It should be noted that one solution for this problem is to use RDMA's On
Demand Paging (ODP).  There are 2 big reasons this may not work.

	1) The hardware being used for RDMA may not support ODP
	2) ODP may be detrimental to the over all network (cluster or cloud)
	   performance

Therefore, in order to support RDMA to File system pages without On Demand
Paging (ODP) a number of things need to be done.

1) GUP "longterm" users need to inform the other subsystems that they have
   taken a pin on a page which may remain pinned for a very "long time".[3]

2) Any page which is "controlled" by a file system needs to have special
   handling.  The details of the handling depends on if the page is page cache
   fronted or not.

   2a) A page cache fronted page which has been pinned by GUP long term can use a
   bounce buffer to allow the file system to write back snap shots of the page.
   This is handled by the FS recognizing the GUP long term pin and making a copy
   of the page to be written back.
	NOTE: this patch set does not address this path.

   2b) A FS "controlled" page which is not page cache fronted is either easier
   to deal with or harder depending on the operation the filesystem is trying
   to do.

	2ba) [Hard case] If the FS operation _is_ a truncate or hole punch the
	FS can no longer use the pages in question until the pin has been
	removed.  This patch set presents a solution to this by introducing
	some reasonable restrictions on user space applications.

	2bb) [Easy case] If the FS operation is _not_ a truncate or hole punch
	then there is nothing which need be done.  Data is Read or Written
	directly to the page.  This is an easy case which would currently work
	if not for GUP long term pins being disabled.  Therefore this patch set
	need not change access to the file data but does allow for GUP pins
	after 2ba above is dealt with.


This patch series and presents a solution for problem 2ba)

[1] https://github.com/johnhubbard/linux/tree/gup_dma_core

[2] ext4/dev branch:

- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/log/?h=dev

	Specific patches:

	[2a] ext4: wait for outstanding dio during truncate in nojournal mode

	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=82a25b027ca48d7ef197295846b352345853dfa8

	[2b] ext4: do not delete unlinked inode from orphan list on failed truncate

	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=ee0ed02ca93ef1ecf8963ad96638795d55af2c14

	[2c] ext4: gracefully handle ext4_break_layouts() failure during truncate

	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=b9c1c26739ec2d4b4fb70207a0a9ad6747e43f4c

[3] The definition of long time is debatable but it has been established
that RDMAs use of pages, minutes or hours after the pin is the extreme case
which makes this problem most severe.


Ira Weiny (10):
  fs/locks: Add trace_leases_conflict
  fs/locks: Export F_LAYOUT lease to user space
  mm/gup: Pass flags down to __gup_device_huge* calls
  mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
  fs/ext4: Teach ext4 to break layout leases
  fs/ext4: Teach dax_layout_busy_page() to operate on a sub-range
  fs/ext4: Fail truncate if pages are GUP pinned
  fs/xfs: Teach xfs to use new dax_layout_busy_page()
  fs/xfs: Fail truncate if pages are GUP pinned
  mm/gup: Remove FOLL_LONGTERM DAX exclusion

 fs/Kconfig                       |   1 +
 fs/dax.c                         |  38 ++++++---
 fs/ext4/ext4.h                   |   2 +-
 fs/ext4/extents.c                |   6 +-
 fs/ext4/inode.c                  |  26 +++++--
 fs/locks.c                       |  97 ++++++++++++++++++++---
 fs/xfs/xfs_file.c                |  24 ++++--
 fs/xfs/xfs_inode.h               |   5 +-
 fs/xfs/xfs_ioctl.c               |  15 +++-
 fs/xfs/xfs_iops.c                |  14 +++-
 fs/xfs/xfs_pnfs.c                |  14 ++--
 include/linux/dax.h              |   9 ++-
 include/linux/fs.h               |   2 +-
 include/linux/mm.h               |   2 +
 include/trace/events/filelock.h  |  35 +++++++++
 include/uapi/asm-generic/fcntl.h |   3 +
 mm/gup.c                         | 129 ++++++++++++-------------------
 mm/huge_memory.c                 |  12 +++
 18 files changed, 299 insertions(+), 135 deletions(-)

-- 
2.20.1

