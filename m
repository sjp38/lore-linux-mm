Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D3DFC43444
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E0E520859
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E0E520859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5916A8E00A3; Wed,  9 Jan 2019 11:40:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A3A8E00A2; Wed,  9 Jan 2019 11:40:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A8E8E00A3; Wed,  9 Jan 2019 11:40:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2D9D8E00A2
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:40:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so3114657edb.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:40:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hrxtyRmtbXqzCLozOcPVEDaxh/hePTam7Z6TNNXN3T0=;
        b=FjtAwoQGjyDaKQ2plXtUQWKbkrFt6XraqQAUTd7qygRPyDAgACtyVr9OTn9xhkeisl
         qhBfs2wEmVUf7NUhEeygDs//jAO+AHLkBD2tcDcKcLJYNTfPDnINSHJvSTamtEyZQObw
         e1YQS6QMHPzqAnpJPTA5BsGIOcbT0jg9rusn0w2j2ZQCX8I8Ifbzh+836/yq021QVOOc
         RgF/ir5xt9TxGLbO68Njhycz9BRP+Tbcq7I65XhHEP9XTCYcwN6Jw4XU4l++thIfU3av
         PrcLoPfPu0jCZkJi65HwFdHfYks2Fmv0ATE1bKxVjWrLt5xBmgNoGiksNF4DT0Lb6XVX
         CGZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: AJcUukdSKIpBEgI0vN+VMdHruK+YZa/8v3nWf/SjuhVYvzb6AGQOusfF
	qXXRUKBrvi3o1mmXebLVoIME+4JNyJHg4VWGNrMkkDqg3Fp0wcSgXgil3KISVbKgqvUPu8elOPh
	XztZ7thng6TZb8dnNZFvjgJgL4y+5wCVQgvvR/l5TRtQRAzZpj0uaSimH8dG3sVz5SA==
X-Received: by 2002:a50:a458:: with SMTP id v24mr6610305edb.241.1547052042357;
        Wed, 09 Jan 2019 08:40:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4rNSA/vcVPlH7yfc//smv4vCROgzw9vs1up4UQq5qBqD7xFtan1YrjEZsTptD2RXTYdlrJ
X-Received: by 2002:a50:a458:: with SMTP id v24mr6610051edb.241.1547052037641;
        Wed, 09 Jan 2019 08:40:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547052037; cv=none;
        d=google.com; s=arc-20160816;
        b=ezmKzCMTm4lHY4JF2+a5LIOZO1YudyYBE4JLT0fOSq7hGYwog4ZOSsDdiRnRZ6r9ua
         7ucv7wu3Qbbg4LTazAbRVNnPf4Q5rMN/9Z7OmGpg3Yji5pIiiUVSNlc2mS7KsIi8VmRz
         M5Cd94oCe2mxi35VMVcuZ++Ju45nUkzrPWFm9E+m45KOafwGBgukM1sJOug0c4dER+YU
         6NQNUuY6DuQFMQ7YsU5s882AAnzLBSD6N+BEcUxZa/akJ7CfIFEyS4KJ2zQXNXvmVxN8
         mk8198Aklzvn0B3lSj0dilH5zxWtJIHAXsHQ7fyJ2QciyTdhmPEF/aALDbJr9UHokp0T
         RQkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hrxtyRmtbXqzCLozOcPVEDaxh/hePTam7Z6TNNXN3T0=;
        b=Et7X3wE5MhQIEYVvdbpmvUCfdXTnPAFVVgpb4Zw3JgM6XTsrcuYt7xcK+BzYcXYHi1
         uQpT2hGYXyJYJVRAyQjZiK7hJipXBxsBgRR1lsAfEYH+/vXPyHHccgS+4x5Cs8PCY6Ve
         OwpqZx939CWPtfLX3REfHu6D0N4+nVWM81FVC7KXUCXzFN9CuxryFCfRugc8hWN2rqeb
         P4G21AS/DenO17TeuxjsGU5exIoHguwn3hBgiOULviVkJZWzS1iKBtDgNSjazyfYWJhS
         y9vkDc+ogg8rDmOfnCPEZADQ0H5AwbeSq6TVYcwOUPSJK8ZIm46yXOiDp1Jdfwtb417s
         5Jbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si1445005ejm.81.2019.01.09.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:40:37 -0800 (PST)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2F557AF58;
	Wed,  9 Jan 2019 16:40:37 +0000 (UTC)
From: Roman Penyaev <rpenyaev@suse.de>
To: 
Cc: Roman Penyaev <rpenyaev@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH 01/15] mm/vmalloc: add new 'alignment' field for vm_struct structure
Date: Wed,  9 Jan 2019 17:40:11 +0100
Message-Id: <20190109164025.24554-2-rpenyaev@suse.de>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190109164025.24554-1-rpenyaev@suse.de>
References: <20190109164025.24554-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190109164011.Y9Jbig96bumAB93SgjTRsFsFVxjswuycvHDp-SFQtrs@z>

I need a new alignment field for vm area in order to reallocate
previously allocated area with the same alignment.

Patch for a new vrealloc() call will follow and this new call
I want to keep as simple as possible, thus not to provide dozens
of variants, like vrealloc_user(), which cares about alignment.

Current changes are just preparations.

Worth to mention, that on archs were unsigned long is 64 bit
this new field does not bloat vm_struct, because originally
there was a padding between nr_pages and phys_addr.

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            | 10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..78210aa0bb43 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -38,6 +38,7 @@ struct vm_struct {
 	unsigned long		flags;
 	struct page		**pages;
 	unsigned int		nr_pages;
+	unsigned int		alignment;
 	phys_addr_t		phys_addr;
 	const void		*caller;
 };
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e83961767dc1..4851b4a67f55 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1347,12 +1347,14 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 EXPORT_SYMBOL_GPL(map_vm_area);
 
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
-			      unsigned long flags, const void *caller)
+			     unsigned int align, unsigned long flags,
+			     const void *caller)
 {
 	spin_lock(&vmap_area_lock);
 	vm->flags = flags;
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
+	vm->alignment = align;
 	vm->caller = caller;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
@@ -1399,7 +1401,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 	}
 
-	setup_vmalloc_vm(area, va, flags, caller);
+	setup_vmalloc_vm(area, va, align, flags, caller);
 
 	return area;
 }
@@ -2601,8 +2603,8 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 
 	/* insert all vm's */
 	for (area = 0; area < nr_vms; area++)
-		setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
-				 pcpu_get_vm_areas);
+		setup_vmalloc_vm(vms[area], vas[area], align,
+				 VM_ALLOC, pcpu_get_vm_areas);
 
 	kfree(vas);
 	return vms;
-- 
2.19.1

