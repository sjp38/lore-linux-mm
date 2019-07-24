Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E05DAC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 991F42080C
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KG/F7Sd5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 991F42080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BA746B0008; Wed, 24 Jul 2019 00:25:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56EB98E0003; Wed, 24 Jul 2019 00:25:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BC2D8E0002; Wed, 24 Jul 2019 00:25:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 046FD6B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so27703181pfi.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qETbyvDGXmWMmkqN4sOdgKXeFkWOntX3r/NRFgCZoWE=;
        b=DD46X764HHYPsE34H9S4xbCzeiyJ9FbvBTgaIPeWErqbli2yyV1quVla7+p9C38jLb
         V0xLxK6wL+j/ie9x1818mKuorLrC7/O/I0SED9nhQ8JldUy0pJ5QjmMecbKspEa/OdHf
         I0dklYFKreUhXPosTPRhcOsvmbFJ2c63Zz19cWMvny6Bp3TjThkCgo57iGOwVQ/0iCKf
         Gwnfpf30nnX3jtSxoHIYjmG6WzWU0akntdpVGn2WMaoVtWo6Oaf36anMqcXD1rLx8ozY
         fVCwwOMgVZKruhjPm3Yhwoq7lblRbQiJBH6XkiiMknGCMwSwXRMhJlxXFvy882m469mc
         dcmw==
X-Gm-Message-State: APjAAAVaH7oA5Tmka1R8U05v8U8WssyvreUNOjtQMgoL2JS0/8Yb0z2e
	FnbPmXjFui76xArNxG8QRNSZHkrapd1kCIzCiFruxWwjcsMQG3pFidPEPDbFQ+3BUwgckOP6ZCw
	rHoc0JdQ2HFgp93SnLS+Y4QVQa2ZIFUKDcF89uFvAYxAv02KDl0dnAT1rfM/FuC57DA==
X-Received: by 2002:a17:902:26c:: with SMTP id 99mr86698470plc.215.1563942325620;
        Tue, 23 Jul 2019 21:25:25 -0700 (PDT)
X-Received: by 2002:a17:902:26c:: with SMTP id 99mr86698413plc.215.1563942324527;
        Tue, 23 Jul 2019 21:25:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942324; cv=none;
        d=google.com; s=arc-20160816;
        b=yAal7Fk0xmXAv+NVdA6h7H9x1mV9eBwCHsaemOCd1yCIchcdk+MNfVONmiBLvYHMkX
         1xOXrO/jk3bETnNUclDyG+2IhRfrZGxjV71RwDhS/u/FLiObwLEOgD6lydcNqi+y76zc
         pH+LB6b9OzFVWm9N9QzVgQbUty+Fa/Gy+zFixnKPNXtNH8SZwohR/MWvzqgvFhKX0jEt
         3gLIXhB5yqf+lupZf9oDPk+rx7+KSJtnxYjKez1zLFPb4DMZjUinRaWfc6T/+LQp2gi9
         bTdG+pcdqSso4+whbQOTrKpLCFT2GMkPuAN0jEVeRLlj62JDaKnxxOWmqNGPtldlZ7gE
         jT0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qETbyvDGXmWMmkqN4sOdgKXeFkWOntX3r/NRFgCZoWE=;
        b=S4Qu2rs1cYqZiClN6cpoUTixXqiOP7bOZs8DawCDRtvXX9o1ctVfrE7Y//cc0g4+qM
         VZYkfoyGHr/50jB+HDTyB41gt5yczmD/Tu8iDRCPkUPTGO5VQ2LZNxNogkZZnf27Oe7k
         LhE4sUJkVm3ORIJ6diGEGVGArEj6hl/NpTaVxoov8EIFps27RQMaXPzN73otij8Nt7yM
         2n3zlY8r7VwmATaN/p1p0+kt0hIUcQTDrh8ZkGhHJS0Yof0gNeSiCQuDAgOMxdDAAhfp
         bFASM575Kx6z6RFmoXulm9TBMi+Ci20Ly1I6Eq8Cn9XG7hZ/LoMNFEfPNF/t3xKw+0XM
         IAGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KG/F7Sd5";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s129sor18351375pgs.62.2019.07.23.21.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KG/F7Sd5";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qETbyvDGXmWMmkqN4sOdgKXeFkWOntX3r/NRFgCZoWE=;
        b=KG/F7Sd5J79dEipElYhdvyhMIk0TxQlRtZu9bi85rUwY/TE5KUGgUZYMnF+3jcDsXr
         jk+YAZfWVg6gnp2IiqLCse5lUUZrgh27wRKMfQRWXUdRnaO5ZlXDztHkfwCA1gRbK+Qa
         Vdl/mcDwYDvc/aIthkQn3dHIfadxoz9OGVoTMkITstrb8gRinr4GRivAlsVYAzJkRXx3
         qijzZ8AyOYgc5Vk4JND+9sG/qLIVyx5s39WeHO+RM9Ey6ODD5O8kuqfL85vwwK9Febym
         eFolpJZ4Wkv3lsIz5mVKSWu4wewrN05ykT4POz6d2Mi/mkYtEQg5LGvW/0qsyHcM4WB5
         F1og==
X-Google-Smtp-Source: APXvYqxkwpMUKWSZK/4NQcFDw+bDP7yRS/NluRzHQboqTdh3aehK42NKuj/IACv1wat7jP2wWUy+ng==
X-Received: by 2002:a65:4489:: with SMTP id l9mr81979980pgq.207.1563942324157;
        Tue, 23 Jul 2019 21:25:24 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:23 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>
Subject: [PATCH 02/12] iov_iter: add helper to test if an iter would use GUP v2
Date: Tue, 23 Jul 2019 21:25:08 -0700
Message-Id: <20190724042518.14363-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Add a helper to test if call to iov_iter_get_pages*() with a given
iter would result in calls to GUP (get_user_pages*()). We want to
use different tracking of page references if they are coming from
GUP (get_user_pages*()) and thus  we need to know when GUP is used
for a given iter.

Changes since Jérôme's original patch:

* iov_iter_get_pages_use_gup(): do not return true for the ITER_PIPE
case, because iov_iter_get_pages() calls pipe_get_pages(), which in
turn uses get_page(), not get_user_pages().

* Remove some obsolete code, as part of rebasing onto Linux 5.3.

* Fix up the kerneldoc comment to "Return:" rather than "Returns:",
and a few other grammatical tweaks.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
---
 include/linux/uio.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index ab5f523bc0df..2a179af8e5a7 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -86,6 +86,17 @@ static inline unsigned char iov_iter_rw(const struct iov_iter *i)
 	return i->type & (READ | WRITE);
 }
 
+/**
+ * iov_iter_get_pages_use_gup - report if iov_iter_get_pages(i) uses GUP
+ * @i: iterator
+ * Return: true if a call to iov_iter_get_pages*() with the iter provided in
+ *          the argument would result in the use of get_user_pages*()
+ */
+static inline bool iov_iter_get_pages_use_gup(const struct iov_iter *i)
+{
+	return iov_iter_type(i) == ITER_IOVEC;
+}
+
 /*
  * Total number of bytes covered by an iovec.
  *
-- 
2.22.0

