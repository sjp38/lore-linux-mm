Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80132C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CBC3218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CBC3218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B08E8E0003; Thu, 31 Jan 2019 13:37:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337D58E0001; Thu, 31 Jan 2019 13:37:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AD238E0003; Thu, 31 Jan 2019 13:37:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3E578E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:37:18 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id j125so4138926qke.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=c0x0Lso80FVkCqQKmxH25r61rYDEF6XogwD4uXvVoWY=;
        b=ZQz+tYFhWXq4Lg7ii3JFL+jSTjRij1sLKyEcBs+dKVopB5851Ba8HudAhtjxJifgWB
         +xvfAWEzHnxuHKz2/LNnD1NChdpZEc3W2CSgUdlpENYEetRR6JlPNaU5scfFW7zO7ETd
         dmdRQ1wsBeyQW0H8xu4hwxfWSWXDhcpCd0pka3KjCST0QQrhkywRJ77Ey8w/wfq0hwjF
         wQrdQMZzWUNWiC5dMoc2CvvfzowJyuJfQvUPN0dFiWWvICbvYzPYc2PlLHQNf0M0c/21
         slezEqthhB79h8x6an9QGC6LyMQy38yxxbnnAxsiPhMMw/jPAKbduPA8TPP2a9Ghb8H/
         Vj/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeIqnkQ3R64biDyXw5BGOGBmn9A6k6kOVm7e7tB7V5ia6xh9yiq
	gVmo9sleRGeaca7ntt7oMyrD8HGAeO6ea6sMGL/B5dcjDPygDaSiN6jP73HQ2KWGeVUnyH24zIp
	mqggKqbe+IkmwEPCn0qj3OKlmZc5QiW73CfQ4EH42YeLlOlMY7/8EOlydxDFN2tTFRQ==
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr35066030qtn.172.1548959838702;
        Thu, 31 Jan 2019 10:37:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5oWm3B4uLnjRquynyW0gQMPB2zfgI7nCeMDCLmm/xFC9no8URLwTG1z2RdFikp8OBBXypI
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr35066007qtn.172.1548959838265;
        Thu, 31 Jan 2019 10:37:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548959838; cv=none;
        d=google.com; s=arc-20160816;
        b=OjfAYcp+Ss2vvJ4unq5F+r5kjylKCvqlk9JgVxHxjhHypphfjcEXi5Q5PLIlJhYTls
         ii7dBxTvIvseEjTE473LDIx/e4fuaQPCPAk4pbkYypYLteYaOwbxTnB1Ax2mhK2fIGuX
         HXdcC3cGmKvlDQCZnlwjcg8jiexFixzov4AlmgRRwOnraIp9vE8jx8nUcuO4K2zaBtAb
         U+WWmcd2SU/oEKL6FUB9SL+4jFjD8WIK71MdHWZ1rrqxHOpCrb8kEVNQktepS3UBMhAc
         ARZuh9KQO6hSgbn3oOF20xhQMMuvZphemEF9zkr17eAxmDKHHukFfjhRlZkqt/VxK9qh
         z6Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=c0x0Lso80FVkCqQKmxH25r61rYDEF6XogwD4uXvVoWY=;
        b=tfI8gxM+Fb4nt1ddYZnUykZ2KEQYLQzzZgCi50/2wjPO479kxerogjKco1qHHbtnNX
         ptBtfq3QE3jDkDopINZni1ixET3Pvr/kRN5n8jrjrwuSjsMQ64fxEEezZICP6VOoxNX2
         y6D6GIyGlRFycIbJAWkxozep8YjIfaHPXOeAghaMfTA4uCvDdbuGZY7LlOGp5qpS9NgD
         o4CLEIaYsglbmrJqyw0U5VwT5nj4ymEhit1UxSDhCQxKnmMkrumgQWpnWi1LHiaClBSO
         /BwyXEo8RiUG4/SOrTXUdeXSAIqIco1dx/f/vYE2YsuRGGkPIGnuXl8XNBw5yN4d65xn
         VQYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l7si3433153qth.251.2019.01.31.10.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 10:37:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 540FCAC613;
	Thu, 31 Jan 2019 18:37:17 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A0C9F17F7D;
	Thu, 31 Jan 2019 18:37:15 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	kvm@vger.kernel.org
Subject: [RFC PATCH 1/4] uprobes: use set_pte_at() not set_pte_at_notify()
Date: Thu, 31 Jan 2019 13:37:03 -0500
Message-Id: <20190131183706.20980-2-jglisse@redhat.com>
In-Reply-To: <20190131183706.20980-1-jglisse@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 31 Jan 2019 18:37:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Using set_pte_at_notify() trigger useless calls to change_pte() so just
use set_pte_at() instead. The reason is that set_pte_at_notify() should
only be use when going from either a read and write pte to read only pte
with same pfn, or from read only to read and write with a different pfn.

The set_pte_at_notify() was use because __replace_page() code came from
the mm/ksm.c code in which the above rules are valid.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org
---
 kernel/events/uprobes.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 87e76a1dc758..a4807b1edd7f 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -207,8 +207,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
 	ptep_clear_flush_notify(vma, addr, pvmw.pte);
-	set_pte_at_notify(mm, addr, pvmw.pte,
-			mk_pte(new_page, vma->vm_page_prot));
+	set_pte_at(mm, addr, pvmw.pte, mk_pte(new_page, vma->vm_page_prot));
 
 	page_remove_rmap(old_page, false);
 	if (!page_mapped(old_page))
-- 
2.17.1

