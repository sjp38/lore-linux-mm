Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CCB5C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6558220675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6558220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E81758E0004; Wed,  6 Mar 2019 02:18:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E09318E0001; Wed,  6 Mar 2019 02:18:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAB938E0004; Wed,  6 Mar 2019 02:18:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4488E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 02:18:26 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v67so9072754qkl.22
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 23:18:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=I7i8KSWluUccJGvvitm/nvSYW6LlPlWoYjbi3a/+f3A=;
        b=WVFM0bQMWDwM+U7ULMcNeAfOyPsOWyv4sMjy+ZGqPL/BmY874ymipaVvibIBGIEjRW
         nWmVtZOzLtU74tN9k8JTAS1sTcarOqZRYkwG88L3Zd9+tbNa8SfTu5Su03uq8iVNgo95
         2n0+7lZVct9NhMQbC63jS7Sy73Lrdqj/RplOjvruN1DgoU1ZJoK9LsHDctgwJy5kAPDC
         msxCU1xNrmN8skiIUTRn2aBlwNa9iQtfXOVzW89tg8iK6rWftKa8qJ2iLWlxvlgEkqEX
         zOD3qfqzl2Ymi6NESAPBh7m0De7647vj3ZpfnK7jjKExu6yhbvic1Jywv951k7JXlINg
         DspQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXX/eHhBzKMShWb0EjKmSWe66fDA/Cf0cpVj4MLRum0kWe2w+7Y
	nL3Vlz0mhJ/j0sLkW//+vPrzx7qGYwzpqWzgqMtvoFw2xzwEjI3rX9kBL01TRWuKuGsiIuMIuvJ
	BS7oipxfxtYyPpma1xNUQTJXml+iF/wNyBGB6BpwB+fHyzYpEr0J47/kiPBb355tTeg==
X-Received: by 2002:aed:2a2f:: with SMTP id c44mr4642570qtd.144.1551856706427;
        Tue, 05 Mar 2019 23:18:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqyFefWBdACfEIePNLStFkIAw1BPNLBfcUw0n+jrvnifsNw1KzfnKZg1HIcQ2+yPSS4prgSA
X-Received: by 2002:aed:2a2f:: with SMTP id c44mr4642539qtd.144.1551856705615;
        Tue, 05 Mar 2019 23:18:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551856705; cv=none;
        d=google.com; s=arc-20160816;
        b=Yl/q2ePhYU6KvPzJlctAzfT6pLQ5sViGuBWXPzA5D5zERY4jFeNuW44X4LzB2cFWcf
         KnYGehfZZomQmhwV1pxRxrJC1PanPi1LxctpcsflL1UFwf4tXRTeXeuKWlNd4FcFe57y
         VLoDqmdjuEcUSSJq+FV/WZYUyopqVU8WNac2SZDfwxNhu/nSFnf0r4YLVRQOTgrqQO3L
         x0ImlnaGzXjEuYaGhcPuXlOkfyogC/Eyr30eIm0e4pGVtfIJZCnO9FMBoD8l1zV2nDRY
         fKcoQqm6QyYkkLjvqNsluT1re5qimcB0DGmmna1nOh+qpFF7Bv5ry4j8/WhMXc6Ng8Nt
         OBag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=I7i8KSWluUccJGvvitm/nvSYW6LlPlWoYjbi3a/+f3A=;
        b=v5ZLP6fvZDxNwlHdItRoOidpXwDVG3tDtrIBWZL7SPNRPI75mENrupBdWOjFzZHOcC
         5/BKu63KDg8FWr3zcgnm+xIKZFecpK8exKbM9qWk8kjNcU/C/SGZmNCuIUpqFF0yh5VS
         fPkQZDFjvi+khEvDwpr2s3ffnXQQ08P33mce89VQ4KIVB3a7SuK8AzU+u5PPrKU5qT9J
         06fqpCE6iHsuPCCNgsbqZp0Qr2Q9R0IXZp85blp2LzUwYzQZeFHOd1RMgMyTIBbtrIh8
         X1HH2vkQ8Punz2ir60h61dQvFSSJAnaTjQlqg/kzH28N4W0me/JjJGO93oDCakMEz3aW
         CWWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t63si499720qkh.271.2019.03.05.23.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 23:18:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E10C1C057F31;
	Wed,  6 Mar 2019 07:18:24 +0000 (UTC)
Received: from hp-dl380pg8-02.lab.eng.pek2.redhat.com (hp-dl380pg8-02.lab.eng.pek2.redhat.com [10.73.8.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D7524600C5;
	Wed,  6 Mar 2019 07:18:21 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: jasowang@redhat.com,
	mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	linux-mm@kvack.org,
	aarcange@redhat.com
Subject: [RFC PATCH V2 1/5] vhost: generalize adding used elem
Date: Wed,  6 Mar 2019 02:18:08 -0500
Message-Id: <1551856692-3384-2-git-send-email-jasowang@redhat.com>
In-Reply-To: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 06 Mar 2019 07:18:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use one generic vhost_copy_to_user() instead of two dedicated
accessor. This will simplify the conversion to fine grain
accessors. About 2% improvement of PPS were seen during vitio-user
txonly test.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index a2e5dc7..400aa78 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2251,16 +2251,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 	start = vq->last_used_idx & (vq->num - 1);
 	used = vq->used->ring + start;
-	if (count == 1) {
-		if (vhost_put_user(vq, heads[0].id, &used->id)) {
-			vq_err(vq, "Failed to write used id");
-			return -EFAULT;
-		}
-		if (vhost_put_user(vq, heads[0].len, &used->len)) {
-			vq_err(vq, "Failed to write used len");
-			return -EFAULT;
-		}
-	} else if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
+	if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
-- 
1.8.3.1

