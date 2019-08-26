Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCECCC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB99821883
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB99821883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AF636B0565; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 338EB6B0567; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24EC46B0568; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id F31BA6B0565
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:16:43 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A8891181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:43 +0000 (UTC)
X-FDA: 75864326286.11.bird55_1d96a15e4d217
X-HE-Tag: bird55_1d96a15e4d217
X-Filterd-Recvd-Size: 2196
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:43 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 84FD5AC26;
	Mon, 26 Aug 2019 11:16:41 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-btrfs@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/2] guarantee natural alignment for kmalloc()
Date: Mon, 26 Aug 2019 13:16:25 +0200
Message-Id: <20190826111627.7505-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After a while, here's v2 of the series, also discussed at LSF/MM [1].
I've updated the documentation bits and expanded changelog. Also measured
effect on SLOB, and found it to be within noise. That required first addi=
ng
some accounting for SLOB, which I believe is useful in general, so that
became Patch 1. All other details are in Patch 2 changelog.

[1] https://lwn.net/Articles/787740/

Vlastimil Babka (2):
  mm, sl[ou]b: improve memory accounting
  mm, sl[aou]b: guarantee natural alignment for kmalloc(power-of-two)

 Documentation/core-api/memory-allocation.rst |  4 ++
 include/linux/slab.h                         |  4 ++
 mm/slab_common.c                             | 19 +++++-
 mm/slob.c                                    | 62 +++++++++++++++-----
 mm/slub.c                                    | 14 ++++-
 5 files changed, 82 insertions(+), 21 deletions(-)

--=20
2.22.1


