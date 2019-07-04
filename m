Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89197C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:03:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D97218A3
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:03:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D97218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECD846B0005; Thu,  4 Jul 2019 12:03:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7DFB8E0003; Thu,  4 Jul 2019 12:03:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93CA8E0001; Thu,  4 Jul 2019 12:03:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA7396B0005
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 12:03:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 199so7233763qkj.9
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 09:03:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fhQ0Se92Bm2BbYqIGhm1cI+ZAFO1eywerRnSPIIlkBw=;
        b=j98LWkRdRyzr7+K3Y6btLS26L2Rcyv9VfOvubqKhLdp+cgAsxbPieLykqGt0wZweQC
         SHcpZLx8Blo1DiXWP4PTyBWOwqkepAjEghZVynY11APR4JORDDE2GrIVH43jDBOapVwk
         W0YK/ELqSyPn87nI2LBwqc8bBHMOx4Zvsv+0QybClPOE1kxxogmCm0cm6DNKZ1GwUoxH
         TZ/mFCFYQwt8U80xqqYFOmIRqdfvVyDTGU9WqL7vXJX2D1OUBZ77ueYXYlb4HAVKD0x7
         229qOh6WvPHw7jpAKaTHQ0RZZO3LwbM4RGMjYy/o0GBVQgykEUdHrP5yiwBQ+rDDBcsn
         XzBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/xsdfuVXfCoh5is58DuBhe4tX8rq+GrT08SfOvrFsp4vMWQ0K
	S8lN4DTF3bqQd+4X/YQj+x/C5OnQyWHh+ZxtP7HeJmra2IypjDzT6u9RRL2Pvg6YN/gyC9UhTty
	x2lPZgFFro0115TBBUgpfgZkTubCQIUef0lbDSuC9pLF9nTwKPxfZ2y6cWHUbqB6+Kw==
X-Received: by 2002:a05:620a:1537:: with SMTP id n23mr25871510qkk.441.1562256203537;
        Thu, 04 Jul 2019 09:03:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNY7IK248V2bK8fVQLfFnVhFe8s4tIGJV1NrmXT5VLrZRV5/OO7bVrHkyE9y+QiOw6y9lh
X-Received: by 2002:a05:620a:1537:: with SMTP id n23mr25871469qkk.441.1562256202937;
        Thu, 04 Jul 2019 09:03:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562256202; cv=none;
        d=google.com; s=arc-20160816;
        b=KdVzUmJDfRGhz0mH/9aG9tCq5Q70wGydaSSv4B1E7DsL03X08RpN5bgNuqA9+HKh4o
         H2TN5MSNSenaiQAMlXU+oWd2gGsOa6YvaNsryYRPtNLKBDJGMnE8jQ+/M8vdhxnbdmwj
         M1CkIRP1SkVp91KPb5Foi1Ar254/lI6V2q0uJ7HdQJv8bFoV9jr5HYTRyBWXoratHY/l
         QLPiRUv+D9cnPduf2sibWdQOPb800ah6sfPxbEg1THCexHTvsgTB7CN33KVJ+uxvtLYL
         v4ALKbEkvie3fOTzJeLKk3vr5O0LKt/SPCaMXAhmhZE088NRQjSy8WB7f5bS/vI33EHU
         4hCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fhQ0Se92Bm2BbYqIGhm1cI+ZAFO1eywerRnSPIIlkBw=;
        b=P7WWu97wjpbH1Cz39/Msjo740R48k7lDad6tiEKsFasjuPDVe6I7Vzg5IUSbIdY95k
         Gga1zzGoUQCHzEP5aU08FnwTZvzoTcCwX6A3g9pk0OH6B42qkeO4C706VBRNWTM/dAW+
         Jn2x0QU5+L2YuwMjnHShq6MjicYogUZ8ExAayYveCAihHecFiRJaDzPzeB/fhaDTKRuo
         GtVSyiLGnSqFcJsygRrkGk2hUcZvNLMPzqeOHyyavf9kTmhJe09bCY3nJOT/bLcjjFme
         Ug32I08x1u1SIASVrYCssd5ZJkgVq/cyRkr7iqXq87L5OhDI+A1I+QGPewjH8q+qBd4P
         JoAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d10si4234711qki.348.2019.07.04.09.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 09:03:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8F49481F0D;
	Thu,  4 Jul 2019 16:03:05 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id A2240BA7D;
	Thu,  4 Jul 2019 16:03:02 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  4 Jul 2019 18:03:05 +0200 (CEST)
Date: Thu, 4 Jul 2019 18:03:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, axboe@kernel.dk, hch@lst.de,
	peterz@infradead.org, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>
Subject: [PATCH] swap_readpage: avoid blk_wake_io_task() if !synchronous
Message-ID: <20190704160301.GA5956@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559161526-618-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 04 Jul 2019 16:03:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

swap_readpage() sets waiter = bio->bi_private even if synchronous = F,
this means that the caller can get the spurious wakeup after return. This
can be fatal if blk_wake_io_task() does set_current_state(TASK_RUNNING)
after the caller does set_special_state(), in the worst case the kernel
can crash in do_task_dead().

Reported-by: Qian Cai <cai@lca.pw>
Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 mm/page_io.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d..3098895 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -140,8 +140,10 @@ static void end_swap_bio_read(struct bio *bio)
 	unlock_page(page);
 	WRITE_ONCE(bio->bi_private, NULL);
 	bio_put(bio);
-	blk_wake_io_task(waiter);
-	put_task_struct(waiter);
+	if (waiter) {
+		blk_wake_io_task(waiter);
+		put_task_struct(waiter);
+	}
 }
 
 int generic_swapfile_activate(struct swap_info_struct *sis,
@@ -398,11 +400,12 @@ int swap_readpage(struct page *page, bool synchronous)
 	 * Keep this task valid during swap readpage because the oom killer may
 	 * attempt to access it in the page fault retry time check.
 	 */
-	get_task_struct(current);
-	bio->bi_private = current;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
-	if (synchronous)
+	if (synchronous) {
 		bio->bi_opf |= REQ_HIPRI;
+		get_task_struct(current);
+		bio->bi_private = current;
+	}
 	count_vm_event(PSWPIN);
 	bio_get(bio);
 	qc = submit_bio(bio);
-- 
2.5.0


