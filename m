Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC701C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:28:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E942070D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:28:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E942070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 413386B0003; Wed, 27 Mar 2019 08:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39AEE6B0006; Wed, 27 Mar 2019 08:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EB886B0007; Wed, 27 Mar 2019 08:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9EAD6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:28:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n24so6586085edd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:28:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=2dScl1E+Z08lwfMUCWfM0UQ8zYdu6l4qKTtzOjsae60=;
        b=t8EhAoVxQVspnx/EDocMZUZpM66/Fdp4sNidxhaiIq+5v7Hj95bSQDVx3odruzMU0o
         mY0b/RLFGZvjjq4Xd4gkJsqI0M9+DacdF7S2p+a/QIGR1n4h4MptYLLYCTBtA+9qCsjy
         JkCyCs10cRWnWZkXakY1l45NTAeSG9lQhbavYC4LKJvmI0jglXTOEY24thFVP07H4i1k
         /ivb++et/XZFPAL1zNA4CeLYMx1S46aT3GKNFWirHhUV7ukS+sh/G993SXF3D0u2/Wja
         j/AJCPddxmLKvlegIZEm+jOhuGww6V2bzKZ60ReTUNtWb4Tk3lNmn7apt0lC6i3a9Q8t
         p2Jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXV1oc1MARFtYLhmRtGH1adK18J1+4u4xIS73yuLYAWnWizhpGx
	sy10z+qWTRmkO8jchIfc8Voc+qLCTaaU8Bg+D7t13Zp/U7LcpcUV3RtNUoJ4yIv13sA7EFHcBFY
	AF/2flidepyJQd9CdU0gaY1HOXWlGf3Ef9jt+Be00De0Aw9jQk0cWQ2tnvxf2Lo61Zg==
X-Received: by 2002:a17:906:4944:: with SMTP id f4mr21146464ejt.82.1553689681277;
        Wed, 27 Mar 2019 05:28:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwChfLTxFFhDUN6zTRD+OSRddBAetZ/n/IyPKGArzc5L2aZa5FK1Jp7fJ3Km91MJrQM3DGV
X-Received: by 2002:a17:906:4944:: with SMTP id f4mr21146413ejt.82.1553689680079;
        Wed, 27 Mar 2019 05:28:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553689680; cv=none;
        d=google.com; s=arc-20160816;
        b=UPTY/nhuxs0LDhDPfxbIJBxBPy39q4KbBQ1RNnxyiO7bfL1eOnwO6NU+XqUZSBHVC0
         eA+QEfvp+JyXj0MB3ObZO3WdqvGLPG74+owtIDhmCNBx/mITSQ/E8cNQ2sEz3wQ+/0Xe
         i4mzMjl1vkZ2HHRGcusHMs38+xyLwKdaSZxkZmKclsz28TUdp300eTis3yU7WsFXtUVY
         uOsF3QTolEDB/nTKyS1d8Xd3HErCA0SvvyJ/RtXZzaoULJT3/5VAlD4MPdOBUcJRB0B1
         UCpdU8dh4fwk/nrFefh5Q8JemtwzYgA4hjdZqr3g+4zCpx5eA1eu9Jkc55FAnnAgk5Dw
         //og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=2dScl1E+Z08lwfMUCWfM0UQ8zYdu6l4qKTtzOjsae60=;
        b=D9uwy6N7gRWK6bBn8GS/PLGWksgijwTZh9u/OZC/1cDGgSrep3tZzrgQZdgraSi6y3
         4PKXEG7wnfjCwIK4wWq0o9K2dMTKEHXy++OYBWm5CY0aqO6cNTN7ELJoG0WIFwfnEE9n
         O4aPSLcDBhSbGE0OYlnFIWv7K7qlMhBj+wKvXPZSsbP8Z2VHkfmpxCr10ZxVOYdGwLng
         3itFOEOAOQ9lg0vKsI3XOyWgOohclpYjhq1ulW78XxBqdEg1yEPHenNrRGNJu1H4iqtm
         PjQDebVeSkW3ZUb39l1QZ6fgTuNJRAUJGxNalZdgHj9aEGSGEIVCu1uWNUquTJI+wVwC
         ce5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j9si4706481ejn.10.2019.03.27.05.27.59
        for <linux-mm@kvack.org>;
        Wed, 27 Mar 2019 05:28:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EA5C6374;
	Wed, 27 Mar 2019 05:27:58 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.146])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 5FD3C3F557;
	Wed, 27 Mar 2019 05:27:56 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	hannes@cmpxchg.org,
	david@redhat.com,
	vbabka@suse.cz,
	mhocko@suse.com,
	willy@infradead.org,
	akpm@linux-foundation.org
Subject: [PATCH] mm/page-flags: Check enforce parameter in PF_ONLY_HEAD()
Date: Wed, 27 Mar 2019 17:57:52 +0530
Message-Id: <1553689672-28343-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just check for enforce parameter in PF_ONLY_HEAD() wrapper before calling
VM_BUG_ON_PGFLAGS() for tail pages.

Fixes: 62906027091f ("mm: add PageWaiters indicating tasks are waiting for a page bit")
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/page-flags.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..82539e287bc6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -229,7 +229,7 @@ static inline void page_init_poison(struct page *page, size_t size)
 #define PF_ANY(page, enforce)	PF_POISONED_CHECK(page)
 #define PF_HEAD(page, enforce)	PF_POISONED_CHECK(compound_head(page))
 #define PF_ONLY_HEAD(page, enforce) ({					\
-		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
+		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
 		PF_POISONED_CHECK(page); })
 #define PF_NO_TAIL(page, enforce) ({					\
 		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
-- 
2.20.1

