Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92B09C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4834A219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="qSJJinjx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4834A219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E22196B0010; Wed,  7 Aug 2019 13:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB226B0266; Wed,  7 Aug 2019 13:16:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C72D86B0269; Wed,  7 Aug 2019 13:16:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2316B0010
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 13:16:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so53119252plo.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 10:16:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=iwun2aSGaLhvIuxR+uqmXX1bq8UAh1apKkg7k1Xio/Lkzs5xoYEXVMNfcgF3iB1NVQ
         KruEy+endovPJQnQKEjNdVWBdAGuYGjqvzgsAOFMqXlcmgJcUJSOuwio7l3QYt+H7xvf
         Z0ZBNfr8QJTOzne2YbZ/NuwO2E7Tc05L4rbJ6O9gDNxa2rUod6z7pwe0n02qAesILsKb
         08LdYN7SN8nF7eynJL/GOXUsP893N6lbln2dN13JXBoTyVwfQ0DRVGZdlfhFqjkt55m1
         /GEK2Z2lEWbCU8OECis4eKJuHTMhnEjVhYNGpI0ELUkqi+AkJyorvz2Yo8WJWwON2PvH
         Agtw==
X-Gm-Message-State: APjAAAWmocdPGaBsCp0Hq2UJhNBLlwLQMPpkrPWyRKJuUiWhRG9qqEQ8
	QbiODD83NdZThgjyHKrad0uWoVOG2BPGAYPCT/JKQD7XvhgHA+3UrH7YQne6o6R5uQAxrPxQP/M
	nCf5Xt5cfy7IxKGBY9YLkhjx0jwYCfIkhKXK7oVpy9XZUZVhDdgpj3gfeTxqFLEswNA==
X-Received: by 2002:a63:6c7:: with SMTP id 190mr8566230pgg.7.1565198189155;
        Wed, 07 Aug 2019 10:16:29 -0700 (PDT)
X-Received: by 2002:a63:6c7:: with SMTP id 190mr8566173pgg.7.1565198188245;
        Wed, 07 Aug 2019 10:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565198188; cv=none;
        d=google.com; s=arc-20160816;
        b=EAACBllx2MPcJAFEu05nBIsOEHnpDWi1q3ZB7WXJ+HRjk1ZsaEDuIwyoVDJhyVSkah
         ztWsYpeto6uz0I79AolJmNHfLozFG2z7C54ZmHpKSHFGqFhrSrTZQNTXk2MxrtEl3RvW
         avVaqi8msGQXAv222RCRkVexXUXgSlOXKAbexjAOw/Zwyx/pSZYP0pMy6EHKxXMb1tPn
         W6e8mwtCMy2+mBWpB6kopwesLkP98ZvvRfSMNzcGIEEwXnO04RAdoBu8pt+mxP3DGLnH
         3W+Vuz0WeOtCeK8aA/SKBhOf8yLNgM3jldivA+q1aaKHxfUTQP2mMQV2KX+nACFrMWvb
         VPOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=mrVWRa60JnxxpdAtomsB3fOer5ReWWWWqxplQ8wg5jsmIaJP6IntTOgORLUTw7vdVc
         bCCKFD4wYncdFi02STMOZU5O3aqKE2XFvxTBx1Pg+i8drEKIhDF2zQL/ZtQfi1MBw9lg
         rzAXVyDvO9bw+lrPc90ZXmey2UxxihbDGnIWnZ1Hc7Ec6XXCyVtxklgtbQTp3cTT2s2B
         tQ0jVwafVmpVYT5SEQU20nWFqftaZbS58qzIREuC+LxMfAZzGb3qqtXsnfsv1g/u4w9j
         WRgBv4kO/J1cxCXqCJZVtXkLFp7qtwQzdI1+eYZX3ANfO0UGz9PN7iBckylmqW46TCe6
         39/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=qSJJinjx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f41sor793385pjg.15.2019.08.07.10.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 10:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=qSJJinjx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=qSJJinjx4WgXKOGFZMmrrGe4d2ALaNficzckUCKQ9VzSczmwMe7F1Cq0uQ7tfoks+e
         rtGpQwgXk30A1hVz+miPyOItSF28qM821PY2ovorbdNSmTsSYUUDhgdU2OE+wjQDzDPX
         CSpRQfnNtyIHoIY+g92oO+tp+BGpBJMqcqBT0=
X-Google-Smtp-Source: APXvYqwFZ4pqna4e9p6C0a1Fkqp6qRc76QmaknFJcHpGMEiflBOSwsFgniRNvWcMNGSw3sFAcWvCGQ==
X-Received: by 2002:a17:90a:7148:: with SMTP id g8mr938080pjs.51.1565198187764;
        Wed, 07 Aug 2019 10:16:27 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a1sm62692130pgh.61.2019.08.07.10.16.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 10:16:26 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Sandeep Patil <sspatil@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	dancol@google.com,
	fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	minchan@kernel.org,
	namhyung@google.com,
	paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Will Deacon <will@kernel.org>
Subject: [PATCH v5 6/6] doc: Update documentation for page_idle virtual address indexing
Date: Wed,  7 Aug 2019 13:15:59 -0400
Message-Id: <20190807171559.182301-6-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190807171559.182301-1-joel@joelfernandes.org>
References: <20190807171559.182301-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch updates the documentation with the new page_idle tracking
feature which uses virtual address indexing.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Sandeep Patil <sspatil@google.com>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 .../admin-guide/mm/idle_page_tracking.rst     | 43 ++++++++++++++++---
 1 file changed, 36 insertions(+), 7 deletions(-)

diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
index df9394fb39c2..9eef32000f5e 100644
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
+The idle page tracking API for virtual address indexing using virtual frame
+numbers (VFN) for a process ``<pid>`` is located at ``/proc/<pid>/page_idle``.
+It is a bitmap that follows the same semantics as
+``/sys/kernel/mm/page_idle/bitmap`` except that it uses virtual instead of
+physical frame numbers.
+
+This idle page tracking API does not deal with PFN so it does not require prior
+lookups of ``pagemap``. This is an advantage on some systems where looking up
+PFN is considered a security issue.  Also in some cases, this interface could
+be slightly more reliable to use than physical address indexing, since in
+physical address indexing, address space changes can occur between reading the
+``pagemap`` and reading the ``bitmap``, while in virtual address indexing, the
+process's ``mmap_sem`` is held for the duration of the access.
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
2.22.0.770.g0f2c4a37fd-goog

