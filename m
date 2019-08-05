Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CF5FC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE67421738
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="hgyWzkgS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE67421738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903496B000A; Mon,  5 Aug 2019 13:05:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4286B000C; Mon,  5 Aug 2019 13:05:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77B896B000D; Mon,  5 Aug 2019 13:05:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 441BF6B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:05:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b18so53103031pgg.8
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:05:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=h9Ha+k2xy/83vfX1kT9JcEpjlG1Hrc2lxNXhXPE/QhAYz3aj2qtQkEE4+DGcoNMY/0
         A6it/i+TMkOc67/uVTb355U3yOnARFpWXfxW10vtfw2x2yhZHNm+C/qq7I9BXO9RzMKm
         ROq+m0/7j8hAOhUM/4H78GvRt1JMkjd0N+VeXZZIeKUmoqatOXxnsQxLjxSkLrwSvasM
         OQfd87Q2lu+COL90VmvlmWdf4SkyW1zrB0Bkkwjndq9WKTsTPdT0uFGdCexiD1Sd5ETw
         tAr/ilSvAyS3F/tfcT+8cS75Ge3osJAz2w0KoEs17NLYZOmxVF8+PZKlGYP64mlyXpfh
         gmyQ==
X-Gm-Message-State: APjAAAX+mnqgZnmogBUJcjbtpv0Kwx5a1YPYSPNlnOv2s/7Mn754eYJg
	mDjFqF29DLXnMGAVhOwU30gevmY8zAEckDgdGpqrLh/axtdHcCupLhckThwQrBOmehUwGUxkjK8
	y0ptM6FPTvNCs3y0pQmYM5ridjStNy5bEAXohY34KY3kfYJs2GIRDRXIoOqpUhhmwTQ==
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr19659580pje.14.1565024720959;
        Mon, 05 Aug 2019 10:05:20 -0700 (PDT)
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr19659536pje.14.1565024720168;
        Mon, 05 Aug 2019 10:05:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565024720; cv=none;
        d=google.com; s=arc-20160816;
        b=WkpvMr3+I2u1kvcZNORKAp81kCSdHrlwxh/kGMKQxxSN7UTGLjTBu68/as0iy0sYZ5
         d0ysvMH9JDDJrBRZpqCpkXvxnOZlI6f1FdW2ZZX1/hFmtMpr+irbl11x7T70yrwN6gO6
         afB+SOgXCd2wFQhSPecDczttOLs/QKTshONtf+0fu7Es0xOyoFQnYXU0/gYcqb6FlueN
         HBCup8TBNWyVybCpFQ+P5xUX2bbfGVs8A4/Kg1tO66t+SPHkov1yFdieZ/AbMQSATfVD
         /4M3g9UFGtLhfgREh6a6BN8fV9JIrqHJldjZ8RFdguln1P1RiHPgHtwPu+qFLYVZ0xWp
         5TOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=UtDlD1ZlcEVWmXX0div0ezRlnseUyuQQ2bZEWk3gSaTuT8rn17KiaoOLlsitoZzogy
         aVqy7p5HxTmFxBbYpZ/QZaEM7QBerSzlTQyoPA69aXqzfNx3bzm61lf1SPOLxExj96Js
         6/p1tF8JM1qPnXX+G9u27qdZNJNu+/c2gMpRzq+5w21u5rpaNFiDm3DDxch2HQFR6GNf
         CZ3WcSMqvYSjRlf+BDWraIBdL6MvLGTnhVb2TlAOkGB5N2USL+Atf3ixJwS1KEFgYBV4
         DkyCFkmCoUT2Bh/0E6/TEuA9qbx5IHl9JrGAxRX7kXxi+F73C3bjjAxX27uRGwOqTnCo
         VGAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=hgyWzkgS;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l91sor36768548plb.68.2019.08.05.10.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:05:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=hgyWzkgS;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EpW+/zsfaWUWqnp/CzJ8iSD2ZsdUd34jJeLFlQmjMJk=;
        b=hgyWzkgSkWIkAiyvGZ+G+xjb4IZCoTupPLFm8KMlB2b4hKbMxa1b+uIr1iRdua+wqE
         QC4A3wju5EZMPMzUeRrpvG6gxy5MEYfQ82W1fGN8SHtXC5yuCxMcBGlIpCV6ZH3OP4zQ
         UMkuRWp/Da9107v0m9+9yab3KvcgH65HHQUcA=
X-Google-Smtp-Source: APXvYqza5nQrNDdoUqGT6kyvYnC1EmmsZrzblP42jhwdV0CyAlqgihwZyUT70kUG+iUloT382Cjx7g==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr61715428plp.126.1565024719760;
        Mon, 05 Aug 2019 10:05:19 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p23sm89832934pfn.10.2019.08.05.10.05.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 10:05:19 -0700 (PDT)
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
Subject: [PATCH v4 5/5] doc: Update documentation for page_idle virtual address indexing
Date: Mon,  5 Aug 2019 13:04:51 -0400
Message-Id: <20190805170451.26009-5-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190805170451.26009-1-joel@joelfernandes.org>
References: <20190805170451.26009-1-joel@joelfernandes.org>
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

