Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DF1FC10F0C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C16DA21734
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:17:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C16DA21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB4868E0005; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B208E0007; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 995E78E0005; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34EDF8E0004
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k32so1135319edc.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JqJ7+Ah6HvL9avHk7AQXUYUEQBRFVjWD/VGM0xcL36s=;
        b=PJi27gW7CZTnZ0JzySgH24Qd3McYWiNKnLDV4Sbep11e0wFHOU4aUnTI1odlwN+Xsv
         EUGLj/rwuR6GIArt8wfgEm30sFwyMxtx60ZG/9bZVFW2OqAs53Lr9cT+oJ6NpZlcA81g
         fp7eCETs37t+tfKTUAh9JDGG/9RE13MhQ7sHOyk0LRt38uo96EyP6Sj6Y5TIA19BZxVH
         amRBg3zmncmVE8eDk4MJ17kZcUSm62S8s/pt1AuK7hPLGqvb7fV3eofQ3F7QQaw43gYO
         aZBV1kGu1VWg+lMH3DoVF9ttUmesUrlshVgtpvlPLgz2jsRI357ngGuh0REnsiobwNGG
         /BUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUmeVmuYWLl4E6TjZygBr77ZGQgTdo2hdvuuU54Fq6CtA6DHYGZ
	FjpdMVU/vD0iEfsTRUf+SVrHBypex65CR76KwqnnK3HPJNnrGimCimLn27Fyj7OfvwpHjkpFWGl
	oLXSXBsOyNz6FLckcBkw1i//VjfFvLoHY3uEqo36QYF3RBOKTF8M8Yy8fjWcTb6IkkQ==
X-Received: by 2002:aa7:d959:: with SMTP id l25mr3588546eds.236.1552400274777;
        Tue, 12 Mar 2019 07:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxM67nTVTHDeOk/NPTaaBbXxmsRYg2vKPcJXXohs5SQHa2fHuZazJoBPV6XposKbj73NQH
X-Received: by 2002:aa7:d959:: with SMTP id l25mr3588485eds.236.1552400273749;
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552400273; cv=none;
        d=google.com; s=arc-20160816;
        b=WiH93Cyuv5ddRWYQY0CPJqU1d5cvrGSDTsRNCSRsQnscLjdgVFBGOltpAtKXk9Ovud
         BSCp2ZpOlDWQiXCwlvcpxrRajCvl/dk/S+UT34n1quBXJXRqEyl9psdFdlDCIj8lAnbH
         bU1K2bIaJpHPl/IKpzSRMiCArieF8afpR40LKL8FYV4/6juaQTbAE1UO7qkSfu5jTsn7
         +GHjy4PZ5Na9wZGX9WV2NI78pGLRJ2nu8Y5m25V+FZxAc4Vqvg35dq//dMwMVH1OAPsC
         uUTlnySRuzCry/HZWmrJQmFqDR8dCAe4ygaQq7uAviR7VvZdXlUG9sSta3M3Xqnl5wco
         5Ezw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JqJ7+Ah6HvL9avHk7AQXUYUEQBRFVjWD/VGM0xcL36s=;
        b=cGJ2gXPPL0onqTdNcHWX+oNrcRD8f69eQXAB5u/BqB1x0J3iDf3Kfq+u6DAdxqXQWd
         2BvA8OucKWRz0iCs4onBo8gNRhXIZOZO1I+cpGUjBMEwdhDYkktzWHqoGHIRdXn9MRdZ
         8tP56h5dBhorEPsc0zis/+NO6Q6CLpXY9DG6zhSnzZ4x3uM8NsgJpeTV8jnK32RC25Ia
         ic4y4l5Y4yn1NqiESjEgobCpkHCA46hhE1gFz6dVOgFfAojVJ/2Q7f5LUm0VZZwsf51q
         flWws/gZzaaZJOMhERagA07yTYW/NjGjOn+vq3bnj65UUTJoEOme2REbqnkKy156+S+E
         8Zfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1si6415083eja.30.2019.03.12.07.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6EB2B644;
	Tue, 12 Mar 2019 14:17:52 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	Jiri Kosina <jkosina@suse.cz>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>,
	Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>,
	Vlastimil Babka <vbabka@suse.cz>,
	Josh Snyder <joshs@netflix.com>,
	Michal Hocko <mhocko@suse.com>,
	Jiri Kosina <jikos@kernel.org>
Subject: [PATCH v2 1/2] mm/mincore: make mincore() more conservative
Date: Tue, 12 Mar 2019 15:17:07 +0100
Message-Id: <20190312141708.6652-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190312141708.6652-1-vbabka@suse.cz>
References: <20190130124420.1834-1-vbabka@suse.cz>
 <20190312141708.6652-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jiri Kosina <jkosina@suse.cz>

The semantics of what mincore() considers to be resident is not completely
clear, but Linux has always (since 2.3.52, which is when mincore() was
initially done) treated it as "page is available in page cache".

That's potentially a problem, as that [in]directly exposes meta-information
about pagecache / memory mapping state even about memory not strictly belonging
to the process executing the syscall, opening possibilities for sidechannel
attacks.

Change the semantics of mincore() so that it only reveals pagecache information
for non-anonymous mappings that belog to files that the calling process could
(if it tried to) successfully open for writing; otherwise we'd be including
shared non-exclusive mappings, which

- is the sidechannel

- is not the usecase for mincore(), as that's primarily used for data, not
  (shared) text

[mhocko@suse.com: restructure can_do_mincore() conditions]
Originally-by: Linus Torvalds <torvalds@linux-foundation.org>
Originally-by: Dominique Martinet <asmadeus@codewreck.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Kevin Easton <kevin@guarana.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyril Hrubis <chrubis@suse.cz>
Cc: Tejun Heo <tj@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Daniel Gruss <daniel@gruss.cc>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Josh Snyder <joshs@netflix.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mincore.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..c3f058bd0faf 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -169,6 +169,22 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+	if (vma_is_anonymous(vma))
+		return true;
+	if (!vma->vm_file)
+		return false;
+	/*
+	 * Reveal pagecache information only for non-anonymous mappings that
+	 * correspond to the files the calling process could (if tried) open
+	 * for writing; otherwise we'd be including shared non-exclusive
+	 * mappings, which opens a side channel.
+	 */
+	return inode_owner_or_capable(file_inode(vma->vm_file)) ||
+		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -189,8 +205,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
+	if (!can_do_mincore(vma)) {
+		unsigned long pages = DIV_ROUND_UP(end - addr, PAGE_SIZE);
+		memset(vec, 1, pages);
+		return pages;
+	}
+	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
 		return err;
-- 
2.20.1

