Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED8E6C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9433C20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9433C20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6B586B0003; Thu,  4 Apr 2019 08:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1AC16B0005; Thu,  4 Apr 2019 08:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2FB96B0006; Thu,  4 Apr 2019 08:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC826B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 08:59:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so1358243edr.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 05:59:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=NL1yXZonfnF48J81cwG5p6cGLHvNWYsWSJIbu8UcozY=;
        b=YG3hWu7SEtttoZKXPpl8BOJFOeZQpVQu2ufcKCQwRY7a+gZWOUzsrc79RKp1xY+dCC
         ldjiPoWm22C3zd4j83dolCWQhc6ptQUFtII/i1RJFG+YjX8FGTwuDKlW+k7cN0U8a2f2
         iY+EwUAdIRnvqt+5k8NiiT8m3HM5b0NrprsDwz6Z4vrAp3lOTyFbcajsC66pp/8NtpuP
         z+mowoKmzU5qKqqD0hJShQheIL3SGscsmPJ0Au83pG8X73VvVkzr+BssmPKWa+EaQ/vp
         PAnnw5lliX/3ZoNANyKZzQFqxNzHlR0Sjpte7C46+BVUoS/OBtZGJd3W5XM/aMtj7FEg
         yidQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXeOYipepssjBLMBJtwRrkuKXAVxH5dePOfrkajQS3NPc5/xCA6
	7GthfI/QILeWZCBX+Ij9Wn7Y1n+2ZKUGKUfQuBvGlrcC+0p/jQBWqEZ5qrxHFAOggHEbbpQNg1I
	ewFsVCGyI5U3RHKr7AjqC9vQ1p/gB5+hjjrRcm+dsZL6j9ZTZMnq6ILrp7LSfETE5Mw==
X-Received: by 2002:a50:90ee:: with SMTP id d43mr3831864eda.220.1554382779126;
        Thu, 04 Apr 2019 05:59:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUNh2KoFHSFtz2tooF4QCXRLpwv+KKVIXTxNvRbk/ap0xAPi8ZDv+sOGojOTOESJgRLjMa
X-Received: by 2002:a50:90ee:: with SMTP id d43mr3831812eda.220.1554382778158;
        Thu, 04 Apr 2019 05:59:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554382778; cv=none;
        d=google.com; s=arc-20160816;
        b=UHYYTVEiO2uPNNkIS0rLBplRV/oMkY+gc1YIanl7kvj9Yi8/NDJDjkC5hhZ/93QV39
         e1gGZ0JzHOQG3dlNkQHbUuo9mtcjKcfL82zIswi+QhFRYFpbMWfjDBV7Gc6DLRIW1psW
         9NcNGl70CISOxQC8XmiCBz9nqccH9F2/OqGZ79hUPjnmQ1bnKh27I7UVfKcexr1NXeTG
         hrqyS3F0CmBbmV79X3zz1A8XFjRvyNutE4yGV6GuVjPDf1ytXwEb5qTWXZ+nW7UfVQup
         A8M/AgL+SpP+0+XNi5fo3TEZaeZ1S+GscZeV9d3NgUOoLc4/tGxCV7qLhMKCVpYbXf5Y
         F9PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=NL1yXZonfnF48J81cwG5p6cGLHvNWYsWSJIbu8UcozY=;
        b=ijDnRUun/Es4aX/KcKiLqwWnl5YIbYBIyArtWhgUwgOfFkNR++0hT4kKRW89ufzWFD
         DwAE+XQCyqFmMoLia1C3IdocE3Mg+leKIWDcwX7N3v2bUxbh19kUJXQt4Rh5Hk8sc7iI
         Cd6ZgDkEdZr8sqE+QDPO5RBSAYc2iJYcxhGO6w5kJER9vs68OlMBR/6x0TWRUXjQ/t4w
         X1l9YjVQbWPHydmLvPNGHG+09KXEZcaoGjCWpJT5FgZ6AsW7/fNOoWtGKQt+c0ZWk+kv
         6AO67HtdM6ETqhxo1agYCozy0Cymxzn0UX9bP6BwMDRSF7b4QsBTQBMSqLf/woNb14ZM
         fEHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g5si5920476eje.144.2019.04.04.05.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 05:59:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 04 Apr 2019 14:59:37 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 04 Apr 2019 13:59:33 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 0/2] Preparing memhotplug for allocating memmap from hot-added range
Date: Thu,  4 Apr 2019 14:59:14 +0200
Message-Id: <20190404125916.10215-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

these patches were posted as part of patchset [1], but it was agreed that
patch#3 must be further discussed.
Whole discussion can be seen in the cover letter.

But the first two patches make sense by themselves, as the first one is a nice
code cleanup, and the second one sets up the interface that the feature implemented
in [1] will use.

We decided to go this way because there are other people working on the same area,
and conflicts can arise easily, so better merge it now.
Also, it is safe as they do not implement any functional changes.

[1] https://patchwork.kernel.org/cover/10875017/

Michal Hocko (2):
  mm, memory_hotplug: cleanup memory offline path
  mm, memory_hotplug: provide a more generic restrictions for memory
    hotplug

 arch/arm64/mm/mmu.c            |  6 ++---
 arch/ia64/mm/init.c            |  6 ++---
 arch/powerpc/mm/mem.c          |  6 ++---
 arch/s390/mm/init.c            |  6 ++---
 arch/sh/mm/init.c              |  6 ++---
 arch/x86/mm/init_32.c          |  6 ++---
 arch/x86/mm/init_64.c          | 10 ++++----
 include/linux/memory_hotplug.h | 32 ++++++++++++++++++------
 kernel/memremap.c              | 10 +++++---
 mm/memory_hotplug.c            | 56 ++++++++++++++----------------------------
 mm/page_alloc.c                | 11 +++++++--
 11 files changed, 82 insertions(+), 73 deletions(-)

-- 
2.13.7

