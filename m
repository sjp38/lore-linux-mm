Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E234C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B10921743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B10921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CCCB6B0003; Fri,  9 Aug 2019 08:57:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97E0B6B0005; Fri,  9 Aug 2019 08:57:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86AFB6B0006; Fri,  9 Aug 2019 08:57:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 616916B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:57:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so88848385qte.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:57:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=iCjrBj5hwHR2FKNoOwDFbTFqGlSuJB3B8zikiGf9aMU=;
        b=l+yuvxXgOILrRcfI8x4BKQiPvqinBRS9jGNwyRdqH3Knhd6oi2WhStTNDdm8Fq9eGD
         qtrVWcINSGdztcGibTjPCqt+v2BRk5qleNFEBq03UegCx9TqDCYWsnt/d7TYlqxemeyA
         6aEDTmETZcYAy3g78ef3sXKLi6gI7xoBka4ffNnpeeVfiWodTjB9il5v4Ud7w9gncEM1
         bn8J6OzZUa1u70sY7KvuqVk05qc86Xxh3F6vIPJZ4PbhR5HiFr7BT0XNZJZ2n5oC/KyU
         +tuOvjcCAlVeTEGbyqC3+btD4+Z4oojfF/r469kdJ4CRvUVQxL2xei87oQmVlHLm6W9d
         k8eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVK+iRuPBjNYQv6tde/qQrsXMhRWOBfofY2HP82tAZTjHHHDw+G
	RRWSPOubCoJkIqt9n9dpm090nZBmRRCs27rZHtjkKCXSzEJzVrE5z5P7oOV9Uoj8+N0rmWvtwCc
	jKIXgqHp3nIWCfNAzd3/yT7p3QTtOFdFidBKkBP1aFjLv+Vhh9jPz+Jew81qEKc7paA==
X-Received: by 2002:a37:afc6:: with SMTP id y189mr4383119qke.7.1565355456147;
        Fri, 09 Aug 2019 05:57:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+cIwi37+2Q8F3X27Apyx1mh+7mCf98iep+WC/O1u4LAjEgY1ocCl6HKyw+tFr/CRavOmQ
X-Received: by 2002:a37:afc6:: with SMTP id y189mr4383086qke.7.1565355455601;
        Fri, 09 Aug 2019 05:57:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565355455; cv=none;
        d=google.com; s=arc-20160816;
        b=Twuqd7xbVHbYjnEUJvoDlbDFQQ+DW5lYh6kxzVnylHJo/x5NCJs4ncO8DeHPa7ek4h
         2FsK3gG+OmyHDxWmpgBcqCapTCSnrd0UKFWZcDbPWgzDX/lh/tOlSrc0GL9aZP2/SfKr
         H27Msykt1kyjS5aQ3nCfM8SXesfkQFeZoHRpEBt7bntCKL2FPZ67wk21fOEqayw1qmTm
         g8ESiOpvZKhTeUjfmPqEhTtaXA8zwp5Q8C4rUiI0TpFU7vxIIscwEyV7JJ8qrElc/m9p
         fU47BJM1YyrAwaCZvYgiu2mLZOFgb0JDa6TtRFPr0Vj4uf8LJlDKNa1lBqNxSGkLpcLW
         LD1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=iCjrBj5hwHR2FKNoOwDFbTFqGlSuJB3B8zikiGf9aMU=;
        b=X7cpv4x2TF/l7th+g4zjYLWUNhdunUat7Ht5TueLXtcIhxuT/2mkwtgk1lG+moaps/
         gtpduPYjL8Zk2+wA84mIeb5zvNaDiljqo8uiJiMlXGJLMiijSzW7WEdBzufgyE19x48Y
         SLW7I4GIa8LioIUdf+qHj9XHEZ/7SqGW+VVrGQX1wREIC4ZgBoZ+7w9gDFwELa7Rdr4k
         Nsxivmk8P/QqUdGrNiYcOBKoX18/3/wSRwA0vt9S0TGOlstNfgSa4I/TC/SKEv8eGjmZ
         f461wRfaRk9McHj05WQyoY5smiMKi4C6VGsYd1bUmQiKG3KHmAizkTiyeZR9+XYcrfV3
         71Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si921709qkg.326.2019.08.09.05.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:57:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B3F3530CE671;
	Fri,  9 Aug 2019 12:57:33 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5C4C218396;
	Fri,  9 Aug 2019 12:57:02 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arun KS <arunks@codeaurora.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Borislav Petkov <bp@suse.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Nadav Amit <namit@vmware.com>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v1 0/4] mm/memory_hotplug: online_pages() cleanups
Date: Fri,  9 Aug 2019 14:56:57 +0200
Message-Id: <20190809125701.3316-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 09 Aug 2019 12:57:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some cleanups (+ one fix for a special case) in the context of
online_pages(). Hope I am not missing something obvious. Did a sanity test
with DIMMs only.

David Hildenbrand (4):
  resource: Use PFN_UP / PFN_DOWN in walk_system_ram_range()
  mm/memory_hotplug: Handle unaligned start and nr_pages in
    online_pages_blocks()
  mm/memory_hotplug: Simplify online_pages_range()
  mm/memory_hotplug: online_pages cannot be 0 in online_pages()

 kernel/resource.c   |  4 +--
 mm/memory_hotplug.c | 62 ++++++++++++++++++++-------------------------
 2 files changed, 30 insertions(+), 36 deletions(-)

-- 
2.21.0

