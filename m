Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA923C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BE5021E6A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BE5021E6A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FEC46B000A; Wed,  7 Aug 2019 02:55:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0936B000C; Wed,  7 Aug 2019 02:55:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F07176B000D; Wed,  7 Aug 2019 02:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2AFF6B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:02 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 41so75497650qtm.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=+Pfi8JFD6WhijRBrJVHHc8gcz0yOnQpAUmEE4+7Nm2M=;
        b=lB0lwFBS0jgmx/kiAk8Dz46CNTex6LPmDzaKbmmBTMG3nte7ukkC5ElgZ17kTNcOTK
         Lj8VK6ADXr1ZtYWGgSIv7jbi6eZ3MICSBO2UG/mOOTWuyeN4deuvKbwhp5ZIW7SKtb8y
         ZwBPezSd75mtcG0k3WkZC1oEEwJOj32qRxFqrbzb+Dn3No/Ev0ZpNdNMkpmN4y686oef
         a6qu0zQ3xtDTnILzX331b+VW8K1QP7qkqn4hgwpIAbIgxys1uqJTJBYY6dxf7C2n8QOr
         NlNqb+BYvpxCtCL3Gnjg211XEy33tW8tZYK9Y9zJPn1EoDAGVJ0yLfbrnKYeJqLPs0oC
         PVwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXqnQu0hx1FtX7UwpkL+hHFIobNYVcrCZ2sVDa5xFSKuEnd9e87
	76i52kfqIyCb2aonJAtm/42M1wK7OSeXQHIEA57pkshgVQmT+EPef/+6v+nHRlE3jwyCOGZ4LHI
	yh+GHER5+hcPcYld9tEz/VWyRNZTyaLkQp96Arvnherb7eGAIIF9pugtsqOrq10gsIg==
X-Received: by 2002:ac8:180e:: with SMTP id q14mr6625885qtj.327.1565160902654;
        Tue, 06 Aug 2019 23:55:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwndRg6y4pN22M7ZkMUbMVCdnHJ7C4/kzYSdRYsPP7jTYLC0i8oBfIEcxuaNr9AldFR46zT
X-Received: by 2002:ac8:180e:: with SMTP id q14mr6625864qtj.327.1565160902125;
        Tue, 06 Aug 2019 23:55:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160902; cv=none;
        d=google.com; s=arc-20160816;
        b=WZPdLdvXstj0HaHr6bexgRb7irpAsAeutseb8acv16Q2qXkpvGKkPlagvVzC35v/tz
         Cbatm2z5mmy1DvsqyYll9QNHqXelj3UAZQED6zD3km43bUz+kWf7IsdjGzYLrSHzuIS5
         psZgn04cjpZkdeeI99J0Ume80KjSq+N7T76PCqlue2gGtfXta+oeFkmjWSO5jahQz/7X
         u81A9Qvl+JaXBoyigUlGfO3+X7CcMlRWZxEze6lqQlR3cgjIJAujrSrPnEv2B1Nl9G+G
         VTmOp2yjp1SH3f/18U5x1s4YhW7Fpx4pZfXiW/8PSex7AiQKWjDhZc1yWwDIsYe++N6j
         PWbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=+Pfi8JFD6WhijRBrJVHHc8gcz0yOnQpAUmEE4+7Nm2M=;
        b=m0yfP1TtqpSUC9CPUZ/TVKp+1TaPAHQQxmnFjYXD5lFOlbDDjAFzwvPf1PuXfEvfVd
         ppvIjbqpwfMYokbvWxL+p28nPU/w46GumfV5/Jpj6FFPeh4hXxfFpCNltYnQVi3duivv
         ghvYJyXZG2tCZzKcp7u0TfFBLH+HeyugMuIXTz31jIYnRK+EbLUYUb18BeBoNuVwjXHB
         Ubx3H++CK9qJ0AsS3fUap0aUSRayE9biFw7TP80j1hzLgeDjCIYbkgeJ5VpSKkH+lvOu
         dEiXb++DfsDhUgiUoPUY7WZ7fXYfrIwRrB5q4LM+FDxkF94epUTWXvMbhTPiCf+2y4yk
         s+uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g37si2350523qvd.137.2019.08.06.23.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 58CDC8EA41;
	Wed,  7 Aug 2019 06:55:01 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9C5081000324;
	Wed,  7 Aug 2019 06:54:55 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 00/10] Fixes for metadata accelreation
Date: Wed,  7 Aug 2019 02:54:39 -0400
Message-Id: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 07 Aug 2019 06:55:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all:

This series try to fix several issues introduced by meta data
accelreation series. Please review.

Changes from V2:
- use seqlck helper to synchronize MMU notifier with vhost worker

Changes from V1:

- try not use RCU to syncrhonize MMU notifier with vhost worker
- set dirty pages after no readers
- return -EAGAIN only when we find the range is overlapped with
  metadata

Jason Wang (9):
  vhost: don't set uaddr for invalid address
  vhost: validate MMU notifier registration
  vhost: fix vhost map leak
  vhost: reset invalidate_count in vhost_set_vring_num_addr()
  vhost: mark dirty pages during map uninit
  vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
  vhost: do not use RCU to synchronize MMU notifier with worker
  vhost: correctly set dirty pages in MMU notifiers callback
  vhost: do not return -EAGAIN for non blocking invalidation too early

Michael S. Tsirkin (1):
  vhost: disable metadata prefetch optimization

 drivers/vhost/vhost.c | 228 +++++++++++++++++++++++++++---------------
 drivers/vhost/vhost.h |  10 +-
 2 files changed, 151 insertions(+), 87 deletions(-)

-- 
2.18.1

