Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABBE8C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56D74206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:31:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56D74206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7E1E6B0003; Tue, 16 Apr 2019 08:31:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDDF76B0006; Tue, 16 Apr 2019 08:31:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA4FD6B0007; Tue, 16 Apr 2019 08:31:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69C356B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:31:53 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b12so2017349wmj.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:31:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Y/CYgzso0fI3Ij7lzAxNt+qvKgVSgCplQDjlKsz768I=;
        b=VuGnzWLM84cjnK//FLroRgbvAVTZEMDLWTAZP/nEfZFZx5EraO4WAy9CMPfxCYM/vT
         eZzuRbNizya8xad+0aWhOV52R2X/yWlj3jbehGJOg46CwQ8waWvzbiaXmmVaZwATrOuv
         PG7Mr0jNKU75iYfbNWj/uIblfVOMMXOLRivpwLJCGtJAp/Z8WtKEZZ44HaZDhieokca8
         SWBKB624EoTQZx0orvibm6NDuFRMLaS+iPuksptrdIt07PC3QO7wB4QUSNgT6p8HKsIR
         xWE0JOl+vLQWPoYcQDY/1RLdrrxfpOnkbO1wUtoebM9ui89wt5auiL43N/ZD5aVjc2MR
         wW+A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.72.192.74 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAUWv8QihPXstXI2V/zG4q6ZhaJD8fZ9WlK5QB4PjNRxd4PviB9s
	p2g6AqQ0t/YKxwLEER0rMYvb1vboHB64Q3RQH5Y2jguhjG63qbh3grQd/x9SGY/+8sYB8fNtLlk
	TAx4ByVrILrpgZobMVV/TVrXUjXdD6qSTbJMA3y6M0f9rlvGCYsem27CgyxNWrQk=
X-Received: by 2002:adf:f488:: with SMTP id l8mr50124563wro.213.1555417912765;
        Tue, 16 Apr 2019 05:31:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQoUTOv4hGfdyy03nMhjF40LicKVuWQyQ9e7Fm+c3fl7hRnIBj0nYKfa1a3bs/ywNS0UPU
X-Received: by 2002:adf:f488:: with SMTP id l8mr50124508wro.213.1555417911826;
        Tue, 16 Apr 2019 05:31:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555417911; cv=none;
        d=google.com; s=arc-20160816;
        b=kw3/fXnvlXJu9pPQI1VNoItz8H5Barcx2i19sLXDKkunAWr7ubY/8drxvH6cTXnSsT
         2TNLIUCX1LaNgPLwwcLjEktb/RTSHraxyhFqq4m8I6L9FZv/MXBUDEk/6gb2SyI8EKju
         ZnXvKu3TzpDfYmYojYvytHEtKdgn7xnQE8dshdvdPuhP55UCwERZlyHatAVcYjpzDMKj
         mvkwlFN566r/fWNWrZaFKCYhxHG3Pxms7iQBf2+qlpTJpV8/PzCDLCIUhsfCOF2lAehv
         NymbY2aSUJ3mvy+GU+/YFR9lIwAFod6KzTsPOc9zi4bH51MGKnJbFnE7bCjiSXcvv77s
         obJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Y/CYgzso0fI3Ij7lzAxNt+qvKgVSgCplQDjlKsz768I=;
        b=FpdlNDebLs9FVPd2OOVsbUT4k8zqekzjS6owq+EwRiGpuSQSY/i9KKHrz+AouhHwbf
         99PBXxi6Ac1WdkRkyX5za4A/oTiKZ3+LePAsUNK4Z0hXyN/jbkosTwnKPV0/KmzUBJvD
         uhhbAFUkoH8+sYJ1mOL2VtN4YizbtembNWaZKCnqD0hPjrk+6FzYsUgFHNJB/6zBRlrl
         Alcta7IoT3NqI7T6rXiEz1AdbrdwRrPQqivbfunYd5NakXEi9+18c5n+RlAHr/iG5tkP
         0nwOYl2Q1WPgYsK/BV5a9KG5bX72UG5Nrz2kIubj5tNsH8EVnJTDP8/I/djzV1+afqME
         4zmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.72.192.74 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id q1si35905821wrs.148.2019.04.16.05.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 05:31:51 -0700 (PDT)
Received-SPF: neutral (google.com: 217.72.192.74 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=217.72.192.74;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.72.192.74 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1Mj831-1gbHjU3m3p-00fCGB; Tue, 16 Apr 2019 14:31:50 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Vincent Whitchurch <vincent.whitchurch@axis.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] kmemleak: fix unused-function warning
Date: Tue, 16 Apr 2019 14:31:24 +0200
Message-Id: <20190416123148.3502045-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:1EvAL0ojU2Frr4q+8XD0ubRvQzid0tVwlNCSoNZpPcdhs4cXgDa
 er9JnhpiZ6+hzDmyNo90eKhBWtxDpCdIn6jqy4JCU9DrGMckNRieIrMfro3+wbktoidofOa
 2tVttJbXVZWG//pdNS5j3Y633M1A+mZTSjYVaRthJnUD7c0O1yizfkfnXNRSg4ujEr9MH4x
 AyUceR85JAEo3Yda+Rw5Q==
X-UI-Out-Filterresults: notjunk:1;V03:K0:yJV3e/orw2s=:nbtkNbl92Oed8LdUTP7aNQ
 8K1IijsNIuBoy5Titcdi7g2zqv5QUY9rX8tRXQdW8aqtnn15cD1G01zd7WNx3TfDL9xvhfIFG
 1ItPv7GKidKCQgzBFk1xM3iBuN5nIyNOTzla1ypOnT5yGAqFwo2y88e0ZE21QSHMTTuKprRha
 ys0NCnA/4V9Q4fAq0Gdg7oBKDNIvx6FuWon6Zi/XmwyIElCZCoG4DJiEiATKCJB8GzOtgN34m
 r6j48PcG6ZM5h+Xk95gtJhBgOBO/TOsBYZXWH79pFS9v9SWRNHAvCYu26GdxorKhy31maOvff
 954yn9NwEFJfsY1WYLJhfc9YvHYSDT+tidCsA0Z/ZNXVEfR5BGxuZCxzG8sBFdkKhdxDLaHo9
 sW+I/CRJMPxfZmXxYMmvDxNzeNTfnenr+P5xnRYKskXx6f/cdzplWjDgSExfUMqgtcgiYAh1J
 gBTzsKsuuHXqjpcxXOm+yOTP1IZjeL4ZGY2nLzwjztRU5Ywp6PaSc5iql7ZH2l9EKV+olJ7/6
 2b4Iw/mWze/q9s1nJMhy1SBE270oK4ErvsMcyfabDRW/2nN0l8rEom5HVHJ+05QIxKrjCAaux
 qJH6kaXBYfiYJ1DvZIhcprrl+V8ulpOm2ESXBwiFzydWz1Fx0O0Re0wr22N1d6Wq+9zGsYOQP
 7/PyT2MvXJ68UXl+/kCsbT2AYesGM637PGllo2Af6HowfEH6kwoBlchorWR3rD9byv/nWt7Un
 QpjQ4Ok9B5p1irYvm6AhvABLFng+3ZJ9Tn3SFg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only references outside of the #ifdef have been removed,
so now we get a warning in non-SMP configurations:

mm/kmemleak.c:1404:13: error: unused function 'scan_large_block' [-Werror,-Wunused-function]

Add a new #ifdef around it.

Fixes: 298a32b13208 ("kmemleak: powerpc: skip scanning holes in the .bss section")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/kmemleak.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 6c318f5ac234..2e435b8142e5 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1401,6 +1401,7 @@ static void scan_block(void *_start, void *_end,
 /*
  * Scan a large memory block in MAX_SCAN_SIZE chunks to reduce the latency.
  */
+#ifdef CONFIG_SMP
 static void scan_large_block(void *start, void *end)
 {
 	void *next;
@@ -1412,6 +1413,7 @@ static void scan_large_block(void *start, void *end)
 		cond_resched();
 	}
 }
+#endif
 
 /*
  * Scan a memory block corresponding to a kmemleak_object. A condition is
-- 
2.20.0

