Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C92C7C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 867FC214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:43:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 867FC214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C0DA6B0007; Fri,  9 Aug 2019 08:43:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1718F6B0008; Fri,  9 Aug 2019 08:43:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A056B000A; Fri,  9 Aug 2019 08:43:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABDDF6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:43:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z2so1261486ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:43:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qihvdteIfLvHRWEnF/5fPjtUVrcw+kHezCMiuZJhEco=;
        b=VUwk/RJ2nBWXX7OeowXJLnLOQSrwrVt4oLn0PRI58cXKwKMQkld/yIxaPTGbZa4w7N
         g6r6OcPZdMCQypvYUEVlRqD5q7x/vuGGUirvv1z5R3BhJYN2RK1IuSp2ZJy+dtCKjNRI
         CiNXqNbWr0jttUxSmErTyvWlQoy8y8WHbE+7Qp9DhOZjkWBKTKJeD7BKBJHrzns09OLx
         50f04Tt+cDQR0c1Oow6mV8l/FKtNS2D+eZznqnGe4RVJ+bTg7EvlWcWy8JRVPVZk0O1o
         k7EgaCjC9R+LN3qwqAz+ynvtgi6hoTY00rwUjAdwzJncpqIVIxFS0plGj6DNOZvS+NEi
         ISiQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUPZcPmsI8t4YnUGTDnj/dtKxgxZu7tnnbAPPcS2cDu+A+ql/sz
	C6jGZlO+YowmiVb10nlGaa6cUl20zS3zTpkurc0+fezwNUlMytrG+Femcbou9U3/eYx52GhyrDW
	/5mDJTS1CC08RTmhD8z2/UeSgCLUwPna9XjV8LKubjCbrf3MeDVhJ9KuG3bjgtMA=
X-Received: by 2002:a17:907:208f:: with SMTP id pv15mr1795097ejb.103.1565354607185;
        Fri, 09 Aug 2019 05:43:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQQAGfOb/fRnOXLEMxusvR6Mt69HtLRNGSHuMVlc3mshpgSlYDeAyuHUweK1mCAGDkgceb
X-Received: by 2002:a17:907:208f:: with SMTP id pv15mr1795044ejb.103.1565354606327;
        Fri, 09 Aug 2019 05:43:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565354606; cv=none;
        d=google.com; s=arc-20160816;
        b=vklOrpKXx0yMKcvHAxjJ00e+CU1BaHZxBhQZv68PkV8r4BfjQhziEfKG+4t9jlUp0K
         U3fGCv80L77xvU9Z6VGQVTvEc60LTfXsBHbJ7u8sPq8ULSQdPE0ykMrRFs2TUTCn3zVe
         RaRzAyHlSftJbofD6fm5TDtIfojvHJz7oKcbCWgh6CCgXPAEdwX0rG+cxaD7ZUgnoRX9
         DCSod+WfkKY+Dlsu5dIBQUlgfW/7FhtG1PBKD+z3kbVpvIG01fF27XlHHx5pt4x0NBs8
         /0HeOMyizcL6ZmMO15VgGCTeSmb5zQB9EG0cZDQhdynVmZ+PcPon5Uju6Gjj1wl7cfrt
         E7cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qihvdteIfLvHRWEnF/5fPjtUVrcw+kHezCMiuZJhEco=;
        b=q+sTAgSr0VwHensiSyyPVXas1BlptsbP5/huYeGHkwt5v2qGYZ/AE7M7LgIjH8U9PJ
         AwRG6jvpTtB92rulo9+HRFu+R3wWHVD6G2etgxPgZbeBBj2pAcQzWje3s5qU82DWu046
         sbIWVI0/bt9az2W3fJWNrExm83+78KhfmiKjIPmWa5Mjyexa7MNtWCH8Qp5oqYADQq6y
         YMiaeAu+3QTb+tLseketDo8mQBY7ow5LgLAl+lrGPFkx51wrSGC0aREvgildyNc3rl5Z
         M7jLnfCi74wUw3Uu9kkXQoyipY83hD3+St9Wtec4EAIcoAaj3QJ7QxRXXVLjlkdK00eb
         ND6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x34si38443586edm.138.2019.08.09.05.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:43:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7472BAF10;
	Fri,  9 Aug 2019 12:43:25 +0000 (UTC)
Date: Fri, 9 Aug 2019 14:43:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH] mm: drop mark_page_access from the unmap path
Message-ID: <20190809124305.GQ18351@dhcp22.suse.cz>
References: <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
 <20190806105509.GA94582@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806105509.GA94582@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 19:55:09, Minchan Kim wrote:
> On Wed, Jul 31, 2019 at 09:21:01AM +0200, Michal Hocko wrote:
> > On Wed 31-07-19 14:44:47, Minchan Kim wrote:
[...]
> > > As Nick mentioned in the description, without mark_page_accessed in
> > > zapping part, repeated mmap + touch + munmap never acticated the page
> > > while several read(2) calls easily promote it.
> > 
> > And is this really a problem? If we refault the same page then the
> > refaults detection should catch it no? In other words is the above still
> > a problem these days?
> 
> I admit we have been not fair for them because read(2) syscall pages are
> easily promoted regardless of zap timing unlike mmap-based pages.
> 
> However, if we remove the mark_page_accessed in the zap_pte_range, it
> would make them more unfair in that read(2)-accessed pages are easily
> promoted while mmap-based page should go through refault to be promoted.

I have really hard time to follow why an unmap special handling is
making the overall state more reasonable.

Anyway, let me throw the patch for further discussion. Nick, Mel,
Johannes what do you think?

From 3821c2e66347a2141358cabdc6224d9990276fec Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Fri, 9 Aug 2019 14:29:59 +0200
Subject: [PATCH] mm: drop mark_page_access from the unmap path

Minchan has noticed that mark_page_access can take quite some time
during unmap:
: I had a time to benchmark it via adding some trace_printk hooks between
: pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
: device is 2018 premium mobile device.
:
: I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
: task runs on little core even though it doesn't have any IPI and LRU
: lock contention. It's already too heavy.
:
: If I remove activate_page, 35-40% overhead of zap_pte_range is gone
: so most of overhead(about 0.7ms) comes from activate_page via
: mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
: accumulate up to several ms.

bf3f3bc5e734 ("mm: don't mark_page_accessed in fault path") has replaced
SetPageReferenced by mark_page_accessed arguing that the former is not
sufficient when mark_page_accessed is removed from the fault path
because it doesn't promote page to the active list. It is true that a
page that is mapped by a single process might not get promoted even when
referenced if the reclaim checks it after the unmap but does that matter
that much? Can we cosider the page hot if there are no other
users? Moreover we do have workingset detection in place since then and
so a next refault would activate the page if it was really hot one.

Drop the expensive mark_page_accessed and restore SetPageReferenced to
transfer the reference information into the struct page for now to
reduce the unmap overhead. Should we find workloads that noticeably
depend on this behavior we should find a way to make mark_page_accessed
less expensive.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..ced521df8ee7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1053,7 +1053,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				}
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
-					mark_page_accessed(page);
+					SetPageReferenced(page);
 			}
 			rss[mm_counter(page)]--;
 			page_remove_rmap(page, false);
-- 
2.20.1

-- 
Michal Hocko
SUSE Labs

