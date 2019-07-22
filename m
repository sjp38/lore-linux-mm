Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 690D2C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 21:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216C421900
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 21:32:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="RN51VtIv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216C421900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC5D46B0005; Mon, 22 Jul 2019 17:32:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B2D8E0001; Mon, 22 Jul 2019 17:32:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99D836B0008; Mon, 22 Jul 2019 17:32:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60DAE6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:32:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o6so20610965plk.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:32:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Mv7+8jJEeDbo3rALIQWEE79IiSHFEfgtW30JPgsaJYY=;
        b=eqCtbJW/SsIyA3d0u+KcrY1oNqpx9x3klTQdqWWfNrDiNlUSjn9xBTmxIK3EOlhsF0
         d8B5sYyY+h+gM5caP1L010UV8AsHyna0P29I4MG5YxOChlg1jpleVg1t6C+XkxUWrw8C
         PAIEo07LA0i08N4QWNloUc9gMVrE+LylH1xZhwfOybQoWEJJIdwezi6M9y0UdFtRTFLC
         eyUEW4nc19Nl6SU5wPRValyUIuCJ3lVhlcym8UkmBiTLEZJuSvy2Z9inY9MdI+4mF/Uh
         KXSMOYiRFK568c0xSROq/NPW4/kjY/LWWZgeutDvE2kDi9K8pcjYOuYWoPxJweqqaOmu
         2wIQ==
X-Gm-Message-State: APjAAAUgj+a1j5hWHsmMF77BBT/6f3H5gg7n3yjux080iXH4JEOMZBY/
	VwBtO5r3pWLq79sHpAaAvPV2g5MFgGgZjdvuntFW1yNrT66pkgMLxa5MXKnopISJKLnDWnck4iE
	QxTS1VsU5Y0GRrlwCDNLOqyf4DdsBOgZN3vx9HJWK5iUmoItGJ+2LbwAZpAzMnCny8Q==
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr30211194pju.124.1563831143062;
        Mon, 22 Jul 2019 14:32:23 -0700 (PDT)
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr30211137pju.124.1563831142103;
        Mon, 22 Jul 2019 14:32:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563831142; cv=none;
        d=google.com; s=arc-20160816;
        b=jrfjpKUbEp7Bj2sloxHJ0Cg4GA7Pc7svesiwh67oIlm352H75UDnxABJPdJmPHOEvb
         IrwWEOmChmokQAFO6IvlhA5k1b2QcFuoAA29IbpdEdBeAu712ZLy79wLxx+z3EUIX/Hz
         RuVeUuPelCDqLGZAcmV3yZwCvDR+8tKeQunKCXe235Evsz9pnyVCxYZ4xKP7IMUnQ7q/
         amPCqzdeU5ix7W8NNumdmGJeYROCBNkoT07YGWfJCvx4P8COWfkyiXs7m9KMZnsVHIXg
         z+MAFWqJ52qn7LXzJsBU9qEc9SY8QBLhqLljYb061xb5Ip/I27YP7Smy+AWN8dKqTExF
         dGOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Mv7+8jJEeDbo3rALIQWEE79IiSHFEfgtW30JPgsaJYY=;
        b=x817rrESAILMK8rTVbWM3wp1UqbLyZmtbSF/Z2VCuyAiCPK2tIjK3rpPlAI7aSB6oI
         odQXg4FmOHBjQvgfnb7cXhcXf/O9jdfC1HDtVNu+T0vG31Fs0RLzCoe/OiVFAnCYk92K
         vhb7yy9J1qe7tiLoqDxQCmoYodOWDf2z0iJn3guVhFJn4oCAed7kEG45rNcsUPF5TbKm
         g83B6QcIdFSPya3cyHfaTyHQvXwYGLDVmXqOKScblZhf0NnHOxzC/D2/xn7ApGz5MqRB
         +d1DCk4SUIOUSp/gJ8K88e9rzEcx8nRl1OsxcGhAW/Ov3d4bMr2knhaaonPFQWt+P5F8
         UOuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=RN51VtIv;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj2sor49424503plb.52.2019.07.22.14.32.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 14:32:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=RN51VtIv;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Mv7+8jJEeDbo3rALIQWEE79IiSHFEfgtW30JPgsaJYY=;
        b=RN51VtIvabaQniuWGM+pEPP9sY4v3p6xCZKepJA4+4kregQ3NwAojuNej56xQ688W8
         eLtSCHrEUHvqDuJG1YODwTmMS531wT5nr8f+7IPMA+tRi07n7hQ2+4nf6D7krbpHmVru
         +sIEA0pNjuayX8Cig3N0kz1/Ihvc6sa3pBBYo=
X-Google-Smtp-Source: APXvYqzeYQTGy2llesIRc8Xr/1lEdoWOVbeDS/M3QnnnhYqXSV2haWsR6uhZcgSUQ/kYpp4/+92/Rw==
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr79260764plh.147.1563831141698;
        Mon, 22 Jul 2019 14:32:21 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id i14sm65202333pfk.0.2019.07.22.14.32.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 14:32:20 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Brendan Gregg <bgregg@netflix.com>,
	carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>,
	dancol@google.com,
	David Howells <dhowells@redhat.com>,
	fmayer@google.com,
	joaodias@google.com,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@google.com,
	minchan@kernel.org,
	namhyung@google.com,
	sspatil@google.com,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	timmurray@google.com,
	tkjos@google.com,
	vdavydov.dev@gmail.com,
	Vlastimil Babka <vbabka@suse.cz>,
	wvw@google.com
Subject: [PATCH v1 2/2] doc: Update documentation for page_idle virtual address indexing
Date: Mon, 22 Jul 2019 17:32:05 -0400
Message-Id: <20190722213205.140845-2-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
In-Reply-To: <20190722213205.140845-1-joel@joelfernandes.org>
References: <20190722213205.140845-1-joel@joelfernandes.org>
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
 .../admin-guide/mm/idle_page_tracking.rst     | 41 +++++++++++++++----
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
index df9394fb39c2..70d3bf6f1f8c 100644
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
@@ -74,6 +78,29 @@ See :ref:`Documentation/admin-guide/mm/pagemap.rst <pagemap>` for more
 information about ``/proc/pid/pagemap``, ``/proc/kpageflags``, and
 ``/proc/kpagecgroup``.
 
+Virtual address indexing
+------------------------
+The idle page tracking API for virtual address indexing using virtual page
+frame numbers (VFN) is located at ``/proc/<pid>/page_idle``. It is a bitmap
+that follows the same semantics as ``/sys/kernel/mm/page_idle/bitmap``
+except that it uses virtual instead of physical frame numbers.
+
+This idle page tracking API can be simpler to use than physical address
+indexing, since the ``pagemap`` for a process does not need to be looked up to
+mark or read a page's idle bit. It is also more accurate than physical address
+indexing since in physical address indexing, address space changes can occur
+between reading the ``pagemap`` and reading the ``bitmap``. In virtual address
+indexing, the process's ``mmap_sem`` is held for the duration of the access.
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
@@ -99,10 +126,10 @@ When a dirty page is written to swap or disk as a result of memory reclaim or
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
2.22.0.657.g960e92d24f-goog

