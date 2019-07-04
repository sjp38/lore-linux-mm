Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B58B9C46482
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 13:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6057D21850
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 13:31:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sXnIoQC+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6057D21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983F66B0003; Thu,  4 Jul 2019 09:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FD0E8E0003; Thu,  4 Jul 2019 09:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED8D8E0001; Thu,  4 Jul 2019 09:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 485916B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 09:31:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w5so3754288pgs.5
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 06:31:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=T7rWNTi1E7hTeWQY3QnrdEdcklqFz+mTRT0ti6i3yOE=;
        b=sTM2+tjCF192S4Am2ge/2k2feLwifFdGuMIfKQASCBH7/HEGeTvDD6vXtHJdtVuqYT
         E5cX5/VabB4KVczr/xG/X7UoK49bvtonank2+l42dYodv5aYuqApkHCD5kZUtkP7X/st
         DgCjCblrTvdAgNCNGqt/baSoP+9S26aNX2W1I8o0FnIwpV+8K5OEO9d24Zb2J20swJB2
         6MFjjJDSEBcrZ670x5e7WbeXwjGFDouqP73tefVXZEGl/ey/mNWgxn1ptZUkKtFTVFUG
         nOzov2QoObrqH7324oGanmSBqfYJMY+hiY0jlFRLp2xkqU6Duu+YIEFwRKgpKbpjzS6I
         T3rw==
X-Gm-Message-State: APjAAAXVRz/4hM8tRs1j/5QPr8bZWKz/EAEL+xhKZPNCaBYU9UwaKpzS
	3X3YFPfd9MCV5OuWBDAdTZ3B0AosmqiDO+MHdJNksBXy+hfhCarPp9F0ixP0HYA9Uqw9lVQCMBL
	LRHcTMHk0Pqlp0G8lV8GEZKR26YCuFr1RUxXYUJ+5VdoV+w4kas3k8Ta4EGs+Ar6pwg==
X-Received: by 2002:a17:90a:2648:: with SMTP id l66mr19522113pje.65.1562247060880;
        Thu, 04 Jul 2019 06:31:00 -0700 (PDT)
X-Received: by 2002:a17:90a:2648:: with SMTP id l66mr19522022pje.65.1562247059792;
        Thu, 04 Jul 2019 06:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562247059; cv=none;
        d=google.com; s=arc-20160816;
        b=wXANZ95G3vlAkQ0pwfozWF5wRfJE48dlkljB3anA6wcUxKIADd9NaG8TRu01aavnkV
         XBDMaDvLQPlxFeEcycAAU794xIz6/Kil5M8+CIBhpE4Zok2doqVQP5LDNRZuEUzP1UqF
         la9ZsF4z2AOtNn79bzPY4Q2cw1FXfka0eFDjwdGvCy3hPHeJz4VXFRrzKQp7lpzA+ka8
         HLm9k44ZurVlKMvhdWdG/hdaO2Ouo77k1/GRpDjdg3I0lKxyNzEMaQ/emf9rKJU2I2pp
         yvI04av9wq9qhLjRrg1QwgNaCDWR9UTyXwRwNuCR5zpugEXCTtl76O9RH4CNfqH0y5H+
         0GFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=T7rWNTi1E7hTeWQY3QnrdEdcklqFz+mTRT0ti6i3yOE=;
        b=lOj8sicE78Fg9CJFgop65DslK0ORGCPEmEKrVYMRj2awcfqGpu4dgvHQSuwBJ3HOCg
         34wKhPFYRp5fTl/FqjXc7P7RhaIk5AjoeLlqSwHoVUO1/MRo/NFoy/Zw7xpNcjHF5pO+
         BE7ojLyVzkECJGK3CLNfoizTAJ95ozAPtKu5+QlhKFI2CQt8P+oMqnIqCmCWX5oHGjS7
         bCDMBrEZVxXEmTJR3hJWVNCcCs+5eQPXKxTJekz4q8cTQk3CkwpEFu+77VKzysumHPEA
         TbCLGvAANnI8V0aBT8YDU1mH4mVMQeNMhK6CO0RxxhBbg+wGaHURkecTpzB7sW16HjrI
         QsIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sXnIoQC+;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w24sor6819554plq.4.2019.07.04.06.30.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jul 2019 06:30:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sXnIoQC+;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=T7rWNTi1E7hTeWQY3QnrdEdcklqFz+mTRT0ti6i3yOE=;
        b=sXnIoQC+a7Tp+ha4YF6+8hVuxOYjc/an3avVApFlkpwWWfbXtZgkdZ6lUnMCqAyxza
         JtWvhS5buGGMbRS5wPpm0u/kBRoCElF6LHAqyef3Qd2o+EpxepLOU8zQF3S4DkC7Wz0o
         I1k1xme567aV15OHMlTzldlKgejxfdjqkqFhz6Mt5UlBXGMIU2CEiq94i3rw3VPMikuU
         pgDlIJswlcJ0Pwpoz1RlVhN28GHwlUq0L3zu6aQpcNET8QspamP3MKPK6jH8F1bSLJnp
         16CTZE0WYpHjyF4EYVZZ8D6AnONWtWRnfwfWa44SUA2Whg3FpI5Xd23f/QxEZ7EauQCC
         F/ww==
X-Google-Smtp-Source: APXvYqwqYSyuN2HHjZcixXdS2u2w049iaOAV3EmisamSxAwJucP6UsEqXY/v1VVYeIkmhogul62i8g==
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr49317115plt.248.1562247059375;
        Thu, 04 Jul 2019 06:30:59 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id h26sm12517367pfq.64.2019.07.04.06.30.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 06:30:58 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v3 0/1] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Thu,  4 Jul 2019 21:30:39 +0800
Message-Id: <20190704133040.5623-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v2 -> v3:
* patch 1-4: Abandoned
* patch 5:
  - Eliminate "flags" (suggested by Uladzislau Rezki)
  - Based on https://lkml.org/lkml/2019/6/6/455
    and https://lkml.org/lkml/2019/7/3/661

v1 -> v2:
* patch 3: Rename __find_vmap_area to __search_va_in_busy_tree
           instead of __search_va_from_busy_tree.
* patch 5: Add motivation and necessary test data to the commit
           message.
* patch 5: Let va->flags use only some low bits of va_start
           instead of completely overwriting va_start.

The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Pengfei Li (1):
  Modify struct vmap_area to reduce its size

 include/linux/vmalloc.h | 20 +++++++++++++-------
 mm/vmalloc.c            | 24 ++++++++++--------------
 2 files changed, 23 insertions(+), 21 deletions(-)

-- 
2.21.0

