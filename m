Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51635C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E57D2173E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E57D2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0BC6B000E; Fri,  9 Aug 2019 01:49:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A718D6B0010; Fri,  9 Aug 2019 01:49:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9874F6B0266; Fri,  9 Aug 2019 01:49:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7935F6B000E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c79so84927121qkg.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=PlSWhLHnt2mdBUi0c+gQNi7f4bl/m62dXyay+CX2PTFHqk+ttozhAXT4urxg1NOIxS
         DAWXLGMMm8Q1+wGNfzfQCY1L2ZBeGkE/SPHasSsssSt2vFAzpCmqusKuf0C1geajWcyX
         zSloC3LfcRjqUeuF0lv43LiuhCtunCcGS8228lcQpwwHineoHWpSPYrug1gIph09nAXS
         obvDRoGKUSBYOT4CkEjaag1jBJOb6cH79Drz5RKXhuKsuwEl5i78r67rkkRZWiBmjgqJ
         SkYqu7xaIqKHSkBMjLw2p5Bi6B1U/pqFskIsLUuD7pajOiMfyEK8h92u9Cb8Ha1oHmxB
         aIWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWX/oGESYttmXenjmQFswWUhVlci5y2g7p/gMhbz9Te4Roa1HIE
	7EOMy0QWvNwnJGOndcqYVBl2mmcZpWhW6Bjhq4SPimi2JS3JDFZvMR+9RRMJx0bTktveYcqZPEO
	C/w7NUOdwVhmjmjQ9Nas68lXf+1V40Vr0uEeCSgmndy9lNRPJ172tbxSETpCAYPutPw==
X-Received: by 2002:a37:274a:: with SMTP id n71mr15486260qkn.448.1565329764312;
        Thu, 08 Aug 2019 22:49:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjPL1NkGVk9oMxe4EpkTOxtDo4SC8VYCgx7AsQ6V8HhdZnx3q9eKrjVCOf9mDWp2Fz2bVj
X-Received: by 2002:a37:274a:: with SMTP id n71mr15486240qkn.448.1565329763800;
        Thu, 08 Aug 2019 22:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329763; cv=none;
        d=google.com; s=arc-20160816;
        b=ePfO3ysNU3ucV57xn5QqbNk164yL7Uyt+bnlfMliO4c85IAYB1qMsTZH/lCkDvIVw4
         XvptelNvcTQFYggDqReb186M7yKj8Ki/jL91VwYVMitRtJg7fLD2CatC2Oxx5k61sbMD
         aUzy0M6C9LWNHra/QEPuuwMzamY4GL1vRuqvuT6DJv/eQVrcmmNfzr5UUnz4fyPcZY5H
         JF2vVk+5RvOJMbvyTV3Hj9jXBnWCCaWfEmZVIB5nKvs1oINqSFQV4f4mx7WsEkbAY6ba
         jTvWORpTh0TmG5ze0m2ohFnhpzNyQGRbeOPpIuieYBGCgfSSF70naVrVlfVP0tDTL+pS
         noGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=XIZMMP+4i0eI6rDLcY+qsreorwnRuM2x1pbxExqZ3ABDnJ3sQDD+xku8aP+MqpqFaO
         0EEGW1E5dLKkKNJkEy6B0uR6Z+3Httc+jRQoOTm+c00zIILpkfKvsi+XM3Rx7rtLd9D1
         OWKxzKBYCI6VX+ZDlooDDbyrOfmx/hUGKvJWOFcTIU3b7zZHbo+zNFx+2ZByyDlKHGuj
         2JsqYJ/bOZC2dOa0qJ2Ns7tRILI9eZ4YOZNB1tYam2p79Zq7RePhGb0nK5dUGdVl83fv
         o0ZaWghAqHkrwZ6IqVj+0iWWZYqOs5qVa/5owa4RcE1+mOpzBRglij5FhZ4FnggWvhEZ
         uQ1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si1663485qkl.142.2019.08.08.22.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1256B30FB8DE;
	Fri,  9 Aug 2019 05:49:23 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C064D5D9D6;
	Fri,  9 Aug 2019 05:49:16 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 6/9] vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
Date: Fri,  9 Aug 2019 01:48:48 -0400
Message-Id: <20190809054851.20118-7-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 09 Aug 2019 05:49:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There's no need for RCU synchronization in vhost_uninit_vq_maps()
since we've already serialized with readers (memory accessors). This
also avoid the possible userspace DOS through ioctl() because of the
possible high latency caused by synchronize_rcu().

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c12cdadb0855..cfc11f9ed9c9 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -333,7 +333,9 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
 	}
 	spin_unlock(&vq->mmu_lock);
 
-	synchronize_rcu();
+	/* No need for synchronize_rcu() or kfree_rcu() since we are
+	 * serialized with memory accessors (e.g vq mutex held).
+	 */
 
 	for (i = 0; i < VHOST_NUM_ADDRS; i++)
 		if (map[i])
-- 
2.18.1

