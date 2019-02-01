Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B5BAC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 08:56:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 449C720815
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 08:56:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 449C720815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0CB08E0002; Fri,  1 Feb 2019 03:56:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBC528E0001; Fri,  1 Feb 2019 03:56:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAB548E0002; Fri,  1 Feb 2019 03:56:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA388E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 03:56:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so2538527edb.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 00:56:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=WrXnCZ+PGX6lzv+WoXBqVgVFhevifRruGkRrCB1xf/Q=;
        b=aUWAx9qqOcvnP6tf921uGQ89072xWqTRpD714jIk8APp1udndwN+J53auR6Udo0PoR
         JB3KFS9RYlZXTXJXjBrM1XsfA6ubfUzYH2zlwRGvq2kk2f+UWA5exHvbahSGLzkmY5G/
         2eaTMDqkkIv2akG2LW4ms0Iy24PDS4NII5PixBjAPNsVBq6wwc3KkhgXL2WFKL6yP1ck
         3+5OeZajeD6LBUb+K3DuoHrf2pJAzkC+4/fHTtWgSYA/8ywFjLQqTqpyWQfr5uYpZzea
         YLtzkI9EOtwEQM+LkJUB1wIpos/ZxlqkgA9rp6O+i1E0ylLPlMaJdgRNpEbNWdSAYn/s
         S9oQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukfwBgFif7Q6ozhrJFi9SnuPuUt1pWs5S0zjb+NaXkGvyLTQkVzx
	akbxeDhwZSTGQFYqhFJ6xlgmO9qTMHIhtXMCbM5A0rR/GEW06KXzKrPNBXIcghXdfnDBPFKQElh
	esVnAXE8FAsx4kN3AW/67IGzM9RP5Eqx9u0oKRlEwJs1CoEC+FwAsGQWt/VOmRcU2Cw==
X-Received: by 2002:a17:906:7c42:: with SMTP id g2mr34138424ejp.212.1549011378765;
        Fri, 01 Feb 2019 00:56:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7TXplDb20AtnpD2A1wGS015J2F/qoeoyqzFSTi9Y+7yWPLkTqK6xIcwUB4aUf+5YLwhaVw
X-Received: by 2002:a17:906:7c42:: with SMTP id g2mr34138363ejp.212.1549011377607;
        Fri, 01 Feb 2019 00:56:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549011377; cv=none;
        d=google.com; s=arc-20160816;
        b=VnfFIHR4efr72MC1MvwDODWf6Xa9VOuQggoR6bidZsxOa7A5C+O1Q61hzEsEEEtPH/
         Bdtk5kja2qe8NNW+Kyuj7jUM5US0CD1YPNc1FO15emMXDUKB0S5sDNnyJPNDtZsNpa3x
         Z9br6sZxYThu5OicVqvY2SmN5i/35pW4AqNng1PXkP7MaySHOk2fBzZm9P9GDNrJXHcA
         IHcWZ4soMm8aU7nBVbwFp93Kd1v8BUhqMSbra64OldjbgqYgab9FfhSSSjukyRRaGq9n
         12nYZERFiDh59xPNwNZ3O5GxawgDAPVD2l1q/7cSo4UbamcXOICaSQaTREmz/YF3juoP
         Crfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=WrXnCZ+PGX6lzv+WoXBqVgVFhevifRruGkRrCB1xf/Q=;
        b=omurJvFIgPC/cxI9KXBpEfEy+6Zr9komQ3mzeTSAMGV54KYDn9WJ9emkgdgZWBzjzV
         qB6Y5r5HzCT91jZqbHphqlFF3QOVIA98iF8DHBF448wPZcnLd0fdT6iXCz+//c92KuZH
         tW+1Cc6GtSLTJQv/7lz/S1QCR2JHMaD2Gn8Ix/YGd/FzQEnuyUEWGvGtgJzw9b1WlBQa
         P/yUJbCedJAKbz56TTjtfUVJG0yzCkDc+4FS3l8SDrZQ05Zcd7Hy75AQP1nGydwaVbg+
         1Bs1y/lK5qkEO/2b8KNgPARF8tNiOQQ/QyxFG5oq/CBPymUtYgqO9cwXOJuhqGbnFR1/
         TQDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si795236edr.142.2019.02.01.00.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 00:56:17 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6CECAAED0;
	Fri,  1 Feb 2019 08:56:16 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
To: Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
 Jiri Kosina <jkosina@suse.cz>, Dominique Martinet <asmadeus@codewreck.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>,
 Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>,
 Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss
 <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-2-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <de52b3bd-4e39-c133-542a-0a9c5e357404@suse.cz>
Date: Fri, 1 Feb 2019 09:56:14 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130124420.1834-2-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here's updated version with Michal's suggestion, and acks:

I think this patch is fine to go, less sure about 2/3 and 3/3.

----8<----
From 49f17d9f6a42ecc2a508125b0c880ff0402a6f49 Mon Sep 17 00:00:00 2001
From: Jiri Kosina <jkosina@suse.cz>
Date: Wed, 16 Jan 2019 20:53:17 +0100
Subject: [PATCH v2] mm/mincore: make mincore() more conservative

The semantics of what mincore() considers to be resident is not completely
clear, but Linux has always (since 2.3.52, which is when mincore() was
initially done) treated it as "page is available in page cache".

That's potentially a problem, as that [in]directly exposes meta-information
about pagecache / memory mapping state even about memory not strictly belonging
to the process executing the syscall, opening possibilities for sidechannel
attacks.

Change the semantics of mincore() so that it only reveals pagecache information
for non-anonymous mappings that belog to files that the calling process could
(if it tried to) successfully open for writing.

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
---
 mm/mincore.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..b8842b849604 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -169,6 +169,16 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+	if (vma_is_anonymous(vma))
+		return true;
+	if (!vma->vm_file)
+		return false;
+	return inode_owner_or_capable(file_inode(vma->vm_file)) ||
+		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -189,8 +199,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
+	if (!can_do_mincore(vma)) {
+		unsigned long pages = (end - addr) >> PAGE_SHIFT;
+		memset(vec, 1, pages);
+		return pages;
+	}
+	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
 		return err;
-- 
2.20.1


