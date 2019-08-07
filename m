Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27A60C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC59D219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC59D219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9336B000E; Wed,  7 Aug 2019 03:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9593E6B0010; Wed,  7 Aug 2019 03:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86E166B0269; Wed,  7 Aug 2019 03:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6469B6B000E
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:37 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c79so78394967qkg.13
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xahfPfm1mZfbC4QuU9FoOa3rgOujgUARqGYj2KI+pdA=;
        b=VwagXuDKAdwblMrSwfDGtH21TQ4cj1kam0gsslZ83FbhcfS51WIBoxvZ82OP533qpe
         GK0B9uuO+dK3WFxdWbdq72URSwLSzYvTPn28uPBjMLSA3wmLxNrlIuip42igYEwAQ0PY
         udBCXSIggWDNelhtpDNaPnEvS+HoNWz97bFdARgSwcFR9G3oYdI9a6Y+bjfuYxkjI5S9
         VXQ+gQBu598t/ouHkPI+H3jY2H3PWon49Fmqhnw6OkP5dC/s6aDnTw5TAcB+5C4lj3mT
         T5rUJiHSBrJtxtqkwMVtUfyjmiYBK94soPmSXuohApW6+qZSsU2qtA5UR47vTBK/FDXF
         4yVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkS9qy3f0mM6V0Ze2fP6iXg3kx0uAzU0NppaC7XC3zulhTcr1Y
	qGfncOeWWpiypogek8im5QR6Xx61cSkA0ze+iVQKAiwRqt2My1+kQcbFFR3ktp8xJ08uvLpqKTK
	SWaZxXS1Xo5YhVLDEt8TK9TKa9aLdwLP3WvbB47eRBn7ZZhiBxbc+TIje41cvEvnRKQ==
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr6580835qve.151.1565161597222;
        Wed, 07 Aug 2019 00:06:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEOfpxuDNXSc5NL8XP3uKbWtB9i7GOGlOT2L89pkNe2FrzTptK6g371bcqjUTZe/w71aRK
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr6580815qve.151.1565161596603;
        Wed, 07 Aug 2019 00:06:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161596; cv=none;
        d=google.com; s=arc-20160816;
        b=WvxW8AKn5jLed0z4/XmXRZHVd6jwIVLGwZ6ZysZtwBTg2k3t30oqVEH0R0wVnYmWAw
         KQtO5Gy+E9lI1bokVOnwGJ5lPvMgpnoknu0jUdICYtqCucExWRvuaypeWL2QLyTDyZJX
         KcvJ+tCadxZtmUuAoPkd8UyK7kNGcfOWv5GR0zo8y24BZjypSzl8iVRU6WdagaeA6hmG
         LFcs9lkPU4GiYkGboZqUe0T9Vf/xJFMVkx8uCjvnWLzn6ruR2TcJutXSDyYjPdG8pk65
         GDpi7dzbtkMcWFMtcVZRdVFmbSqL2+SAmX05CPVZhqSQzgGJGP9u8RkvJ8xkW2ZeYXaQ
         fBkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xahfPfm1mZfbC4QuU9FoOa3rgOujgUARqGYj2KI+pdA=;
        b=leabaW6Go9ECZ8gb2OHYrdKo+I/H98/vN1AfATQB/gFh75K6Qh6wKe2Zsl4j2pmRSY
         8759+X7VEu4SK2qSPkuYLHQJkUb6ndi6ViqArnnGxEYvFyD9sZ9E0HlN70w8A8fSy8E7
         jh9ic9djGzKzG3f29fi8LBAFB6tjKG+PLwFPIr1wTPfS4MK2g3HNPM9Rk48EOpnsVCPz
         zHj6bpPT6StyfJV20W1pdPf16+zyuBzK4hT8M4/dWjeAE4D+sSdHTFbgA70igKWefCFM
         iy6o2gas0tOdJ2Bbok3vfUfSPWkiLOz5Q1r+BIgdXaCycgGJzhZnqVs8My806Mc0V9Is
         2RWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h20si14986299qtb.397.2019.08.07.00.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D614730DD076;
	Wed,  7 Aug 2019 07:06:35 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 583AF1001284;
	Wed,  7 Aug 2019 07:06:33 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 4/9] vhost: reset invalidate_count in vhost_set_vring_num_addr()
Date: Wed,  7 Aug 2019 03:06:12 -0400
Message-Id: <20190807070617.23716-5-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 07 Aug 2019 07:06:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The vhost_set_vring_num_addr() could be called in the middle of
invalidate_range_start() and invalidate_range_end(). If we don't reset
invalidate_count after the un-registering of MMU notifier, the
invalidate_cont will run out of sync (e.g never reach zero). This will
in fact disable the fast accessor path. Fixing by reset the count to
zero.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Reported-by: Jason Gunthorpe <jgg@mellanox.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2a3154976277..2a7217c33668 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2073,6 +2073,10 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
 		d->has_notifier = false;
 	}
 
+	/* reset invalidate_count in case we are in the middle of
+	 * invalidate_start() and invalidate_end().
+	 */
+	vq->invalidate_count = 0;
 	vhost_uninit_vq_maps(vq);
 #endif
 
-- 
2.18.1

