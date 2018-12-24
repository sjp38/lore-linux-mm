Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AA3BC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C447221850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:24:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GDuxmq/A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C447221850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 655508E000B; Mon, 24 Dec 2018 08:24:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62CCE8E0001; Mon, 24 Dec 2018 08:24:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51CDD8E000B; Mon, 24 Dec 2018 08:24:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9638E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:24:40 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so9950899plb.1
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:24:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=5oYSW/GvpO5Jr2lAVUEKxgPmdiaC90t9yQ4KohCOQbY=;
        b=j2WpOBFxB4Fuh5k3+hK5AEeLnP1i+zXodYel36K8a1msHKlkRU1WQhg7OifZP18VpI
         uhBjGVMKdb7EGur0OGjH1lsQ4N+GpojReJpYsOXUsvXe+uHRsJ1u60T+cTcPdzozBaW7
         iZZHHwDpEM7SswH65/KULgv5YksvxeI8+RQP4Q9gDWDnDYrCso2kYl30/jyM0rN4qQ4/
         id+Si1EApwSiD0vXEourfNU/6Kchd7VkFSYg38YbmbDj7NOJ8Dlb4HLh5ituU3a6u3YX
         BROAgeBrm1orPzmTBdffmHW+HAkAV3P6WUg3NcbAsKhNWg8vbPf92bX3Xy7VMMAybUpx
         wCoA==
X-Gm-Message-State: AJcUukc1Yjlfj6JgbVlvpY5ZjM7h0xRWXsKLVfjmtAF51nFe3Z1V7Tm/
	CXpBtsKfidhiUFP21aErA0VSStLqdYeN8OYVCP2mZJwONHmVKWHIXbW1PeigQiltjmLzXP6I0IV
	JARXH1dFbKmcIyXZiWImfoTpbkVzANGvi0SeApvfK1VN7dePnCbzZP+mO0biPj2jrOulLfSkYF1
	ybqK4sCedOtVSBwTTzAAtotO/I/34GfrcGQhFkPEgIMs96pULxLmm7DVwEz+P20BNTg03lL1vlC
	0SMaVyhQzqnAq6a/5YbIwFqH7nOWKaTg1oGW5a+uFo10/5AH6JUOnjP//VXf8C0lKMob871mwtW
	tnMm58i0QTAem2RKlPjHIaGOSp9o9B672+O+4OApZEWm9pVFdlHwuIDQN8G4qnaOJjoWVuY/qGz
	5
X-Received: by 2002:a63:6f0d:: with SMTP id k13mr12193776pgc.42.1545657879744;
        Mon, 24 Dec 2018 05:24:39 -0800 (PST)
X-Received: by 2002:a63:6f0d:: with SMTP id k13mr12193737pgc.42.1545657878905;
        Mon, 24 Dec 2018 05:24:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657878; cv=none;
        d=google.com; s=arc-20160816;
        b=CQMUUqp0nIDhU8s/I7OP3qSVidpNg+ghYV/Yl/VAoQ7ne2DdvsBa8pji9UquNuE9H5
         pUCjFiqBw4zRMwwiFvdQ5tbF1jHKrpAaoWC7RhUgxXuXzQGt6E8JihBNNoXzztuHeB2F
         THI/powYYJLyc7ub2LyVOAPoO0lsO9zS9vjiDvjjWAKUkYxmT3RNzjwwmsMne5ybMwlg
         lgKJ3O3xPqQU3t5IjzO62f/awVR0GK/SjS+ZUBjUopUeLQCVpup1P1Ag+rw+mS6weV5q
         8MQIQSO6zFMcLS4tOTk9q976iR3+IJcBy0PEZ20OxNrhpi7iDEp4wJAUCC0cxYIl9ono
         VR+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=5oYSW/GvpO5Jr2lAVUEKxgPmdiaC90t9yQ4KohCOQbY=;
        b=UjvCIz9y62/eSo7qqA9ITENjYW9jNPm4XUum4dL4o5BYPhsGiUKjfpJjtdvNpDJYAe
         pcS0YF9EmYhTFhFkOP2/rxaOMhGe4SnJEqQbVUo+cHaYB5cMY92lS2oss6MQlY3gx7tb
         NCdIDcyD612R97RfKoR4vXPyp/FzmWaBraHVt1NisM5of4hfBo5AbpGSGKOxg8/goom+
         1oTWQofAndtZxcJuwIp72hflkM89iyxYt4CIX2y+gk0+B58LffC/e9Il8e43vKSTegX2
         neMc/GDO+FHbJPJSWoSJSQG4dejUJMAh7Kc7x39iTVFFW+xMoYA5ijL5uq6VNoXr73FF
         ivvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GDuxmq/A";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor51659368pfj.7.2018.12.24.05.24.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:24:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GDuxmq/A";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=5oYSW/GvpO5Jr2lAVUEKxgPmdiaC90t9yQ4KohCOQbY=;
        b=GDuxmq/Aic15WMXOQMH4HrSFG0stmPhzQGi79maKq+afi8zw5IjbX4WO7EBtU4Y4Aa
         es7qIcOpTYJ4MljVBfAKdeTApaICyrUwH9OHwTSRD29kMCYJUvUrqfFRTtWBCFSDVNaB
         D+08WqR+rmVKV+OBhkdgasAMMBrRM3dftytU94MpNoljNyFWIQC5SLE3qv2rEmBJP1iY
         PlWL494kqT4wHJc9k0khQ6jPK4JiFTqKXalJHhj9TcvGX63+U/1VnAEr5HTgPK+1/Old
         8ZWRZQjCT44ajiLNhJX8FmB02uUMM09edQpVw7rX6LARSq6srEeuDlG8Z8hUmpKJre3P
         rPuA==
X-Google-Smtp-Source: ALg8bN7MqKdlBoEyyvA+3qDEze8cTZiGRFINTLDBE/Qm6sZIoDhaLCAuk2cAeM0YMez3riWsyZJJLA==
X-Received: by 2002:a62:9111:: with SMTP id l17mr13092429pfe.200.1545657878185;
        Mon, 24 Dec 2018 05:24:38 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id v9sm44373114pfe.49.2018.12.24.05.24.36
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:24:37 -0800 (PST)
Date: Mon, 24 Dec 2018 18:58:34 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v5 9/9] xen/privcmd-buf.c: Convert to use vm_insert_range
Message-ID: <20181224132834.GA22203@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132834.uUw0aTuLVn2YlCbhC4TiIYnK1nPATEBgZnlfBsakcuQ@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/privcmd-buf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
index df1ed37..d31b837 100644
--- a/drivers/xen/privcmd-buf.c
+++ b/drivers/xen/privcmd-buf.c
@@ -180,12 +180,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
 	if (vma_priv->n_pages != count)
 		ret = -ENOMEM;
 	else
-		for (i = 0; i < vma_priv->n_pages; i++) {
-			ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
-					     vma_priv->pages[i]);
-			if (ret)
-				break;
-		}
+		ret = vm_insert_range(vma, vma->vm_start, vma_priv->pages,
+					vma_priv->n_pages);
 
 	if (ret)
 		privcmd_buf_vmapriv_free(vma_priv);
-- 
1.9.1

