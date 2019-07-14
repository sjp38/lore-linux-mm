Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62F60C74A44
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 21:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AEC820C01
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 21:20:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AEC820C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0836B0003; Sun, 14 Jul 2019 17:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6503C6B0006; Sun, 14 Jul 2019 17:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519A66B0007; Sun, 14 Jul 2019 17:20:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03F5C6B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 17:20:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so12032209edv.16
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 14:20:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+F6nQ1DCkOYoAduUWsweXvem5b4lpcHa80JSEL1ErbQ=;
        b=NrJ9nTiB/WBznaQQ1+3kO0HUahwrtjlBrKD5VDme5AcmYUCILs/01Tciw7I9VioDcf
         fRwf0soaD19G1PEcE/Zjgn7r38nnBNkWL49blPxy5NJ4KYDI5huWlsbvy9EzJK3fGypb
         uH6hqe6oRp7f90VY4UjQaUUyxaM76uPX5DjkQ34ri7Uv1Js4hMUCdWojvDWSwa7infiD
         IYi9oyQ/F7MZPiiGFE0g9od0EEnsZR/+encNXLnUfMbegHyqgTefbOe1KMK5lFB8g6/2
         BHDQdLWfX9oJTodpm3nNNhIdZGHI/qN67Q+4d5mxLg5qiBUO6g7MSEjMSDjYidVi1ioF
         Rs5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAW1MeGPJSpCemxBO31HzWAVzlkLTUO7dYyyxK8bUIJjWJNPzTza
	1OJE0I4BdG3arkoFn2NMnFVR5GkXCLY0Vwjk+vlNX/3baQ/9Fpz1T+h9RfiI4YMHyxHd89iHgHh
	QS+Ss8hVxBy40EDTVGhgPVK6NOl46vnrEUtgzAeJ8NbSoD9nf6/5SVt4dNXWx0GLDPg==
X-Received: by 2002:aa7:d404:: with SMTP id z4mr19948710edq.131.1563139219511;
        Sun, 14 Jul 2019 14:20:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL8eZ/RmUbtqaXRn3WW4g9crdYXGSygeYpX+KOaLLPPfgfYk59Z4Tf7PsnB5AhTR8yIS06
X-Received: by 2002:aa7:d404:: with SMTP id z4mr19948651edq.131.1563139218363;
        Sun, 14 Jul 2019 14:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563139218; cv=none;
        d=google.com; s=arc-20160816;
        b=wbILLgM3NgtPYTR80B2Ckh5+blx8QYhTsgN47/MYcvdq8UbmocxdSNe8x30KpiTYKD
         Ikn9sj4j1lu9rGLc2a+ymHG5OU6PfpER8vE8GXzvGsRqpqfvf4M7RtWblC5uBNuwSnEa
         Oaip7CqXcnTnugH0xDs9nFGky+G0Qk2y1ImjTuyhAf0J405CyKhgXBvh6mrgqCi27S7j
         +973jfAq2qIM+F6zyGVcfqfz8Lxez8gpy4wymIUBJvVRRDY+hym+hz11hznkdMa1L8mj
         JlTtHQvhQ+q6kBaDqUPvu2Ahbr4He3pUR6vOnfrVF+c8M47a7MKs4xZtgFfzqGP9IoI/
         eY1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+F6nQ1DCkOYoAduUWsweXvem5b4lpcHa80JSEL1ErbQ=;
        b=NlKfoqPNE+aXrUThT7foLahY5h7wfa0HrrvMrn7IaMgmTJqFZQeDwkFdNuCM5uoFFt
         fMeQg0QTQcyUTbQPgsjMHV3aP4DKMAtAUx6m5gV2411DWLwcsBe4is+vNiwFTkSJVog6
         CELgLIXzGuqFPMvaLelSnkCF0sE84BK6pyfVTUdJ7tZ/NZciqNLbv8jBi+zuaDG3XwBX
         MJyHDNVjtkgKmj1KtLP557/DypYVJt2FfvXVAi5kcGd4/u4RSumadHBmUJPvUNqHwb/A
         ogu//RTHwpvc1WDlpm0s3hhXOPyNUdgh0OBYrEYPTbuSeDGkmm1R0+iFf3UoGL8S5mG1
         FlCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h44si9470380ede.376.2019.07.14.14.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 14:20:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D23E8AC91;
	Sun, 14 Jul 2019 21:20:17 +0000 (UTC)
Date: Sun, 14 Jul 2019 22:20:15 +0100
From: Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz,
	stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-ID: <20190714212015.GM13484@suse.de>
References: <20190711125838.32565-1-jack@suse.cz>
 <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
 <20190712091746.GB906@quack2.suse.cz>
 <20190712101042.GJ13484@suse.de>
 <20190712112056.GA24009@quack2.suse.cz>
 <20190712123935.GK13484@suse.de>
 <20190712142111.eac6322eea55f7e8f75b7b33@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190712142111.eac6322eea55f7e8f75b7b33@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 02:21:11PM -0700, Andrew Morton wrote:
> On Fri, 12 Jul 2019 13:39:35 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > So although I still think that just failing the migration if we cannot
> > > invalidate buffer heads is a safer choice, just extending the private_lock
> > > protected section does not seem as bad as I was afraid.
> > > 
> > 
> > That does not seem too bad and your revised patch looks functionally
> > fine. I'd leave out the tracepoints though because a perf probe would have
> > got roughly the same data and the tracepoint may be too specific to track
> > another class of problem. Whether the tracepoint survives or not and
> > with a changelog added;
> > 
> > Acked-by: Mel Gorman <mgorman@techsingularity.net>
> > 
> > Andrew, which version do you want to go with, the original version or
> > this one that holds private_lock for slightly longer during migration?
> 
> The revised version looks much more appealing for a -stable backport. 
> I expect any mild performance issues can be address in the usual
> fashion.  My main concern is not to put a large performance regression
> into mainline and stable kernels.  How confident are we that this is
> (will be) sufficiently tested from that point of view?
> 

Fairly confident. If we agree on this patch in principle (build tested
only), I'll make sure it gets tested from a functional point of view
and queue up a few migration-intensive tests while a metadata workload
is running in the background to see what falls out. Furthermore, not all
filesystems even take this path even for migration-intensive situations
so some setups will never notice a difference.

---8<---
From a4f07d789ba5742cd2fe6bcfb635502f2a1de004 Mon Sep 17 00:00:00 2001
From: Jan Kara <jack@suse.cz>
Date: Wed, 10 Jul 2019 11:31:01 +0200
Subject: [PATCH] mm: migrate: Fix race with __find_get_block()

buffer_migrate_page_norefs() can race with bh users in a following way:

CPU1                                    CPU2
buffer_migrate_page_norefs()
  buffer_migrate_lock_buffers()
  checks bh refs
  spin_unlock(&mapping->private_lock)
                                        __find_get_block()
                                          spin_lock(&mapping->private_lock)
                                          grab bh ref
                                          spin_unlock(&mapping->private_lock)
  move page                               do bh work

This can result in various issues like lost updates to buffers (i.e.
metadata corruption) or use after free issues for the old page.

This patch closes the race by holding mapping->private_lock while the
mapping is being moved to a new page. Ordinarily, a reference can be taken
outside of the private_lock using the per-cpu BH LRU but the references
are checked and the LRU invalidated if necessary. The private_lock is held
once the references are known so the buffer lookup slow path will spin
on the private_lock. Between the page lock and private_lock, it should
be impossible for other references to be acquired and updates to happen
during the migration.

[mgorman@techsingularity.net: Changelog, removed tracing]
Fixes: 89cb0888ca14 "mm: migrate: provide buffer_migrate_page_norefs()"
CC: stable@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/migrate.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index e9594bc0d406..a59e4aed6d2e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -771,12 +771,12 @@ static int __buffer_migrate_page(struct address_space *mapping,
 			}
 			bh = bh->b_this_page;
 		} while (bh != head);
-		spin_unlock(&mapping->private_lock);
 		if (busy) {
 			if (invalidated) {
 				rc = -EAGAIN;
 				goto unlock_buffers;
 			}
+			spin_unlock(&mapping->private_lock);
 			invalidate_bh_lrus();
 			invalidated = true;
 			goto recheck_buffers;
@@ -809,6 +809,8 @@ static int __buffer_migrate_page(struct address_space *mapping,
 
 	rc = MIGRATEPAGE_SUCCESS;
 unlock_buffers:
+	if (check_refs)
+		spin_unlock(&mapping->private_lock);
 	bh = head;
 	do {
 		unlock_buffer(bh);

-- 
Mel Gorman
SUSE Labs

