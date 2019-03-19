Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B440FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7916E2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7916E2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A53746B000C; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F87B6B0007; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BFA26B000C; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1303D6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p4so112604edd.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YhEnIqCavVt6SwF55Ols042rQ/lBzw+OT1XOU0MPciQ=;
        b=nWro9nazYtPg8kO+pZk+c6sh+rAnd0SehjyynTJTL0noeEgQ73K0EaAqkyymfHJMzt
         L+UNeLNdrv2ClVb+vP/wsdzWEjI/FZUN1vsX9wuCf1CY57Y5eoNA3rxvA8OitBzmNHnA
         eDIecPrAL5+UUn6xUI1KFunAEHc+kTvB2aD3cXZV3AgZcXuBlAssSO3P89SI3afxVa8v
         NyCj81l+TKU6Hf2jybhCPNJvLllkT7MAdAM4fmB3hGZxm2DQZ6FCCD4y7YeoN3RsiySU
         fpGr0wDhBYEdoNMvqLtbJwOdQlGAbGqNjydyHmRxN8H4a3sgCcR0n/Ox2UMMwXqnnh0n
         Hpyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUkBHq/cHVuW16gsVFhicO7O6ksCRLXDSs8LigigR3lVWYtmYvV
	+MkQ4dvp0gauWKJhDPPi0v2AHKrI8g6a2DcR0cqoFcqrnCC9CGcwuzCinPLbFy0NFbXeYjf2RNi
	JHRzAAgvP5xcWF9smeKpN74+Y52zOmpmxVDDYTOGvhb+ZlHQO/JRea5+ukGqtbl4coQ==
X-Received: by 2002:a17:906:c50:: with SMTP id t16mr7875175ejf.97.1553029889533;
        Tue, 19 Mar 2019 14:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOgX33k+35cNrEqYxvLptyKO/ETRzEijXS2qXxqov6WcWAJYeX/nPXawggNlVvu3YiRQvm
X-Received: by 2002:a17:906:c50:: with SMTP id t16mr7875154ejf.97.1553029888534;
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553029888; cv=none;
        d=google.com; s=arc-20160816;
        b=fMZ8CHKu5LcmvuUnXR44J626C8dlfQu14PJqCFlBidfPNBzYxpB0MB1YYpQxOEcqHC
         CwRtofBIL/Kzktg9I9XFUOe4iiKp2g3JRC4um5AsV57QidlSFeOj6i5y1UVZ75bJUdOF
         9U4bkfk0QMTKju6oNzSiyDSIdGBB3b24fV7H3LDvkxqeHuPZtCavkO+RS/EfWMWW4V2S
         K1jtbitwiq1MOpUHcClg9KxGnSusbqlT3L1XvuAPy63v5SoYv+B8kK3p5H1AeqZeovsA
         IX0sQWwdGACQFX71KL+HEM92EVEbo1BlG2JMHLRi7JeDx8ddOqWJ71Yv92kCvzKLcpyV
         wTKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YhEnIqCavVt6SwF55Ols042rQ/lBzw+OT1XOU0MPciQ=;
        b=oGpPcWX+hti61FgLGba3HrI02QT+NjX27EmT+wZ7iSocugfAJw+LNl2qLrSBFNpigt
         ko1z1NXxOUA2l9p9e5wFliLt71JzTANQhkLVBokbyDhcRmXM9BhagtrKLXpTInnxgo5H
         nLslzDiagWPH47OOM7vK+XfedabtkS1stVsMgOgexAz5xWjT4+wx6mOBjNTj+YY0s7TD
         +rD2VIcfWEr24aLwKDu0+GRoRSorYmsAnFFVxIztrdKsmPyzsRm04HRqbZxYCBDUsKiY
         wbdbSj29HLXgpyWDOw69Y00G+WAYQEPerujKpUhD29um8lKQ7ROhq2/qzC/jmgcNswvQ
         H6YA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19si2545834ejd.1.2019.03.19.14.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9655EB606;
	Tue, 19 Mar 2019 21:11:27 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>,
	Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org,
	linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/2] mm, sl[aou]b: test whether kmalloc() alignment works as expected
Date: Tue, 19 Mar 2019 22:11:08 +0100
Message-Id: <20190319211108.15495-3-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190319211108.15495-1-vbabka@suse.cz>
References: <20190319211108.15495-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quick and dirty init test that kmalloc() alignment works as expected for
power-of-two sizes after the previous patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab_common.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index e591d5688558..de10ca9640e0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1621,3 +1621,22 @@ int should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 	return 0;
 }
 ALLOW_ERROR_INJECTION(should_failslab, ERRNO);
+
+static int __init slab_kmalloc_test(void)
+{
+	int i;
+
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+		unsigned int size = 1 << i;
+		void * obj = kmalloc(size, GFP_KERNEL);
+		unsigned long objaddr = (unsigned long) obj;
+
+		printk("Size %u obj %px alignment: %s", size, obj,
+			(((objaddr & (size - 1)) == 0) ? "OK" : "WRONG"));
+		kfree(obj);
+	}
+
+	return 0;
+}
+
+__initcall(slab_kmalloc_test);
-- 
2.21.0

