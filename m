Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2259C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:23:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7890E218D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:23:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="NSm723gH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7890E218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2378C6B0008; Fri, 26 Jul 2019 11:23:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E9756B000A; Fri, 26 Jul 2019 11:23:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089B08E0002; Fri, 26 Jul 2019 11:23:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C770D6B0008
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:23:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n3so23350879pgh.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:23:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=GSfLQo0L3NIwTqHLI5Q7njP9ACXKuQihwCUO+eIfwnm9Uwl5xKhUW5siiHdjZhOXoz
         6X9Cq9PHb2zh4GIcnbS+PJdR2cenJYJA0ywfuMlIoJ1ma4Of9wL49gbYy/26RkeEunfp
         as1nxrSCLSvbqWjuXS6Ow20MVRjXPIetcM12y/6LtJWVdp9BcHzhbyPfMdDt82utanLE
         XdHA7Lg1MP1lZezOVWy/jackcVHwVtImqmorrC0Dss1N0HjyI3oMUQ/M4qbqpadNtH7W
         ipRjTy19t1tPFcisGOT1yQ5mt7zEFv3sRLA0VWJNytOOwg02m9ucp7dp27Vq+1Y1yfqw
         zu0A==
X-Gm-Message-State: APjAAAU9VnoTjsGdvhTYbK8n1026sUkYN9E0/A6YDur+4X+7AEqIBiI+
	LNBKHsriyzKKdIr2i6m34xzGbHeYSy54V+X81WJXBW14nWkN14OYVieUirSKRR0jeToc1NofGvl
	GiKmNENwVegB+DMa6Rlzs4psYr3/h7rR8qv9q5JSyN/fdoM/Ym33/43VMnG+rTpRB9Q==
X-Received: by 2002:aa7:8189:: with SMTP id g9mr23171640pfi.143.1564154613490;
        Fri, 26 Jul 2019 08:23:33 -0700 (PDT)
X-Received: by 2002:aa7:8189:: with SMTP id g9mr23171572pfi.143.1564154612659;
        Fri, 26 Jul 2019 08:23:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564154612; cv=none;
        d=google.com; s=arc-20160816;
        b=yXkyi03IbWa2HxlW+h2pXvs8SqFLWVKJ1K1ACl5AlqYxIAREDxAl5JBnE4xXYXupLD
         700otgVfN/2baRBcIp+zQdaHMve8UzEgR+PssN/iLE3DX6oa+w8caUeZvUct11EroaG+
         eETLL346+CHErP1g8+WpDfaJwOdalqC7CtiyEMffTFsAzFZeqlcK64z4crKNX+KSGXxp
         2as6M1n2gnVTRh39RDFaZrNRjQMzYBDCy/OyIYbChM11Byko9CD6UcErVsiNr8kVjGQc
         /9p6rqOmnWmUkC6hSaRFn9+p8AqZXskHo+VQigMunvqDNoYYFkIry1VXbWO51Qftlf0f
         6vTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=WIwzzvk/6sSERP6UbjdTIfz2qmaPSn595+X0kSrZw2vGdldMlJvMommywRdWL60jbO
         dGrGUrmVJcS90e39XSE9FVGjChzNHFrYUTJN+/P+V5fYohL5vSgNKWlKlXS4YWnnMmzj
         wKiDtgPrF/Ae6c4d2T0CE+IXoQN2P4Eog+Ye2gHMFsVSM0qJRlFpIufbFU8jnuF1wbco
         DM/AX6+BuQW9qHXo6ss4D6nOukGKCKinI8nnV/Zn+sMHqrO/mLE8y2L5rG+Eaem0sukh
         S0BN7AOmcDbAyuI210VkEMCOn4VOUyBUjJjWUy9AEnImYsuFSX8r/2is7LpmxpmCZS1S
         4Asw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=NSm723gH;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor64080160plw.7.2019.07.26.08.23.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 08:23:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=NSm723gH;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=NSm723gHApWanD6yeW4J2Hod3LusoD9q5rDYeMMOfmnvzy1V6IW8Ik70kYPIywWp+5
         ePTv11kUJPhco3rtrxGscl1Xvn/9LGCfMjCA63hEQGhn0+RLeCWphNUjv25+mG/EUvI5
         IipB8N+66gykX0zBQeBiqZbzJqprH2vYSF24M=
X-Google-Smtp-Source: APXvYqxDFJfffeebJNKJPBtRQh+QrCwtMX6C8cQ3ucTqzwQ23dCczXPmGvaj1O0CVDvfDxhY8WADAQ==
X-Received: by 2002:a17:902:be03:: with SMTP id r3mr97943466pls.156.1564154612178;
        Fri, 26 Jul 2019 08:23:32 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id w132sm55268640pfd.78.2019.07.26.08.23.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 08:23:31 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Brendan Gregg <bgregg@netflix.com>,
	Christian Hansen <chansen3@cisco.com>,
	dancol@google.com,
	fmayer@google.com,
	joaodias@google.com,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org,
	namhyung@google.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	wvw@google.com
Subject: [PATCH v3 2/2] doc: Update documentation for page_idle virtual address indexing
Date: Fri, 26 Jul 2019 11:23:19 -0400
Message-Id: <20190726152319.134152-2-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
In-Reply-To: <20190726152319.134152-1-joel@joelfernandes.org>
References: <20190726152319.134152-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch updates the documentation with the new page_idle tracking
feature which uses virtual address indexing.

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 .../admin-guide/mm/idle_page_tracking.rst     | 43 ++++++++++++++++---
 1 file changed, 36 insertions(+), 7 deletions(-)

diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
index df9394fb39c2..1eeac78c94a7 100644
--- a/Documentation/admin-guide/mm/idle_page_tracking.rst
+++ b/Documentation/admin-guide/mm/idle_page_tracking.rst
@@ -19,10 +19,14 @@ It is enabled by CONFIG_IDLE_PAGE_TRACKING=y.
 
 User API
 ========
+There are 2 ways to access the idle page tracking API. One uses physical
+address indexing, another uses a simpler virtual address indexing scheme.
 
-The idle page tracking API is located at ``/sys/kernel/mm/page_idle``.
-Currently, it consists of the only read-write file,
-``/sys/kernel/mm/page_idle/bitmap``.
+Physical address indexing
+-------------------------
+The idle page tracking API for physical address indexing using page frame
+numbers (PFN) is located at ``/sys/kernel/mm/page_idle``.  Currently, it
+consists of the only read-write file, ``/sys/kernel/mm/page_idle/bitmap``.
 
 The file implements a bitmap where each bit corresponds to a memory page. The
 bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
@@ -74,6 +78,31 @@ See :ref:`Documentation/admin-guide/mm/pagemap.rst <pagemap>` for more
 information about ``/proc/pid/pagemap``, ``/proc/kpageflags``, and
 ``/proc/kpagecgroup``.
 
+Virtual address indexing
+------------------------
+The idle page tracking API for virtual address indexing using virtual page
+frame numbers (VFN) is located at ``/proc/<pid>/page_idle``. It is a bitmap
+that follows the same semantics as ``/sys/kernel/mm/page_idle/bitmap``
+except that it uses virtual instead of physical frame numbers.
+
+This idle page tracking API does not need deal with PFN so it does not require
+prior lookups of ``pagemap`` in order to find if page is idle or not. This is
+an advantage on some systems where looking up PFN is considered a security
+issue.  Also in some cases, this interface could be slightly more reliable to
+use than physical address indexing, since in physical address indexing, address
+space changes can occur between reading the ``pagemap`` and reading the
+``bitmap``, while in virtual address indexing, the process's ``mmap_sem`` is
+held for the duration of the access.
+
+To estimate the amount of pages that are not used by a workload one should:
+
+ 1. Mark all the workload's pages as idle by setting corresponding bits in
+    ``/proc/<pid>/page_idle``.
+
+ 2. Wait until the workload accesses its working set.
+
+ 3. Read ``/proc/<pid>/page_idle`` and count the number of bits set.
+
 .. _impl_details:
 
 Implementation Details
@@ -99,10 +128,10 @@ When a dirty page is written to swap or disk as a result of memory reclaim or
 exceeding the dirty memory limit, it is not marked referenced.
 
 The idle memory tracking feature adds a new page flag, the Idle flag. This flag
-is set manually, by writing to ``/sys/kernel/mm/page_idle/bitmap`` (see the
-:ref:`User API <user_api>`
-section), and cleared automatically whenever a page is referenced as defined
-above.
+is set manually, by writing to ``/sys/kernel/mm/page_idle/bitmap`` for physical
+addressing or by writing to ``/proc/<pid>/page_idle`` for virtual
+addressing (see the :ref:`User API <user_api>` section), and cleared
+automatically whenever a page is referenced as defined above.
 
 When a page is marked idle, the Accessed bit must be cleared in all PTEs it is
 mapped to, otherwise we will not be able to detect accesses to the page coming
-- 
2.22.0.709.g102302147b-goog

