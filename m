Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EABE0C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:39:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC2B221721
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:39:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC2B221721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A3D66B0006; Fri, 30 Aug 2019 08:39:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 554916B0008; Fri, 30 Aug 2019 08:39:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46A026B000A; Fri, 30 Aug 2019 08:39:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1E56B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:39:48 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C0FDD1F841
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:39:47 +0000 (UTC)
X-FDA: 75879050814.09.crown34_7294002f4b131
X-HE-Tag: crown34_7294002f4b131
X-Filterd-Recvd-Size: 1821
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:39:47 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 29395B667;
	Fri, 30 Aug 2019 12:39:46 +0000 (UTC)
Date: Fri, 30 Aug 2019 14:39:45 +0200
From: David Disseldorp <ddiss@suse.de>
To: linux-mm@kvack.org
Cc: henryburns@google.com
Subject: zsmalloc build fails without CONFIG_COMPACTION
Message-ID: <20190830143945.223ebf94@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm hitting this build failure with today's master
(26538100499460ee81546a0dc8d6f14f5151d427):

  CC      mm/zsmalloc.o
In file included from ./include/linux/mmzone.h:10:0,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/umh.h:4,
                 from ./include/linux/kmod.h:9,
                 from ./include/linux/module.h:13,
                 from mm/zsmalloc.c:33:
mm/zsmalloc.c: In function =E2=80=98zs_create_pool=E2=80=99:
mm/zsmalloc.c:2415:27: error: =E2=80=98struct zs_pool=E2=80=99 has no membe=
r named =E2=80=98migration_wait=E2=80=99
  init_waitqueue_head(&pool->migration_wait);
                           ^
./include/linux/wait.h:67:26: note: in definition of macro =E2=80=98init_wa=
itqueue_head=E2=80=99
   __init_waitqueue_head((wq_head), #wq_head, &__key);  \
                          ^~~~~~~
make[1]: *** [scripts/Makefile.build:281: mm/zsmalloc.o] Error 1
make: *** [Makefile:1083: mm] Error 2

It looks like this is due to:
701d678599d0 ("mm/zsmalloc.c: fix race condition in zs_destroy_pool")

Cheers, David

