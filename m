Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1012DC43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C4B2173B
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YVxuP3Qw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C4B2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AD1A6B0007; Sat,  7 Sep 2019 13:25:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 783E26B0008; Sat,  7 Sep 2019 13:25:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 699FA6B000A; Sat,  7 Sep 2019 13:25:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4992F6B0007
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 13:25:17 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E899045C1
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:16 +0000 (UTC)
X-FDA: 75908800632.05.order75_10f3bff610156
X-HE-Tag: order75_10f3bff610156
X-Filterd-Recvd-Size: 5847
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:16 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id w6so7549655oie.11
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 10:25:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=rtCJ9oXMvzyqzSO/6+XMP8VFA+c1bypJ2A9Wi4tC2B0=;
        b=YVxuP3Qw60ve+K16OV/2OTXTVXsnZSGiw8yXWOnvCSAPW2RJsbvv9esY2jbVJk+MTd
         gZaFZgeUDSH31cxpn+4ACT+RtrLyEzlpB9CSFSKqcLbBdu5k7zv4t9ddGWWi0TGCGwiu
         gFWbCI/pIFOqwAWmWO0aBRiIEO3n1vCRrqraKqGz8fVFzLWJMKaeT4nkP76nJ9dVqS5M
         mGxpfLI0pp+7NdvVFdGAITNx/Whl+E8KWWUR6DpIaXjDSmYY2Hh+szZWNaDpLgznhs4Y
         DGw/CpIO4ALtMzKoFiREaJMW+0Vo1vWKa+L+gYpEaIJGJWvuU4XIhs/WSIDDM2sUHuCP
         a9dA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=rtCJ9oXMvzyqzSO/6+XMP8VFA+c1bypJ2A9Wi4tC2B0=;
        b=KrdQM60hYglQtJ0l4ALKmlG2kcm+9D482HQzCk0+0JPgDnZhESeEzpL+GYayWYgsQ7
         fxgrYaaXPFVznGdN37z1fmFdenZ5mE7+i2QOIt7A/povBkWCtYexQBLRTmV7yHZaNTvs
         kWMd3wSsdiMBzXRX5+pkIeULB882YxXp9p92FA9dcwu6WKCqDpG2qYiHkVMMhtfcVLSp
         f15obnEvrmsSlBU7k2iI4X3aIkJ3cE9XyOIpl+Zt6tb3xy/5cZntaDYNQN9tUg1L1cqi
         6YcdzQT2TB+QkG6tUVVe+qRW9bzyoixOAlGgHbihjqTMh2Tw/wzrUdUjyhQEH/Ns/tpA
         Nxrw==
X-Gm-Message-State: APjAAAXVLDpJlUXc+4Rp6EUnJeOZbLkai6oLA1elW7Tl31QupmJMt1wF
	oU936daddy8DqjIKJEJh9mY=
X-Google-Smtp-Source: APXvYqx76pbWI8aVf7Yn3gxH+LEAS1HoAzYWQhYG1OYCBkmvO+49isQhgNq9dB292v9n9IEZQlObWg==
X-Received: by 2002:aca:b388:: with SMTP id c130mr12021078oif.27.1567877115467;
        Sat, 07 Sep 2019 10:25:15 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id h5sm3898728oth.29.2019.09.07.10.25.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Sep 2019 10:25:15 -0700 (PDT)
Subject: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 alexander.h.duyck@linux.intel.com, kirill.shutemov@linux.intel.com
Date: Sat, 07 Sep 2019 10:25:12 -0700
Message-ID: <20190907172512.10910.74435.stgit@localhost.localdomain>
In-Reply-To: <20190907172225.10910.34302.stgit@localhost.localdomain>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Change the logic used to generate randomness in the suffle path so that we
can avoid cache line bouncing. The previous logic was sharing the offset
and entropy word between all CPUs. As such this can result in cache line
bouncing and will ultimately hurt performance when enabled.

To resolve this I have moved to a per-cpu logic for maintaining a unsigned
long containing some amount of bits, and an offset value for which bit we
can use for entropy with each call.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/shuffle.c |   33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..9ba542ecf335 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -183,25 +183,38 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 		shuffle_zone(z);
 }
 
+struct batched_bit_entropy {
+	unsigned long entropy_bool;
+	int position;
+};
+
+static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
+
 void add_to_free_area_random(struct page *page, struct free_area *area,
 		int migratetype)
 {
-	static u64 rand;
-	static u8 rand_bits;
+	struct batched_bit_entropy *batch;
+	unsigned long entropy;
+	int position;
 
 	/*
-	 * The lack of locking is deliberate. If 2 threads race to
-	 * update the rand state it just adds to the entropy.
+	 * We shouldn't need to disable IRQs as the only caller is
+	 * __free_one_page and it should only be called with the zone lock
+	 * held and either from IRQ context or with local IRQs disabled.
 	 */
-	if (rand_bits == 0) {
-		rand_bits = 64;
-		rand = get_random_u64();
+	batch = raw_cpu_ptr(&batched_entropy_bool);
+	position = batch->position;
+
+	if (--position < 0) {
+		batch->entropy_bool = get_random_long();
+		position = BITS_PER_LONG - 1;
 	}
 
-	if (rand & 1)
+	batch->position = position;
+	entropy = batch->entropy_bool;
+
+	if (1ul & (entropy >> position))
 		add_to_free_area(page, area, migratetype);
 	else
 		add_to_free_area_tail(page, area, migratetype);
-	rand_bits--;
-	rand >>= 1;
 }


