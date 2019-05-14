Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8FC0C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C02520879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C02520879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980E96B0008; Tue, 14 May 2019 09:16:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 959FC6B000A; Tue, 14 May 2019 09:16:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 848356B000C; Tue, 14 May 2019 09:16:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 382FA6B0008
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:16:59 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p3so6618999wrw.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:16:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=XOfzdfS9JDTS2x5DGGI6S8ITgh1lhmu7AKXviivuHlM=;
        b=lYhCYBcHXx0ifQ7FhG2ITFQgztO2GgG0mb2KKzoPwOFBYm0jQ7zOkFJDSaXVP7jiGd
         mFhaZcPZClI1Wbo9tpIEWhpjh/i9T2llYGVuuMZ3mGpfAxgun37DreXCzuq0YGV2MhJK
         vRcrukps8CEUZsQ0fmjUeLUPVESXETgoNyAzrtdfNiX1hkMPTi0Pd+yP1yEJGrBo5wzD
         9lCMrhre7yQvwIPdKAKFXhUhJb6uxjBeRACVkutXJbcwR/TTGU1n8yz5bC7GVxXcFkXf
         7osk2WGYC5uUX+pbQzed5QRMeL24aAI80eo9TloKIRQf7HyadyGwOCXWqvntB51w2HtK
         1+5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMyfJortgnzIpXSUaxFjHh3uDAY+9sNojwcfxPZI55pYhESf/d
	L2UzpJjQk+nZ+F/LVo9xh5m2qGQ6ebJPlyRR3PGDgXzL8NMA/MJPyo4QgOIlHVtK1looNSnEfru
	M8DdQ6vjtW2VRPIqaAnB0amJ5sBEBWBzAUE1vd/l5ze2Jww+ElHTxjpfIPpz9BTmZOA==
X-Received: by 2002:a5d:68cf:: with SMTP id p15mr21765465wrw.105.1557839818705;
        Tue, 14 May 2019 06:16:58 -0700 (PDT)
X-Received: by 2002:a5d:68cf:: with SMTP id p15mr21765377wrw.105.1557839817036;
        Tue, 14 May 2019 06:16:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839817; cv=none;
        d=google.com; s=arc-20160816;
        b=t6xi9AvzVfAf4cnO5mbbm/FXfOo+viL9NR2PP7R2xjPhruyQoc5qXxXn1krnZn8Bit
         QZK9D0vCM9DCS55zIigsWjt98pYurARGC1U21fd9vIqIDD2vIxaYv/jv6jKNtaIsJvGe
         +TQ2GcvgT3lvOwrXQ0xszBFEkVatYDu+0N+/DNAYzDhW+x8boVUMYsJbLUYpTq7UjKXa
         1iJFDqi9rNkvi+uYwhOeHrGJ6B19IM8FEbGZ8OHUwN06e2gBCSFlGQGezOW6z5m363Bp
         thE7n9/rBNcVGWY5FI1oTHgKYerNYDCnfBKcCEoZIDPNJeFnKRwVM3fWgnXakT7u8k5b
         sdLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=XOfzdfS9JDTS2x5DGGI6S8ITgh1lhmu7AKXviivuHlM=;
        b=BIA+W+u9MyjxuwGg+76THV08PvAcOnerJN8MSyTgwH5NC6YQBareZ2MdIq5E4HWACw
         uOWZ+Op7aqdE0JnlP86mQY+OvwO8acZJahNn6bCHAvQrEyGlk26OZRPgKIyYv+MA+5XC
         WEDFRGXd6zpW+Ow9orH2QjzvOnJ97VVHegyQXetk8crjajFMB8DhwyN0BuW2p58qEsuo
         0gDhGI2UDrEvQ4kxACjOJb2rttYfh9jnv1+krpwaSblabcjtC1oJ4VY99Wa2H3zQh12k
         00CFNqwRakZEePWroBc4GxN2a17cOUea8CMCCIlX2pTqA0+99VvfgJYZ8IHpPEv/pvi2
         P7UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor1623435wmk.14.2019.05.14.06.16.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:16:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzjd4S45m8QdzJ48SrXeW8o3mq0TAOS+XYFjYBtZJbI+0Eb9uL/5VQgPZcML53KJaym23myJQ==
X-Received: by 2002:a1c:f310:: with SMTP id q16mr20319455wmq.102.1557839816601;
        Tue, 14 May 2019 06:16:56 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id l12sm3350136wmj.0.2019.05.14.06.16.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Date: Tue, 14 May 2019 15:16:50 +0200
Message-Id: <20190514131654.25463-1-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By default, KSM works only on memory that is marked by madvise(). And the
only way to get around that is to either:

  * use LD_PRELOAD; or
  * patch the kernel with something like UKSM or PKSM.

Instead, lets implement a sysfs knob, which allows marking VMAs as
mergeable. This can be used manually on some task in question or by some
small userspace helper daemon.

The knob is named "force_madvise", and it is write-only. It accepts a PID
to act on. To mark the VMAs as mergeable, use:

   # echo PID > /sys/kernel/mm/ksm/force_madvise

To unmerge all the VMAs, use the same approach, prepending the PID with
the "minus" sign:

   # echo -PID > /sys/kernel/mm/ksm/force_madvise

This patchset is based on earlier Timofey's submission [1], but it doesn't
use dedicated kthread to walk through the list of tasks/VMAs. Instead,
it is up to userspace to traverse all the tasks in /proc if needed.

The previous suggestion [2] was based on amending do_anonymous_page()
handler to implement fully automatic mode, but this approach was
incorrect due to improper locking and not desired due to excessive
complexity.

The current approach just implements minimal interface and leaves the
decision on how and when to act to userspace.

Thanks.

[1] https://lore.kernel.org/patchwork/patch/1012142/
[2] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/02417.html

Oleksandr Natalenko (4):
  mm/ksm: introduce ksm_enter() helper
  mm/ksm: introduce ksm_leave() helper
  mm/ksm: introduce force_madvise knob
  mm/ksm: add force merging/unmerging documentation

 Documentation/admin-guide/mm/ksm.rst |  11 ++
 mm/ksm.c                             | 160 +++++++++++++++++++++------
 2 files changed, 137 insertions(+), 34 deletions(-)

-- 
2.21.0

