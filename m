Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C922C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 19:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 505D1208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 19:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 505D1208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA10D6B0003; Fri, 21 Jun 2019 15:38:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51458E0002; Fri, 21 Jun 2019 15:38:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F108E0001; Fri, 21 Jun 2019 15:38:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A13446B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 15:38:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so9094302qtp.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 12:38:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qgcjky2l4JJkw7iPeyudfbSTntlU4iGJoy411DV78HU=;
        b=QI6rs7V0qq0AxXx/6IhSiYd2JoAonDwudNfiQadKEzO732Pwq7ABPyVk9FXpBahyT9
         8Vdb4Yf1qpdIbqeZnlVPFZYbAlMLpLxRcK/eRKnYXtZvJ4KpOhFRbnMtKdVzOzimTNl8
         ffUk/hC3pIkk0/SbaajrwiDZQ6LgaklboHsp02YF8nYYe0zr3xUs6MvY5/xftEFu/2Ct
         VDBM+95+4ROOmABMiVEndTgjPrF6/teEAGftXSqyd4WasGcOKP4pZSmiP39DUIEXNmnR
         iO3uC08l98Eidt2a7l7k8Wneo6iDSjxuGsmHbVAU8El4DpfAh4FcFL/lJLCPQMH7PQf8
         Lvcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW+2cbyXpkrt0OjCEY9obUKeFnIviEmMJXJwyVKhOEJrpEA1ltP
	NHeL5abg2ogZfGKLSNvP9yn5srVzJNGMmDMTzLDKUNOrtIRxXfrw/bdVFidCmaDNREoziywMlsk
	rXT0iZOGtXw39oA0pknarLx+5uuGzPIHNw60zOOBGi1eJAqZqyk7TEFEcFUSr+HFA+Q==
X-Received: by 2002:ac8:17ac:: with SMTP id o41mr46163861qtj.184.1561145923427;
        Fri, 21 Jun 2019 12:38:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5zafyh1JFWjab48qYDbhhXQAQqozeiFhFb7qCPmhO/VKUFx1jgJUvNB041AI++67oeVAi
X-Received: by 2002:ac8:17ac:: with SMTP id o41mr46163829qtj.184.1561145922754;
        Fri, 21 Jun 2019 12:38:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561145922; cv=none;
        d=google.com; s=arc-20160816;
        b=Va3eK/iAraMyoAaTsmT7bVq0ryTrBhuNe43JU33uJRjDh9RBH/729woUHRvIla9aes
         KK0Q6DciiijcyLr7MOTi1ctWra7/1yK03khxvDra6Ym+x85gohdb5IUua3ww4MTfc+Ok
         KtjggxXcN0vZFJxfGBAvZhwDIjcxmBurh+Ec7FHO2c5AIK+DQUol/hu+wfLIJIqFZ5fG
         57cmWHRKdNagcwDfhOL9BDNTgm375dvBXieeWrMK0jnzGeZZO58GefINTZLFcjYfdr6P
         DIsryFkvEH9IP3jKO1PrIMAqpRmcUCH6YRHlLCkOICwteYzwlV2h5Cnn5Op0Opu6igQ9
         yY5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qgcjky2l4JJkw7iPeyudfbSTntlU4iGJoy411DV78HU=;
        b=DbiZc4bMQkTy/Jl9UEhrgKui7GoNVJYo2hLeWTO3uM+WO9KZlEH22RqpcJuxNYkH8R
         TgVxocknIDi2SyjuLltUypmRzbI77IaLGgJdQLaTcMNvmIpgaPE4gdsJZAMYzEYcuTrA
         mDztW7IIJt/IF9s5+aK4ieej2O7RN5Dg09Q/an6fz9ZKG2YNeu5knjvvd7PN3QicG8Qw
         X5MgVysu69HM/iKuAzLG1zaBicp29x0e07czY9Ait+TakGGx/5Wy5NpoIsdiujK1vmvq
         R0SxG5QrSvdsAJ4ZuSfIUHY/czRRecdJrR8zCR11azmK66DooZdNm8no10UC81Tel92Q
         m+gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si2302224qki.325.2019.06.21.12.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 12:38:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 74EA23082E21;
	Fri, 21 Jun 2019 19:38:40 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-40.ams2.redhat.com [10.36.116.40])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9F5D419C59;
	Fri, 21 Jun 2019 19:38:35 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] drivers/base/memory.c: Fix "mm/memory_hotplug: Move and simplify walk_memory_blocks()"
Date: Fri, 21 Jun 2019 21:38:34 +0200
Message-Id: <20190621193834.21730-1-david@redhat.com>
In-Reply-To: <1561130120.5154.47.camel@lca.pw>
References: <1561130120.5154.47.camel@lca.pw>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 21 Jun 2019 19:38:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The start and the size are 0 for online nodes without any memory. Avoid
the underflow, resulting in a very long loop and soft lockups.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: linux-mm@kvack.org
Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

@Andrew, Stephen - sorry for the noise *again*. Feel feel to either apply
this patch or drop the respective patches for now.

---
 drivers/base/memory.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 972c5336bebf..7595a4f0068f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -868,6 +868,9 @@ int walk_memory_blocks(unsigned long start, unsigned long size,
 	unsigned long block_id;
 	int ret = 0;
 
+	if (!size)
+		return 0;
+
 	for (block_id = start_block_id; block_id <= end_block_id; block_id++) {
 		mem = find_memory_block_by_id(block_id);
 		if (!mem)
-- 
2.21.0

