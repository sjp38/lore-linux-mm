Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E119C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:02:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31EF22173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:02:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31EF22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF7B66B000A; Thu, 18 Jul 2019 05:02:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C82946B000C; Thu, 18 Jul 2019 05:02:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B23538E0001; Thu, 18 Jul 2019 05:02:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6769D6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:02:42 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u17so6767938wmd.6
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:02:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=6uHJDM5Ju/M1+aK6ffeXmCjcxFXpjJCWhN4nR1jMUbg=;
        b=IVb3CRqCYAEcKiW7siNA+0CN5T30PX8O3MElvVQTV6BQJggPPUBuREUIr09ogOehD2
         w9XgQUJ2XQjUOi1M/2iOZEhSgSTYSTGHA8JGrk30xyYPo4YJ2q1pzBNDuKYartkckgsS
         ob42rSPaLI0BoBxZpA7u6JB7RfQXNMU2lX8/cAeG9ScsRNRCgmzQefIYjxZ9lMYwzo2f
         H6GcHHD/SM2UR8+lnCcUbkZ+Xr/txKOb+cqULX9E06SvIXoVQ26+je7VrFQaov08kZPL
         iqQI5kfi9k6u9tBgmEQONF2E0lXg68xaC9nx7vu5ZA31IOdARl2uD6l4HlidY2+A5XLg
         0GCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWRpLa66h7dSjR0o7ZLIh4Rk7MtzOCWACVX9b8cPgDyuuMZregq
	/ipO8XZnLSOqAj472t1yZTFa+HRJzo+VrgVzsNsKQolO+SBhS16jFlb4sbrT1cdrtTAF47rTHTa
	Uqa7RUxew1gnrq6eHcJVw9ewgwxxPGlXnL2CmFcqGgHxCDnOZYwmd45a9eKI7lvC9ig==
X-Received: by 2002:a05:600c:da:: with SMTP id u26mr40006731wmm.108.1563440561953;
        Thu, 18 Jul 2019 02:02:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPwaR2wHl0HMUDd7bPJuptDXAFmzhQ0DxrcOg7vt2MwrnmSwxndZ4CKKMLt7dDyvp6WSz7
X-Received: by 2002:a05:600c:da:: with SMTP id u26mr40006628wmm.108.1563440561026;
        Thu, 18 Jul 2019 02:02:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563440561; cv=none;
        d=google.com; s=arc-20160816;
        b=Cmi4UwJGYk1Y5IQQR39AnLBC7HrY/GGmwU1BfJ2idHZl4EilYUvtPVHdWWw4+zNF/8
         Tt2Pu9r5U98svzhrE8FjgQq7nRvR5CdN1wIZmKmI1Sdq0QarU/JGA9+ETtL9at1DXxDG
         TXOUh0ZS86Ru9zCxzkpzLMl87VFeO0r4GAJRXXybHdHYeWBZMSGisasvehq4TDYrkaO+
         ny7xVMTNh8FR7JzfyuryTm9EcGpZbpATHxhGpT0+e73cPGJPsPDwiy6RxCiuG2pV5szt
         IJKrMu2C7KtZNgQTDfZvFUqqT45G+Q1ieGGXgdKpBIo5tqBqn7+akses/zwClWBfyag+
         G2TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=6uHJDM5Ju/M1+aK6ffeXmCjcxFXpjJCWhN4nR1jMUbg=;
        b=KDUJjAHKHhxhOcGltq/WSeliNGogDg5jGIW2daj8SdTTO5Vde4+VDfW9QmXrU4AqLP
         nMJc/TCsBTFAnAvqGpaFF9fhujn5D2r5D45Mgcik/sSp8mus7cKPFUcO531EdM8fCzEI
         bh8e4evPQk4peaH7Ib7/UNWIENvGmhjvv2limZSoT8OA7qI3XqXd5aDfi4P6/vq314wQ
         U5fn71BazQ8OkY+Rj8AevQISnAjJ2WIr6v3JhSfOfIZA0nPRxfS5YhlAZytEIjXVpLUs
         bskUSK7u6RrbXjluDTrlTClBD+rh/y1SrlDAcbqU59HroBO1eD5/TnuCDFVyzH4hnOub
         bDPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id c6si26798078wre.296.2019.07.18.02.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 02:02:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) client-ip=81.17.249.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id B9207989D8
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:02:40 +0100 (IST)
Received: (qmail 4427 invoked from network); 18 Jul 2019 09:02:40 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Jul 2019 09:02:40 -0000
Date: Thu, 18 Jul 2019 10:02:38 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: [PATCH] mm: migrate: Fix reference check race between
 __find_get_block() and migration
Message-ID: <20190718090238.GF24383@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

buffer_migrate_page_norefs() can race with bh users in the following way:

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

A user had reported data corruption issues on a distribution kernel with
a similar page migration implementation as mainline. The data corruption
could not be reproduced with this patch applied. A small number of
migration-intensive tests were run and no performance problems were noted.

[mgorman@techsingularity.net: Changelog, removed tracing]
Fixes: 89cb0888ca14 "mm: migrate: provide buffer_migrate_page_norefs()"
CC: stable@vger.kernel.org # v5.0+
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

