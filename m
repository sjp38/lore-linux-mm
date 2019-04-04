Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B981C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 214EB206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="aToAwocn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 214EB206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A39FC6B000D; Thu,  4 Apr 2019 03:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EAE26B0266; Thu,  4 Apr 2019 03:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903BE6B0269; Thu,  4 Apr 2019 03:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5F86B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:24:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d33so1233503pla.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=xx8VzHLiibMcDula0s0X91k44Awqbt6B1nRWsay/e1I=;
        b=Szq4hooE5heiiz3Sf9D+L8v/uXmZVdOpqPVlvwLQvebhXkvYjnyc/zUb7qtJ9ORti6
         j0jBO9w0DP4AQ5a7c+7UkwLBUzOXvwoJmUrVufHUCPRisS23TU1wDO1C2237lsXWanrJ
         nOZsxWFZ0/7TFN1j46/If5wj8k4+qHbqFCQjKU908Gc/caN8/cqEn6zMDpbdYQMIjJcn
         5yBU5/XvOwuwsAe7DtuExf1NTjYh3tb08SbmPRUrLl4HClaVlJJ6Wesub5mqBnCsi2ZU
         qG6ZOgzbsrxPdw7Kwgl+KS7p20t5melnNij9Xgu995CHAe2J9VkjqZK2xc2FDosyDkML
         70rw==
X-Gm-Message-State: APjAAAWqkVnqt+BDuE7MKGoHP4Bn/j1I8kHSfdY2CGE2jOd7Kiae9v6T
	0bBvaFs0P4bMPWUWv1HA4xPkUAPhk7Mw5P+J9lvljgulnkgleOJ3s2YhP0zIVXQtQLetIw8vc0J
	Daauqj42hX/nH6snXpLJ1Ki24uxNrA5SVgZiWXCo5V+Lhx4LxZ8lcMcIYbDLtKt6f8w==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr4285456pgr.411.1554362643613;
        Thu, 04 Apr 2019 00:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyastaRgBlsg/jxq7GmfzVuXwF3lc4qtIYw7uZ7xeq35KWOgVY05VP7b1SjfbrUWCnilfXg
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr4285396pgr.411.1554362642470;
        Thu, 04 Apr 2019 00:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554362642; cv=none;
        d=google.com; s=arc-20160816;
        b=V0sHLOH0cuLUlNmONXHntJnBK2WGdy/iWCppzxiX0tB8UCJ2UgtoEIutfOoSWEc7ep
         fPMofHz2W97lg+UgE7B8yPMam5CcnGCZxb2Rmouab42Rd6H3nn9s+y0XSGdWC+x0aTrK
         r4vblr6P7aui5iTZdbz31QJe0/nZF/UsF3kT329TiDXOZz93v3FJnri/wF6kQn8wExmZ
         QBGca6eJQieGyG8gWAXMa6q2Y7TNnI3rJDBOs3uCkKiZTxGaOkH1zgTmQAcs48gV1gCG
         XpXpMtcowjQ7hJB1OKfGPqxU2OJ6ub35tkbdhjIKdoZ6Ez10N0xI1h0ZNGDIkIOvOAUO
         2ENg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=xx8VzHLiibMcDula0s0X91k44Awqbt6B1nRWsay/e1I=;
        b=reQqeeszVf6LuqNIv4sEC7cQfX7EN2JeQcG3PLIfOWIFxPSOdwAEXUhNKOGYzqyZAG
         wxq2DQYJRb3yJqYx1CTkGiAKCerDwu4/yrE8ZwVpUITF6tLV+ezMErovdvviY49nyNOQ
         kUA9G4OmGpjUdP9gptaUy6AjGPVfW2gaUPnXTU2heZYlHyMh8tAMhdYK1cvsQ3gG6FYi
         9SlQtSEKNKl8n/u1JdTQgs4f2nmTNEazzBeokr6kEVO8UlewxbkqHyu0R6/acrR+QDY/
         bYO+Q8WT4QDUVrccagGSzudfi3qYbA0w1lIrVKh64JZxmlX3S+UmldKi7SyvuG5D6Cna
         kQCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=aToAwocn;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id w7si9700417plp.341.2019.04.04.00.24.01
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 00:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=aToAwocn;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-773ff700000078a3-3a-5ca5b10f9ea3
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id E2.73.30883.F01B5AC5; Thu,  4 Apr 2019 15:23:59 +0800 (HKT)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554362639; h=from:subject:to:date:message-id;
	bh=xx8VzHLiibMcDula0s0X91k44Awqbt6B1nRWsay/e1I=;
	b=aToAwocnWLp6XN3hzTRRF7P4iGhB++m9K7y0l7+EMVvqrTgOUWvR9VtHyviIauiOyQm0dDC+4rk
	yaZJUnW93dnWEu4d3Rhi5/AnTCgRFNXB0zMu2xLk48h9iFvxYD9cr3NQ6+Iy3oNM0vwPgblRQfYO6
	yDdzj+jMmBTil8ykwho=
Received: from hsj-Precision-5520.iluvatar.local (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Thu, 4 Apr 2019 15:23:59 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: <akpm@linux-foundation.org>
CC: <ira.weiny@intel.com>, <sfr@canb.auug.org.au>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Huang Shijie <sjhuang@iluvatar.ai>
Subject: [PATCH] mm/gup.c: fix the wrong comments
Date: Thu, 4 Apr 2019 15:23:47 +0800
Message-ID: <20190404072347.3440-1-sjhuang@iluvatar.ai>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-102.iluvatar.local (10.101.1.102) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFjrALMWRmVeSWpSXmKPExsXClcqYpsu/cWmMweweHYs569ewWex/+pzF
	4vKuOWwW99b8Z7XYuvcquwOrR+ONG2wei/e8ZPLY9GkSu8eJGb9ZPD5vkgtgjeKySUnNySxL
	LdK3S+DK2Nu4hLlgOV/FttYvrA2Mq7m7GDk5JARMJH70/GTqYuTiEBI4wSgx4d8CRpAEs4CE
	xMEXL5hBbBaBt0wSx+Z4QxS1Mkm0PVjEBJJgE9CQmHviLliRiIC8RNOXR+wgRcwCvYwS9xqm
	gRUJCxhK7Fz1n62LkQNokorEnaNiIGFeAXOJG+0vWSGukJdYveEAM0RcUOLkzCcsIOVCAgoS
	L1ZqQZQoSSzZO4sJwi6U+P7yLssERoFZSE6dhaR7ASPTKkb+4tx0vcyc0rLEksQivcTMTYyQ
	YE3cwXij86XeIUYBDkYlHt4fq5fECLEmlhVX5h5ilOBgVhLhdX0NFOJNSaysSi3Kjy8qzUkt
	PsQozcGiJM5bNtEkRkggPbEkNTs1tSC1CCbLxMEp1cCksJnNyiHsLO8EfgfPOK77U2wTDJ+x
	tJ3bV7j/4ea9Hms7TQITbwWc0nKSulCw6Se/Q5LvwZx/y6zlVO7OW7546yrjddtr1Q6/fWAv
	+vy6i4rLi0tSay+qHVhk8mDu3bYX8aEJGWdtvzGs5zL+usg/stV4Rnf2zzPyJxtNa+YWKAqY
	siQ86P562pM5Mn7NevcpecuinMvlp3wXrtP5H/Zo6kVjuevuZ65efpL/R3q/4ryLx1kmfpM3
	5y0S/X/0zr0ZUoaSSdvS/Axfh5/embH87YYioXitas+9fy8K/LD245lmzsxdIK2ovLJkk8uf
	m4lahgfCm9n4RTMEtGfPtjdXk4iaI6LxNev/QibXV6eVWIozEg21mIuKEwEEoaWG0wIAAA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
get_user_pages_fast().

In the following scenario, we will may meet the bug in the DMA case:
	    .....................
	    get_user_pages_fast(start,,, pages);
	        ......
	    sg_alloc_table_from_pages(, pages, ...);
	    .....................

The root cause is that sg_alloc_table_from_pages() requires the
page order to keep the same as it used in the user space, but
get_user_pages_fast() will mess it up.

So change the comments, and make it more clear for the driver
users.

Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
---
 mm/gup.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 22acdd0f79ff..b810d15d4db9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1129,10 +1129,6 @@ EXPORT_SYMBOL(get_user_pages_locked);
  *  with:
  *
  *      get_user_pages_unlocked(tsk, mm, ..., pages);
- *
- * It is functionally equivalent to get_user_pages_fast so
- * get_user_pages_fast should be used instead if specific gup_flags
- * (e.g. FOLL_FORCE) are not required.
  */
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
@@ -2147,6 +2143,10 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * If not successful, it will fall back to taking the lock and
  * calling get_user_pages().
  *
+ * This function is different from the get_user_pages_unlocked():
+ *      The @pages may has different page order with the result
+ *      got by get_user_pages_unlocked().
+ *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
-- 
2.17.1

