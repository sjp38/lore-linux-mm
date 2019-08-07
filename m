Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7084BC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 423B62086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 423B62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF6DB6B026D; Wed,  7 Aug 2019 02:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6FB6B026E; Wed,  7 Aug 2019 02:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBD4F6B026F; Wed,  7 Aug 2019 02:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFBD06B026D
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:37 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c79so78370780qkg.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=emOCY78+qYrPzYEsa6BTu0t1qLH1xOVvjmlFjmRfsdo=;
        b=DGqaaTOTMZG/wabUdNuxVj+/KAfRIwOSIT0JNrA4Dh7rKW87kNp5LGQ7apzAU7ki/t
         C+v2AQ4q2jQFuTwE1Rj3ivTyoq87nZu+aJBWsEe0yuQ/txjL+Z4BADq7+1NH7WYo/Adi
         6UeHoEbFYRiXDQQ1Ml2EUnJfAxkY+GCrZFhDql+lYd9YWJFtdy8Rtpug0GhB44c0AW2p
         vDc4dib4fWqNHkSvM2vR7Q6eIO8AyJ8BToRomHZ0IDG4e56m25byqY8spfvITdtwAwa/
         jvZay2a2SuZunn1Prqk7JVAbS1UBBZh6NqpD3rDSmZ+O3uhaO/7NruJf0O3cY/GBMxnB
         KA2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWIm4ZsPPeAn4Vo/6uIKbX+rD/mmoyDO7giv2t+DEqxzvF/uYP1
	T/UaDNtOxF0KX+xugUUekqSOVhW3UpGYVmw6+8mNLUU8GTf0hEEWmqW+WON0YWbuMM1IRmXTHjN
	Az8z8E6mFXD77fMaRX/0pReDhlDTV4hYOLk5dMihkhMpgn+JTzNApxeKfp2fKrNN2ow==
X-Received: by 2002:ac8:303c:: with SMTP id f57mr6686390qte.294.1565160937477;
        Tue, 06 Aug 2019 23:55:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+963/9CYiJLJEN+oo82DAjX9IsQ2GooXmYoF/BlSmsM9aHpNbqJtjS3xwsE5NW6Xp2Lb4
X-Received: by 2002:ac8:303c:: with SMTP id f57mr6686361qte.294.1565160936805;
        Tue, 06 Aug 2019 23:55:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160936; cv=none;
        d=google.com; s=arc-20160816;
        b=V21BUfmd3AArW6HTkRf+5MrcSOu9yMaVrVjNWAjt5yP6n2g5lS5F/RW7FvgGw0tww0
         PUnQuWsspLVOSaEUor5NXMh9XdELkE5OyXlUBLvg21Nigt6JjfSrcLQwhXf9NNttTsH4
         7VZqcNyzebQn0HZQvZH6jZiY8TfUOyx2+7VyjDQmjsZYPxqXg2k0cJDcplTQxTTNKet2
         q9B2iUbdUIIZ8I+0VQky3Wpt2QXUsLDfBvq7B9cmNCSiOqGtWul4k5W+XR7Rrxuodvct
         g0BQ3pfgl2/dn0rzTyq4i075VJoeLpYWiuzeqpvWEJE69CSnXCcv+/fX0m7sUrxkfUYp
         oGLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=emOCY78+qYrPzYEsa6BTu0t1qLH1xOVvjmlFjmRfsdo=;
        b=ah7KqDW7X7fmv4SuI1RA+JCyvhR1xDooqedk6OFpNJmTk0KFzIouRCeq+BoIfhHRVv
         QmTXHQzqfxBQGnMpVYCxwWUAlNasFdLKSDfl5CC10E8rUxyMoVm4FpvlV55M9avtBRsz
         dE58wvSYAYR1t9WHjQGJhRoeX7TSz7wicTPlnTzDeWjbrnau0SUQY1lNEXnYaF4jakhu
         dhN8v+GahSsn8XF6se76yqz0iXPMjt7eNpL5zYLk0AxARlpVYwmLL0EUvsgZcLpQwkFT
         +gYUHZoXx8eEbsPfDZVhQ09CKVUaW/qHxRcUvAKDvapdlOYhAF5PdXZ0uMYcj+g2Qgkn
         RB2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v46si26467838qvc.97.2019.08.06.23.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 10D5614AFAA;
	Wed,  7 Aug 2019 06:55:36 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2D84A1001938;
	Wed,  7 Aug 2019 06:55:30 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 09/10] vhost: correctly set dirty pages in MMU notifiers callback
Date: Wed,  7 Aug 2019 02:54:48 -0400
Message-Id: <20190807065449.23373-10-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 07 Aug 2019 06:55:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We need make sure there's no reference on the map before trying to
mark set dirty pages.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 57bfbb60d960..6650a3ff88c1 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -410,14 +410,13 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 	++vq->invalidate_count;
 
 	map = vq->maps[index];
-	if (map) {
-		vhost_set_map_dirty(vq, map, index);
+	if (map)
 		vq->maps[index] = NULL;
-	}
 	spin_unlock(&vq->mmu_lock);
 
 	if (map) {
 		vhost_vq_sync_access(vq);
+		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
 }
-- 
2.18.1

