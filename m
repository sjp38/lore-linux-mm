Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50649C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECD0920693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NqDbh2O8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECD0920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91E6D8E0003; Tue, 30 Jul 2019 16:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A8A48E0001; Tue, 30 Jul 2019 16:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7223D8E0003; Tue, 30 Jul 2019 16:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35F0F8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:57:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n9so37893004pgq.4
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:57:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=uqJmpXDtzLBWNlelQWuVA7iDRDyZ/qRljFOmlSAAnn0=;
        b=Oc9uu3kYP+xiRxIT7XfYodzijwJYI49JExtIUzDvBV1UXAob+zZWVtVCCyP3gxY/d3
         3pFTq0weNGKmrmNVNX6D9A54ZHSjJrDi2dlYnN98joegOfNlj6Xf/ajlfar2GiXCKq2V
         ec90/g0ftx1nB6WaSTD2seJ6dCQm4IW2RDzBKMRnxxMafhHgn02arZRTlfT71TGbe41/
         LeIfks47RnmRy9Ve6SpBAi1mkg+ftwyPw73Pg/T2uqsmZejNaYwA5YHLkWSW5A2fQqln
         kqQTC3nRBzio0xBs8JdH3au42pU5MuZG/OqHavHNGbyPrVG0tjAVGG6ywT/RUO/ulH39
         PK0g==
X-Gm-Message-State: APjAAAVSorD/HCzu52FRXeHi5TM6yXGrrYhSgEB0wPCa2l8LbdNYnkAn
	QhgesgsQqBrd+eoZbEMKi3CN/O3C9VtT3TRd1a3zjyccsBreMSt8ptqOXfty/oktmkmP0qAWBc6
	hRm5XaxMiucyOCzm40l82RmzREdcf5xZr/UKK9suee7mSaX4oGt6NGuhL+AnGKQk/uw==
X-Received: by 2002:a63:fe15:: with SMTP id p21mr111900994pgh.149.1564520229762;
        Tue, 30 Jul 2019 13:57:09 -0700 (PDT)
X-Received: by 2002:a63:fe15:: with SMTP id p21mr111900945pgh.149.1564520228770;
        Tue, 30 Jul 2019 13:57:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520228; cv=none;
        d=google.com; s=arc-20160816;
        b=qO2NsKjyKRWMJXZRYjvXHn6WivU7QHcVpzCbgObiJeM2Yf/7YlzKpNFuuqNG96gCVb
         1sjVxRKNqGGItYSg3QgmyUGlFP+udM5pF5w92m3T2jWWC/SbgLo3um6rW5/LvmwYzwZY
         N4kwtKTLCt+RVqbz9i68O3+Zbj0caJAZ2ZySNyOquDIdK/gMA53d1NjZWs8mf2FBdaBV
         FlpyVGVok3d5DTgiQUBOYihDLrFrWXAHGo6dUbuEuyzm4D1G3qRTZ4m/Tak8uOOeJ/qu
         fP8Lgyq35EZ5Ti9aPsvgA+Zpd4KYzXUZxlq15jnLzxyW9MEQAW2GSNoCxRksaaeS6V3f
         sBuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=uqJmpXDtzLBWNlelQWuVA7iDRDyZ/qRljFOmlSAAnn0=;
        b=MqivMDWOLLzPNs1laX8YgVJ+ggMhpEyt4F6/wV1v2Fk7dt5hLNSMyNX7VxbNic+1nt
         gQYC4MLdNfR8hBX4U7+XmwOcpKfGggKVxYB9oKndMY8GtTTqgqway+jzd7/GK508VaPZ
         Ys7hM/Lm/lXsNjqIDnXizxqs1BfZCcM2tGkesDMm6rCQQZ7LeXf5sN3a8CcLUwQdmIzb
         hKzHx3SnPjq6i6zR9YAz4EnMnI4pU1Tjn8QRgs3XeaFHOymEVs9kiG43DnKY7WURLeSC
         R1BmenwYLb14P0MO3rwAvddz/kQAPL0DLYwL4bHnuZRTnIr154NNca8rC+fevGN7gDUQ
         tkDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NqDbh2O8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor38595607pgs.55.2019.07.30.13.57.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 13:57:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NqDbh2O8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=uqJmpXDtzLBWNlelQWuVA7iDRDyZ/qRljFOmlSAAnn0=;
        b=NqDbh2O85KBLGJwB95wfPrIlnecdhR2uQrPFwjpUkrDdeCEBoZOXuXAUHe9xcOwYdE
         7eTcvJNfUnCdUWexszZcf+DvLJ1OdISQx9CQRlfNBJFR5U3aSpeH6jy6URKtMpx1OLef
         QBBW/iq2fVyiwN5P9A3tVS9c80X+Pm16kPgexkp66bPV/A+6Kgkew/ofKlAUO9uUcrBI
         efgD3JxOO564hLodKPUr4nYTImYgmOwz7byaI7fdBHyYEDVv9DOLlYMm/yNrkjJ65wAs
         OFPF8ZW5FFPq4B1VlhQdTxfzAuDPHjJnAdP2T2CYXiO2DNiigyO64i83I8LN5jSVO5Ug
         lc+w==
X-Google-Smtp-Source: APXvYqwcRbMlDK99ar4exlWQ05oz6IdyB0wpqZP985LoMg3ICsxtQKsx77BzPQMx87QOkdoFN7DPKQ==
X-Received: by 2002:a63:1:: with SMTP id 1mr45751834pga.162.1564520228384;
        Tue, 30 Jul 2019 13:57:08 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 137sm80565678pfz.112.2019.07.30.13.57.06
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 13:57:07 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-xfs@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v4 0/3] mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Tue, 30 Jul 2019 13:57:02 -0700
Message-Id: <20190730205705.9018-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Changes since v3:

* Fixed an unused variable warning in siw_mem.c

Changes since v2:

* Critical bug fix: remove a stray "break;" from the new routine.

Changes since v1:

* Instead of providing __put_user_pages(), add an argument to
  put_user_pages_dirty_lock(), and delete put_user_pages_dirty().
  This is based on the following points:

    1. Lots of call sites become simpler if a bool is passed
    into put_user_page*(), instead of making the call site
    choose which put_user_page*() variant to call.

    2. Christoph Hellwig's observation that set_page_dirty_lock()
    is usually correct, and set_page_dirty() is usually a
    bug, or at least questionable, within a put_user_page*()
    calling chain.

* Added the Infiniband driver back to the patch series, because it is
  a caller of put_user_pages_dirty_lock().

Unchanged parts from the v1 cover letter (except for the diffstat):

Notes about the remaining patches to come:

There are about 50+ patches in my tree [2], and I'll be sending out the
remaining ones in a few more groups:

    * The block/bio related changes (Jerome mostly wrote those, but I've
      had to move stuff around extensively, and add a little code)

    * mm/ changes

    * other subsystem patches

    * an RFC that shows the current state of the tracking patch set. That
      can only be applied after all call sites are converted, but it's
      good to get an early look at it.

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

John Hubbard (3):
  mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
  drivers/gpu/drm/via: convert put_page() to put_user_page*()
  net/xdp: convert put_page() to put_user_page*()

 drivers/gpu/drm/via/via_dmablit.c          |  10 +-
 drivers/infiniband/core/umem.c             |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |   5 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c        |  10 +-
 include/linux/mm.h                         |   5 +-
 mm/gup.c                                   | 115 +++++++++------------
 net/xdp/xdp_umem.c                         |   9 +-
 9 files changed, 61 insertions(+), 108 deletions(-)

-- 
2.22.0

