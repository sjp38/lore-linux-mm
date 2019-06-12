Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76152C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:53:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3879621019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:53:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3879621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE2E66B000A; Wed, 12 Jun 2019 11:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C955B6B000D; Wed, 12 Jun 2019 11:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C276B000E; Wed, 12 Jun 2019 11:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B81B6B000A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:53:15 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v7so7546124wrt.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:53:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Be82MXrZZVwB1/Oeg/G/O2HGzMN4mPYcnghvzbdbiYw=;
        b=F7ox/K//SHCaDz7OyN7/kGxwD7OGDrVk61MowuARSsZ+tLUmltPsLIsTOMFiIvnBA4
         10fieksbpF95gYkzjCmLPzgORFYKhBtMDeiSz3rEl2WnZHZKBif8n3HUvAkvq0FT/BFJ
         Nz7hSlQzJImoi9/MJy+6aMYrbFdCF+2O/wEpgbVEzv98gg0ahC99aNWP0KJJv74eR3/d
         k0ycGWX0P2dcRs8gG9wWwOXqRR17BCLAgNInR6QIyxNUAK1lBBFIRGkCjdegMsr98jxV
         JWRpb5iwiA2lVrEEk7/A7aewKyiAEpGdjoPZ5ye/fa3OgmTjmZvQpyD0m+f4PAJ8Zr35
         BAIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: APjAAAXUyHFbrmBz5D/ApGBph42P/FlAbxlaq2qmgJ7urSZurM/B0gS6
	7gwXjqyM+l5akZtAa6y84mBpQVBqsxuBNno+kRLZFWNlPcbVZTPZ5RitsPgLTNh1q664I3OfKn3
	yzuiS06iC2wLIzXBt+5w4Glk9UA/SOXGvmDal2XmcZ/+AYfRO++rNnq5v3/kzxQnNUw==
X-Received: by 2002:a1c:f415:: with SMTP id z21mr9910396wma.34.1560354794884;
        Wed, 12 Jun 2019 08:53:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweGK+W3lDuTfeAdsrAknp4baeT4KZCVFVptZgp0oPn3TIz2mQLlWJi1DsyA/N5SaBxJNL7
X-Received: by 2002:a1c:f415:: with SMTP id z21mr9910346wma.34.1560354793940;
        Wed, 12 Jun 2019 08:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560354793; cv=none;
        d=google.com; s=arc-20160816;
        b=FgxsPMQ6n/aI5GioceO0dxeB+yGPdYwcuaWY87U8cvajUCxRgfQzZpSF3ryuOZOuiD
         HXldyptoO2SY7y8gYRLaXdYodVJBy1SRusC+D/svBKspbxpzh4IZ1hBdzQommn7ogwoB
         pj0DyKg4UXkkmaklGqj4qOhaMcAAwC+2bQtLrtBh0LcPtZQEIHDG5Z/gMIb0yBybWeos
         SrROC7bj2Euopu+ythsOOTHL6spIFQ4S6NXfHqHpZV68OZ+8mv7fnHMPRDjjnRuc218z
         mzBQuAW8oEtULo2A+WZxYsiCEoeZzNu+8de6HgyxFGjFToLRMJpBhIKIqLNid0XL6srX
         s3Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Be82MXrZZVwB1/Oeg/G/O2HGzMN4mPYcnghvzbdbiYw=;
        b=ZiayApnMO475CVgJBgBLoFjY/ilcFJ4LLHUmReCm7TUfzPA5UgvsSyNjlsq41XPztC
         hLFLVAoRjKStHXsm4IcHJbKuhSmk6MSf2MlpxNQN9R/7xDEVCubc6Ps07r6TN82KhALF
         IuTquyYNhyOP8Mb8D87S/KkesNZP2BG7zggNV4pDqKDlExkuUxoD2f4E4hq82ZXwlyr+
         R4UV/Vwspm93ETh5xtP5h1bugL35W6tfdW+nqguK5si2BB+vtqaq/gDs9BoiocG2mtlh
         A6998vIAc2MONCsWpbnWH+u8CC5Vh4DHjvSMqdRMh98Rq3qj8BCm1wzVcXbeKXLyAGRQ
         B6xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id s127si9876wmf.122.2019.06.12.08.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 08:53:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of andrealmeid@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=andrealmeid@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from turingmachine.home (unknown [IPv6:2804:431:d719:d9b5:d711:794d:1c68:5ed3])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tonyk)
	by bhuna.collabora.co.uk (Postfix) with ESMTPSA id 0E7D52808F4;
	Wed, 12 Jun 2019 16:53:10 +0100 (BST)
From: =?UTF-8?q?Andr=C3=A9=20Almeida?= <andrealmeid@collabora.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	catalin.marinas@arm.com,
	kernel@collabora.com,
	akpm@linux-foundation.org,
	=?UTF-8?q?Andr=C3=A9=20Almeida?= <andrealmeid@collabora.com>
Subject: [PATCH v2 2/2] docs: kmemleak: add more documentation details
Date: Wed, 12 Jun 2019 12:52:31 -0300
Message-Id: <20190612155231.19448-2-andrealmeid@collabora.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190612155231.19448-1-andrealmeid@collabora.com>
References: <20190612155231.19448-1-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Wikipedia now has a main article to "tracing garbage collector" topic.
Change the URL and use the reStructuredText syntax for hyperlinks and add
more details about the use of the tool. Add a section about how to use
the kmemleak-test module to test the memory leak scanning.

Signed-off-by: André Almeida <andrealmeid@collabora.com>
---
Changes in v2: none

 Documentation/dev-tools/kmemleak.rst | 48 +++++++++++++++++++++++++---
 1 file changed, 44 insertions(+), 4 deletions(-)

diff --git a/Documentation/dev-tools/kmemleak.rst b/Documentation/dev-tools/kmemleak.rst
index e6f51260ff32..3621cd5e1eef 100644
--- a/Documentation/dev-tools/kmemleak.rst
+++ b/Documentation/dev-tools/kmemleak.rst
@@ -2,8 +2,8 @@ Kernel Memory Leak Detector
 ===========================
 
 Kmemleak provides a way of detecting possible kernel memory leaks in a
-way similar to a tracing garbage collector
-(https://en.wikipedia.org/wiki/Garbage_collection_%28computer_science%29#Tracing_garbage_collectors),
+way similar to a `tracing garbage collector
+<https://en.wikipedia.org/wiki/Tracing_garbage_collection>`_,
 with the difference that the orphan objects are not freed but only
 reported via /sys/kernel/debug/kmemleak. A similar method is used by the
 Valgrind tool (``memcheck --leak-check``) to detect the memory leaks in
@@ -15,10 +15,13 @@ Usage
 
 CONFIG_DEBUG_KMEMLEAK in "Kernel hacking" has to be enabled. A kernel
 thread scans the memory every 10 minutes (by default) and prints the
-number of new unreferenced objects found. To display the details of all
-the possible memory leaks::
+number of new unreferenced objects found. If the ``debugfs`` isn't already
+mounted, mount with::
 
   # mount -t debugfs nodev /sys/kernel/debug/
+
+To display the details of all the possible scanned memory leaks::
+
   # cat /sys/kernel/debug/kmemleak
 
 To trigger an intermediate memory scan::
@@ -72,6 +75,9 @@ If CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF are enabled, the kmemleak is
 disabled by default. Passing ``kmemleak=on`` on the kernel command
 line enables the function. 
 
+If you are getting errors like "Error while writing to stdout" or "write_loop:
+Invalid argument", make sure kmemleak is properly enabled.
+
 Basic Algorithm
 ---------------
 
@@ -218,3 +224,37 @@ the pointer is calculated by other methods than the usual container_of
 macro or the pointer is stored in a location not scanned by kmemleak.
 
 Page allocations and ioremap are not tracked.
+
+Testing with kmemleak-test
+--------------------------
+
+To check if you have all set up to use kmemleak, you can use the kmemleak-test
+module, a module that deliberately leaks memory. Set CONFIG_DEBUG_KMEMLEAK_TEST
+as module (it can't be used as bult-in) and boot the kernel with kmemleak
+enabled. Load the module and perform a scan with::
+
+        # modprobe kmemleak-test
+        # echo scan > /sys/kernel/debug/kmemleak
+
+Note that the you may not get results instantly or on the first scanning. When
+kmemleak gets results, it'll log ``kmemleak: <count of leaks> new suspected
+memory leaks``. Then read the file to see then::
+
+        # cat /sys/kernel/debug/kmemleak
+        unreferenced object 0xffff89862ca702e8 (size 32):
+          comm "modprobe", pid 2088, jiffies 4294680594 (age 375.486s)
+          hex dump (first 32 bytes):
+            6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+            6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
+          backtrace:
+            [<00000000e0a73ec7>] 0xffffffffc01d2036
+            [<000000000c5d2a46>] do_one_initcall+0x41/0x1df
+            [<0000000046db7e0a>] do_init_module+0x55/0x200
+            [<00000000542b9814>] load_module+0x203c/0x2480
+            [<00000000c2850256>] __do_sys_finit_module+0xba/0xe0
+            [<000000006564e7ef>] do_syscall_64+0x43/0x110
+            [<000000007c873fa6>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
+        ...
+
+Removing the module with ``rmmod kmemleak_test`` should also trigger some
+kmemleak results.
-- 
2.22.0

