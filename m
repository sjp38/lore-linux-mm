Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6970E6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 11:56:41 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d140so17425263wmd.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:56:41 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id t141si2744854wme.100.2017.01.13.08.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 08:56:39 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id r144so79348444wme.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:56:39 -0800 (PST)
From: Daniel Thompson <daniel.thompson@linaro.org>
Subject: [PATCH] tools/vm: Add missing Makefile rules
Date: Fri, 13 Jan 2017 16:56:30 +0000
Message-Id: <20170113165630.27541-1-daniel.thompson@linaro.org>
In-Reply-To: <20170113164948.25588-1-daniel.thompson@linaro.org>
References: <20170113164948.25588-1-daniel.thompson@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Thompson <daniel.thompson@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org

Currently the tools/vm Makefile has a rather arbitrary implicit build
rule; page-types is the first value in TARGETS so lets just build that
one! Additionally there is no install rule and this is needed for
make -C tools vm_install to work properly.

Provide a more sensible implicit build rule and a new install rule.

Note that the variables names used by the install rule (DESTDIR and
sbindir) are copied from prior-art in tools/power/cpupower.

Signed-off-by: Daniel Thompson <daniel.thompson@linaro.org>
---

Notes:
    This is a resend with the linux-mm list spelled correctly (and with
    special apologies to Andrew for the spam).

 tools/vm/Makefile | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 93aadaf7ff63..006029456988 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -9,6 +9,8 @@ CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall -Wextra -I../lib/
 LDFLAGS = $(LIBS)

+all: $(TARGETS)
+
 $(TARGETS): $(LIBS)

 $(LIBS):
@@ -20,3 +22,9 @@ $(LIBS):
 clean:
 	$(RM) page-types slabinfo page_owner_sort
 	make -C $(LIB_DIR) clean
+
+sbindir ?= /usr/sbin
+
+install: all
+	install -d $(DESTDIR)$(sbindir)
+	install -m 755 -p $(TARGETS) $(DESTDIR)$(sbindir)
--
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
