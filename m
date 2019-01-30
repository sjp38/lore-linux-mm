Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37736C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0147520989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0147520989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A1D78E0001; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84B548E0003; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EDCA8E0005; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 342FC8E0003
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so9393483ede.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:45:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gR8hjRmommIPz3aLtYKpIHs+oBCBI/oZoS9lhEjaZDg=;
        b=XdGsxWzM7lINEZNmTMDqg4NajmfkqxyjbqK8zJkTQn+eJaaqByV5NZRd5qFMmv3w0u
         QrUUBCF5MB2i8L2e1Ic1UZ8JjRMCwynYv4m5QV3cfiVdMaeyesy3jXA3FR8UZnNoJa3t
         2jqbqCUw/Xw4C4/iF3xdcxjonRBOn/5vMRpQ3HuBPgzdHm2TBxGPfonPd4tuizNuKMrB
         kHOKXeZGF2lSlsJ98b00j2cUMLEG2NJprNw8Iy6I3PUsEWCAJ6dzvCQxh7T5dOKkxHrn
         CmiLxGK7YnZJ9ngzdu3suAGFayZtQ8ErsAEXT+Fn7CEM42alGZVKDeb5SbhkI5eOhUmL
         A2Fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukdWtruSGjSwxPEP+EMNjGH+HihpqeMNb1upeOUCGqw5NgILs++5
	lOfRqPn/NJjajDtwcRG/4wnThCcVOvEYfDLDchefnknu8Wx54bVs8J1RQha2xy9ce8FNlYXaib+
	Fy8nwRZueous65JtjlUxioTXU0tzV+mjilRNlvbHoe1AteBEyCCZUW0qMws5Z60RvFA==
X-Received: by 2002:a50:f61e:: with SMTP id c30mr28992175edn.197.1548852315565;
        Wed, 30 Jan 2019 04:45:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6dgEgKO6DE47q4m2yOtTp9UWIyOFsef2yTW8ylEGHMQ2XpIVgjZ5BOCZXXXHOxuAencAkO
X-Received: by 2002:a50:f61e:: with SMTP id c30mr28992097edn.197.1548852314169;
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548852314; cv=none;
        d=google.com; s=arc-20160816;
        b=FOuzUrcSCtkulEuTP5zqiqIa0+PBru8S8lldvnj1V+69/6UfK/0HEtOydkBUoze8OC
         c6ma4krd0ruMvAF6PQFPgB4RwZ5SDigtUfmm3/9Q0+//OALNgduW590zRdpP2WmRbNji
         sDExsmuNTvzlr77UYErG3E2ZHDi4SHmpgWdyyhIKOdDVfmeCnwI7uOUuuqPq9GLxX+ew
         tae2Y0llXwXl20yGYlD4v8QM/Dq1Ughxbs+CDOZoYCirK5QBHpqAIYDud6gEtiFtFrNZ
         P+20A6GSJdDCRLXlRgTJvx1n6aJo1IzBW3+glB+POl4ntEzDijeA/o0Hz69qH3ae2Lo8
         Fdmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gR8hjRmommIPz3aLtYKpIHs+oBCBI/oZoS9lhEjaZDg=;
        b=phUWKu0jMsj7VuJy4V///fk7/e7nI7zBhlyDcHCwH4tcRAB/71gohzl6G56SwxCzwF
         EHeQ2ZtwjK7ykjQZj/4/tTxxRCOG1KeAcKdkabVaGqY07MukH1LkS9ZQo69+4mRjeDxC
         RTaMk8j3wch4cYE48rPkTeggHGAN3A4s570Kf2SmFvR0fBS4SRCNttTI+Xz1/J7Z2XR3
         CoK7SNZDqCNNG7U/QEgzWZdw33VqBrlkHwoEit+7L8zuVOfPp3OQr5mVk9OL2T+hykss
         Rc67ulExVDAE4RELiNNr0D/lX3vW6eu44tv2CM+m+2ifuuDhmD4n/Vpsik+FK9tPi/IT
         Xrcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si865234edl.131.2019.01.30.04.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 41B7BAE88;
	Wed, 30 Jan 2019 12:45:13 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Jann Horn <jannh@google.com>,
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
	Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O
Date: Wed, 30 Jan 2019 13:44:19 +0100
Message-Id: <20190130124420.1834-3-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130124420.1834-1-vbabka@suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jiri Kosina <jkosina@suse.cz>

preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache contents, as
it reveals metadata about residency of pages in pagecache.

If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page not
resident" information, and vice versa.

Close that sidechannel by always initiating readahead on the cache if we
encounter a cache miss for preadv2(RWF_NOWAIT); with that in place, probing
the pagecache residency itself will actually populate the cache, making the
sidechannel useless.

Originally-by: Linus Torvalds <torvalds@linux-foundation.org>
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
---
 mm/filemap.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e..7bcdd36e629d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 
 		page = find_get_page(mapping, index);
 		if (!page) {
-			if (iocb->ki_flags & IOCB_NOWAIT)
-				goto would_block;
 			page_cache_sync_readahead(mapping,
 					ra, filp,
 					index, last_index - index);
-- 
2.20.1

