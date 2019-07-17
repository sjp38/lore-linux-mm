Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACBACC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6824421849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6824421849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17C666B0006; Wed, 17 Jul 2019 17:59:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105F46B0007; Wed, 17 Jul 2019 17:59:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3FC98E0001; Wed, 17 Jul 2019 17:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE6556B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:59:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so15385717pgh.11
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=12zTz4j0UgXqTdL/G4s8a0vSnJAZUXcdtZYJkPHMDzQ=;
        b=CAzGuzS/V8j7k78hgeKuIdzTwWLSIg2DuYJirrLStcN0d6tu4vFDlm07zeLLJT58fz
         X/0UkRvv989P+C97DsnLXakeSRt4K2EnNcYPJDomViYQ8AQfSgQeARo1OMttTOP80XpT
         yXIHZa0AmW3MM0E3jI+wqyhwrCdO7q5hTkTeUgOczsNxszSfeZxMoj3yT23lQpbSCaU+
         9og1tEgN64DfBTtBZxF3M0BvarUAzAYtSYpwu4/ybDGpRAmtiNdXlZNTOuzuC6mnxTUy
         AmKk4Ns5j969994h0n1R/O34utVViNZ1GcAjJzUXY+z8vUjJCFuIRT3G7gEQAprZxZI4
         vvag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWXYN98F7VKpvMOzzAzPt7PJOprWHh+b3t1ZyVJX5+iFOI8eVay
	y0Y2IlrlriVi2XnMdxlCE7qAORbcHpAVHL9JJb3V3+LsdCFOia6slDW+mOkDpHuQuPkr9BD/ndn
	rULisMm36xKBTVqkSU5FJUMW8MJLOdmwsVuZHBhqLfp1l+VPaL8y9h2eoNS22nn4q2Q==
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr47622279pje.33.1563400793466;
        Wed, 17 Jul 2019 14:59:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxqDPVApGfdPeca28Sq9jU56wh8bWIjFsxGm8+A3+ObaWQuR8HkrdSz0E4Z+sErhwr9eMR
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr47622228pje.33.1563400792640;
        Wed, 17 Jul 2019 14:59:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400792; cv=none;
        d=google.com; s=arc-20160816;
        b=z+h7WqOjkruJFFp6OYQpXKU1ZWPnGJEeucSTw/3Nfp7SAX3wJ9cvjQxhOiTkuBL6i+
         0laSQvEUGG8srIhQUHjQCH6q93jOFq7Xw9KlSFQ2Nzsd9emH2vQvaGcl5Xj7cF2FuYSY
         KbFWE2fLxkfP7/jmB+oINU8Eiip0YZK0pEpe2D6MSH9r9UgonS7jtj3ihFTwSVM55Vtx
         juxhDzXvpd4ssYocSMBAqSUuVLrHKlyj9SHO6jmZt7KNZAxFBr8tKhejKmP+m2de3TLN
         nrINUIDHj1efk9YAKbCMH0gEdREkK12dNiVohMWrQ17WUZ10PghCTULQXk6AtwvRf0Pq
         5Opw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=12zTz4j0UgXqTdL/G4s8a0vSnJAZUXcdtZYJkPHMDzQ=;
        b=acnvQMCzgA5YnQ46Tk+r/3cOjoOFSs7x4EOUXnA7gWaJL036Sq57KEg/uwZRMx3VZU
         e6PO/D8AGIxULM/PIwecp5BlT0bKtEW25cm9oDFEHW5Nz/Lz7mLZeOOdiM8girwsmOE4
         HB3JyWA83syeMviWF4OHG5CT1tlO7HR7aMfk3YiabM7uiaLkMypoKQO+K5eoW5A/MYMi
         WK7DD67zcYH/PsbAj+LXisvkiqtFnBT9OfhJFoQB5tnrKBJk6vftGRMSXvm+uhn7oeBl
         jv8Y6iJ1mysZWf7y5vUlDeLuspykUzrDB+bBRhCnOniucBXkhk3pjhAX+kBmUb6KpV7Y
         Ewug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id n187si23957761pga.165.2019.07.17.14.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:59:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R881e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TX9KWw9_1563400771;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX9KWw9_1563400771)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 05:59:38 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: hughd@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 0/2] Fix false negative of shmem vma's THP eligibility
Date: Thu, 18 Jul 2019 05:59:16 +0800
Message-Id: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
vma") introduced THPeligible bit for processes' smaps. But, when checking
the eligibility for shmem vma, __transparent_hugepage_enabled() is
called to override the result from shmem_huge_enabled().  It may result
in the anonymous vma's THP flag override shmem's.  For example, running a
simple test which create THP for shmem, but with anonymous THP disabled,
when reading the process's smaps, it may show:

7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
Size:               4096 kB
...
[snip]
...
ShmemPmdMapped:     4096 kB
...
[snip]
...
THPeligible:    0

And, /proc/meminfo does show THP allocated and PMD mapped too:

ShmemHugePages:     4096 kB
ShmemPmdMapped:     4096 kB

This doesn't make too much sense.  The shmem objects should be treated
separately from anonymous THP.  Calling shmem_huge_enabled() with checking
MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
dax vma check since we already checked if the vma is shmem already.

The transhuge_vma_suitable() is needed to check vma, but it was only
available for shmem THP.  The patch 1/2 makes it available for all kind of
THPs and does some code duplication cleanup, so it is made a separate patch.


Changelog:
v4: * Moved transhuge_vma_suitable() to include/linux/huge_mm.h and
      regroup some functions in linux/include/mm.h. Per Hugh Dickins.
    * Added Hugh’s Acked-by to patch 2/2.
v3: * Check if vma is suitable for allocating THP per Hugh Dickins.
    * Fixed smaps output alignment and documentation per Hugh Dickins.
v2: * Check VM_NOHUGEPAGE per Michal Hocko.


Yang Shi (2):
      mm: thp: make transhuge_vma_suitable available for anonymous THP
      mm: thp: fix false negative of shmem vma's THP eligibility

 Documentation/filesystems/proc.txt |  4 ++--
 fs/proc/task_mmu.c                 |  3 ++-
 include/linux/huge_mm.h            | 23 +++++++++++++++++++++++
 include/linux/mm.h                 | 34 +++++++++++++++++-----------------
 mm/huge_memory.c                   | 11 ++++++++---
 mm/memory.c                        | 13 -------------
 mm/shmem.c                         |  3 +++
 7 files changed, 55 insertions(+), 36 deletions(-)

