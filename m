Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85023C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DCF42741D
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ew82e7Nz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DCF42741D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11F66B026B; Mon,  3 Jun 2019 12:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9D866B026C; Mon,  3 Jun 2019 12:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3C386B026D; Mon,  3 Jun 2019 12:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A16D6B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:37 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w41so8084999qth.20
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=luHVeQDtsejNe05MbpEHIJ5FAOspLsm1rW4+f3IOXdc=;
        b=enZ4DGD1OQO9omrg+lVYT4v5VgVH/ty/zmg9CtPmtkWMuMB7WKzwzyZdNAimIrGCSf
         h35oZcvwg2Q7cW2SlBeT08yoTjBXBVu3YG3m+3iSPOPbofftTOEE4lX0pH/lPSEHQ0QU
         fKS5s6Cohsvh8ah3khQtPL5nbaZoxn9hUpvip7MeDUzstmV+QIolEM6FhKkIcrXS8aqk
         kyiBUjgidRw5ZJPjXs3ZWiyCgKQFCyQOZ5UxwvCeBQY8e4HlOI460gAQLK84sBzdmtXj
         HM+7bWHW2vvwCMCxIXZCDn6k+rulOleJ3zME+i5Q03Xuak0AbabSottt0y7MEy0vuzdT
         ZyLQ==
X-Gm-Message-State: APjAAAUBIXhRxdE3pCIBLOQBksIBT/tphSAf5Oi9o97mJ4wfwocavEMC
	p08eiLTJttbVsnRzbr5mmzZjUl+eniSIipUfqINjyaa/9M92nl7viJ9WzqUzkstAO5GSBEelHxu
	uBlBHR8w3YbJEtVNHBhgORA+hcWs4YwNaKwYSty4iNvLeL4UrWWdApDNUpXQHAGpCUA==
X-Received: by 2002:a0c:b0c7:: with SMTP id p7mr22229664qvc.246.1559580937201;
        Mon, 03 Jun 2019 09:55:37 -0700 (PDT)
X-Received: by 2002:a0c:b0c7:: with SMTP id p7mr22229627qvc.246.1559580936692;
        Mon, 03 Jun 2019 09:55:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580936; cv=none;
        d=google.com; s=arc-20160816;
        b=TyFv0fBkV7/74EwB1zsKuo61W0yaN9fZu+OrWOgEH0a62uNOTA1LAONP9gm7vqZaM9
         B5qCHvlFcVCRW/rYZjy0PsQQT/YULk4dByVrtcNJ7bCJyef6sQ5K9ntHkWcL+95ZNseW
         5xfcOjyh3Nb2lQEjXABUP3o2aYqw6ENkJwJQSg0PiPG1LSvBpqITdX5pb+yhl3fziYr9
         vvM8YSMJ1ZhM2MvNCPVEnnLy3BdhSJxHMLTrqn6IkvLThZB6JyxbXY1GUzBfGLV70+yV
         DG78f7vOo9U8WN5KbugUsfL3cKWY+WRnmMt76Doc8EP2EvYK6TBBPlRoJdI6gIbgsftR
         YApw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=luHVeQDtsejNe05MbpEHIJ5FAOspLsm1rW4+f3IOXdc=;
        b=p6NSGM1T8/Qa5pCkwkmHvgUVSOtmK0ejNaQNW7guQoUdHjMCgZVz5SJaXUjp6rYmIP
         npvo4X0kLHJI4xL0EylH9eUPRv4od5JjtfPRGbj/qu3Cqq9YCb9lTRIi5NFY+GSDaQl6
         0LxKkH0qwbyGTjf+vD8qkdEujdHTl+zZQAnp2kZvv44w4dTEH9urjZfSl6H4pJhFUjMF
         psC2VelHNIfQ6tezFiEo2KgxvYS6F3KfdwDy//EqtoRa+6g7bnPQ0poqvIl/JLX+W3lY
         n6CcK9sfReNRGokSPWFMSTKT4wNN4j0aq4CL8u9z/IF1dJrG79uO6Hg2HJwlglpl1jeq
         lzfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ew82e7Nz;
       spf=pass (google.com: domain of 3cfh1xaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3CFH1XAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u17sor1680981qvm.7.2019.06.03.09.55.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3cfh1xaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ew82e7Nz;
       spf=pass (google.com: domain of 3cfh1xaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3CFH1XAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=luHVeQDtsejNe05MbpEHIJ5FAOspLsm1rW4+f3IOXdc=;
        b=ew82e7NzIq+8fpVjdyGeAl2NjSKK4p0nGZ5QsTZKvqtsLjuuAXvE063KXb+pD0cHy3
         33+cPut/htgPr27GTzwOcJ20GBX2Ux9NssttTzwHChq9HvO45Yd1WsNH+qMaKhyQDDTc
         D+9zMoo5SrYePAGdOkXZXmMQhF2t0ypsOVpok1EOYB7sNktF/Rh9uldB40uKjOJapI1g
         axLdF69gRV4YSFbj/UQdIsHxS2aGe/kJaiIGVBIH5qRmQS2qsSWYGny0rQfE2+NQmVfF
         bjXTeOgusRer2Jz6pFuYk/PEgndLJQ02z9T1gNTKOM3uuFHRlwHl2aCc1w3EkCHnhf6g
         ZiTA==
X-Google-Smtp-Source: APXvYqxWajnT2+NV3xTud3R56ZNhfS6I5UrUDe55n3y1jJe3OWUToUGKN+BmVqJ0YCPX/M4xXQWJhyPq+bf/72n5
X-Received: by 2002:a0c:ad23:: with SMTP id u32mr3896810qvc.39.1559580936412;
 Mon, 03 Jun 2019 09:55:36 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:06 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 04/16] mm: untag user pointers in do_pages_move
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

do_pages_move() is used in the implementation of the move_pages syscall.

Untag user pointers in this function.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/migrate.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..3930bb6fa656 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (get_user(node, nodes + i))
 			goto out_flush;
 		addr = (unsigned long)p;
+		addr = untagged_addr(addr);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
-- 
2.22.0.rc1.311.g5d7573a151-goog

