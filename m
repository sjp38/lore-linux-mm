Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74276C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B0022238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:08:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="aHKVCn8Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B0022238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24876B0005; Fri, 26 Jul 2019 11:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9D66B0006; Fri, 26 Jul 2019 11:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FAE48E0002; Fri, 26 Jul 2019 11:08:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0926B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:08:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so33382329pfe.1
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:08:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=EbtankSSdcVAC1y+1UpHqdY30IRJShlXq5UMOTacdT6jXxsscLki9VSXwzK1pt1rfZ
         PK/ZPmveHMKMwL390GQ4wxHzBMiPQ7O2zZGcG93Z/N2Gd05nsokz/SjgAjkFF/mbJxxy
         ZeRV3HNpN7k6C9rhniCYfzpF6fUWFejM5nU76MBethWEGkqN74InXSxajhobCba4b2Ca
         DbIHd6DH2DOD8OrIukMOZlfKKVo7sP4Hhmw9MhExyLyWoR9Qc50oI99WXlqmxeYCatD6
         NAO1meJOnxgP+3qPg4ypo0DMJp7OVSNSXMemZgJUTenKP/gW77rNNuM7P+LwxFUso/M0
         3row==
X-Gm-Message-State: APjAAAWAGn3fbFrhOcDdsf2rb2A2dsslPNOreW4qiaM9Y56Y5SLA8Hsm
	CBdgTrZ6ZOs6ndrhHiiPquyO6iy7as50WJlQhIhP85nUk2FvcdNVFVbinla5t4EMxtluzKGSRQ0
	aDkvbzpwXb+lSyHVfyAQrdBNKWEUJ2F0Kn7tqDkumvbZuk1+0dzG2bfmEO2lnY750Cw==
X-Received: by 2002:aa7:9531:: with SMTP id c17mr23526021pfp.130.1564153737907;
        Fri, 26 Jul 2019 08:08:57 -0700 (PDT)
X-Received: by 2002:aa7:9531:: with SMTP id c17mr23525936pfp.130.1564153736945;
        Fri, 26 Jul 2019 08:08:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564153736; cv=none;
        d=google.com; s=arc-20160816;
        b=mTTxIAZBqQDMRTp0rTQ5pcrAs6c+URi9nu6NnDVkhDzmkJjqbSN0jOQHxqZgA7087b
         zHPQwPHyDxdlAqRGH7w4FbWdPxmvSS9oLPKGnav5H2h6thLyyP3yb8Kpq6eIGz8Prqim
         bWOm7SJV8bDUMmaW5PJ1LOdE3a5uCfkoavtJsKjyCJZPAbfuL4RpiFpXVED1jWD98MQo
         E8M0n8Pgk501PL0magiF0U6XVr/fWVP1FGVmUFHZ7pbDpTdP9m2h06iY64NFI4+n2hjP
         QnKoqhP6H5WuiZfEVx1jRWHeDs/zvfS+gYWVjeDqHsCHg+3W8rJjcXQpAbQNWngq15+W
         o2zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=J5jOeTkfb2rpUNFaff7XSp/q8eUMciEwYTYixDHUQnv+N2TmMGY0idKaoDJpH1klTc
         I0Nf6lMrW9yqLHmdnIja3QUxF2ElJvPMT+1J4BSGjxDxnvgWr4NM/g2qNH5As3unFWoc
         f3yCX8UPoukyHydud9CT4a4S3JXHkaKSeD+IeodEUGOPbGf1Uhx9v6De3LRsKAYgQhqF
         40R8QvVyf3vutXTjfGp+ftalwvDVUBtiTxIF0HnK+R6Z8sxR4G5ZnHr0z5+QpWr76zXT
         rCwUcL7sR1YVTwuRS+WrUIOiZR+S903THOMLYjbvHXH6NW7slPbTbd0VBDyuomkeQet9
         +Zdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=aHKVCn8Y;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor63869593plt.55.2019.07.26.08.08.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 08:08:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=aHKVCn8Y;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dWQZR/3W1JJGAqPUD7hTWyfWfaLoNTQhqklPLc/rCo0=;
        b=aHKVCn8Yp9k/O48xxeey02lLJNycfqq+nT8pu97tqLat8sXh6527ZcHjiLMjFGs8ZZ
         SzpXGhN97m6q7LoR5xxBb5fekgPrddIS2ckjFbLcS/b41a8DTKGviU3TjgY2guZy2wOV
         N7hTZrckEmKJ55qJ5XLQRPA1RD8Ilyo39Glr8=
X-Google-Smtp-Source: APXvYqzXibXZSd6IWrSK+XtEpTCaIi3keajeQLn0VdiXnOjUc33BTq98H530Us64OhTV+XaDB3T7Bw==
X-Received: by 2002:a17:902:7791:: with SMTP id o17mr98018495pll.27.1564153736559;
        Fri, 26 Jul 2019 08:08:56 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id k36sm54802352pgl.42.2019.07.26.08.08.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 08:08:55 -0700 (PDT)
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
Subject: [PATCH v2 2/2] doc: Update documentation for page_idle virtual address indexing
Date: Fri, 26 Jul 2019 11:08:44 -0400
Message-Id: <20190726150845.95720-2-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
In-Reply-To: <20190726150845.95720-1-joel@joelfernandes.org>
References: <20190726150845.95720-1-joel@joelfernandes.org>
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

