Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7107AC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AAA62086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AAA62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D81416B000C; Wed,  7 Aug 2019 02:55:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D31E56B000D; Wed,  7 Aug 2019 02:55:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C21156B000E; Wed,  7 Aug 2019 02:55:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA3F46B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q9so2006682qtp.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=tUjASA4+zAgItkGVuRA5d1D5k4PSp8myjrUvNkD8hTA=;
        b=XnMz2QpXlNVFNORaYOzKAUjr60+gsmbSyJYW9R7TGMEyE4x6jvir/teOMKnTRoixMp
         PD1Qmg8SWJRTNeEqimmUBRQApJsLw75JDQpfJcO2x8bIG4HRoHl8UC7QAIRLqGOMIDlB
         IADutRihuQuznObm/dnn03630wmuMKylgZzPInUO5Q8f0zWguR3bPvb+okBYcS60ZIHG
         ecrJgKqqijAvqmDEk8zVgIAGutE5PhM9FG/6d7UsQrbfsT2TTxkD4eJt/8Yb1UH3XuN7
         Ru/Hhp3aB9wsonJ9S7Pz4eMz+tjK7vNn2cgWkR1OCbT6ahOqEFynbkEO6Y6DkxdzNzy/
         PikA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZEI9dZQfJVmap2nVev6mD47tlRDgbWYLc9LabJrYG163QUmrQ
	0cXXAIwG83Bxk+ZlWHr36O32stN8ipH9KNaojI5/ht4h9d+fMs9sotBELKG5IMx0SSaSSU3g2e3
	ZlfSn/5IDjCFV5uzdTRqfSkboLItwuebUuWUeUofSThBr9lxx+Hg9ubxYR2nqVTpZpQ==
X-Received: by 2002:a37:6397:: with SMTP id x145mr6467493qkb.56.1565160905483;
        Tue, 06 Aug 2019 23:55:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwq/kTCBl39z7Gt+MFt7SeOGnp02gbJC1Kr16+jeRYGq/6M+9B1cN7bbdCTSBw7l2p4kmDD
X-Received: by 2002:a37:6397:: with SMTP id x145mr6467477qkb.56.1565160904918;
        Tue, 06 Aug 2019 23:55:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160904; cv=none;
        d=google.com; s=arc-20160816;
        b=Kg3E8zXKbLc0b53ja4pp9ibmrKO6TZy0lVYe4NdPJsvKQG2viZxp6JCZaGru7jxGEr
         l8xtJcaNJC14CT/gg/B18S15UXlaagpyvLhr5bTHMQ0RUyNaZPy8hoo36mj9kkRXejDH
         WjnCNALSi+Cl2NlBHwb0JHWm17iQGiXrCP83PCeORDTSbBrsrIoKS4hfZkeSGscS2vUA
         pLk6eaopRjmdkcEMpMOOfX5NDdwI3zJrbj2qP/MT1XDHfxdBbFTz5pysIcT4lI/zYtQO
         kDLtm6GyhManx1RnPEvaPPuDCCd/aKaErJifTUthQewkBHnhXHdjTN/6CiQrIrY0Jnfc
         qzbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=tUjASA4+zAgItkGVuRA5d1D5k4PSp8myjrUvNkD8hTA=;
        b=nPm2k9W1+gcK6QB5w8yGB/kAzfBnNorlrAYkjNemNOCRpQ/98rDRuD1wfKSdbcIlrP
         Lu+nmXI2lKJXJVvw0dgO7rayqIFrIzpKx3MunESNBL02Aha4GKvuEE6wswy33Sn5/tz0
         AjMnHBaj3PmvZ6IGrZwDR8o520cu3xxuN6DdDcaBhRaqEspW4oiss6VUyWtE5B3UUGf7
         Otj0F7Txueedm1tYN/mMnUeAjV8CNzvGcHgGrzKeqEfmMtF8KWlOjK103P0xw+T8SLQh
         Rb+TuAeu69rfo9YmlcssN82UWXwFyLwh93ZJAZqf/hzxRI1vYfkym59GiY/RD7C48quK
         ZwyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d49si52962193qta.198.2019.08.06.23.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2297C9B28F;
	Wed,  7 Aug 2019 06:55:04 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CB6001001281;
	Wed,  7 Aug 2019 06:55:01 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V3 01/10] vhost: disable metadata prefetch optimization
Date: Wed,  7 Aug 2019 02:54:40 -0400
Message-Id: <20190807065449.23373-2-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 07 Aug 2019 06:55:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Michael S. Tsirkin" <mst@redhat.com>

This seems to cause guest and host memory corruption.
Disable for now until we get a better handle on that.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 819296332913..42a8c2a13ab1 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -96,7 +96,7 @@ struct vhost_uaddr {
 };
 
 #if defined(CONFIG_MMU_NOTIFIER) && ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 0
-#define VHOST_ARCH_CAN_ACCEL_UACCESS 1
+#define VHOST_ARCH_CAN_ACCEL_UACCESS 0
 #else
 #define VHOST_ARCH_CAN_ACCEL_UACCESS 0
 #endif
-- 
2.18.1

