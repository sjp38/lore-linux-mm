Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A3CFC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 05:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D54AF2084E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 05:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D54AF2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3863B6B0005; Fri, 21 Jun 2019 01:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3375E8E0002; Fri, 21 Jun 2019 01:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2257E8E0001; Fri, 21 Jun 2019 01:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC1F56B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 01:57:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e25so2549195pfn.5
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 22:57:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=xcDUJE370Hy4y1yxEhDnfE8BcE5Irq6bIwf9v89i0jk=;
        b=EuDWJd1EYXh7FKz0EhXKgGoV2bof7srZuOB1asDMt5y3s5BjW94f4+0LnaQgpGzynf
         02szXX1HGMZjDy2ZAfg6b7BF8ky8ca71fMIksWxsIpHVFIrpNXjjkHlh+cbe5y6hdMTn
         tSj2VEYjqsYN/3Yjh3JHoUWeg7Da3wTUm4jrSwjtkCZa1Sv0UFFpeApy8UD/N7YVVl4d
         UWC8B8ZfRl4o/VP0W9Jb60+/XlYaVY4peJ9DLkni9qJBk3i4QR+b+TkjMm+/QdEueN8l
         fsWvESEnwyvWWZNZ1TArAcDPtDIWB7XVuuEver96rAvby6O1XdfuWcmVPLTlY501TBsa
         50+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUSjrudBDi7qKQmIlxnjP3quFpJwjOefWgJDYX8iZ7FvZWMwE+X
	pMsYcJR02cNDthoF9sgDohEL+NIKgBvibclxD/nw42tX5sMSkgjp6Z+fV+Bj4kHE0l03xLS3ATp
	aNA6reGSCd1SZeVSQ5ByqRxMazgFM1ekTBLaoBsrD9BT52LLdzJy0jp7I63Qz0JHU7w==
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr4192325pjn.119.1561096676583;
        Thu, 20 Jun 2019 22:57:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwppuZTs+Kd6Kr3j9d692Z4QGMQwaXjqYNv8IuFmhaLIZVLhcLRYZ267UZz0rjph50dQwXv
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr4192260pjn.119.1561096675819;
        Thu, 20 Jun 2019 22:57:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561096675; cv=none;
        d=google.com; s=arc-20160816;
        b=LxxXPb2nLwJp5qI5eg7lpn15lesAMlDyfz2IXVsfpuadiCwuLkBJTw9BrpcKwgHMdC
         SLfa/9E3TPWIWvgP4Nt+Sm56b7wKKPrNHXE7fEdIPEQfffDYGYG/7zrrUAAdyJu7IHNq
         TLyVMJmFc5wnsQwcnZTpQlZmgO1Gzy9B1cqCIHhy7jAVJum7WtWgfXYgswS9nLWM+j/u
         gyxy/8HKrUgeGKSVr9RJckg+AC5as+7AOycIf/knhmq+8RX+yOM+62sHqbb8znwg/K0M
         qGFxUSekjm4xdZrCOqMGYk37LPj4Ng4HJ+hfn+wnKvSesnfNNz3a/InGICUtoZRuXDXu
         S+dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=xcDUJE370Hy4y1yxEhDnfE8BcE5Irq6bIwf9v89i0jk=;
        b=kuuZ0ViUvKX4u0UI3lBnbqwgtERkAdnGM06gE2QnCa3KL6dZyuLv1jBka4w4EVpqpW
         rBvcDgdrpIroBbMUVGowlq4SkS8wixf/Hr1uWx6o2jOCk4vv29MRpabfZ/tMdRSuR8VP
         LgnCAWU29MSkV4KmocnrdRXSEAE/Eu/q0Ove47ztRVPC4hHxpiQluS/3qHD0ZkOImm65
         Fe+SYXfuGvmj5lI/tbZUsLvtaUCsjSCP3SxvAkqjA4R1CmJ0i1G4qgbpDFXUdlEMXQOq
         JVgbqw1yMjc8Xh/Y3YK8xwuiPX0+vj8jbTSDN8W4Jvy3SLOzFy41cAMHOp35cLiPgOaM
         hnoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f69si1928632pjg.43.2019.06.20.22.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 22:57:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 22:57:54 -0700
X-IronPort-AV: E=Sophos;i="5.63,399,1557212400"; 
   d="scan'208";a="187060039"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga002-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 22:57:54 -0700
Subject: [-mm PATCH] docs/vm: Update ZONE_DEVICE memory model documentation
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Thu, 20 Jun 2019 22:43:37 -0700
Message-ID: <156109575458.1409767.1885676287099277666.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike notes that Sphinx needs a newline before the start of a bulleted
list, and v10 of the subsection patch set changed the subsection size
from an arch-variable 'PMD_SIZE' to a constant 2MB.

Cc: Jonathan Corbet <corbet@lwn.net>
Reported-by: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Hi Andrew,

Another small fixup to fold on top of the subsection series. Thanks to
Mike for the build test, I also caught that the doc was out of date.

 Documentation/vm/memory-model.rst |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
index e0af47e02e78..58a12376b7df 100644
--- a/Documentation/vm/memory-model.rst
+++ b/Documentation/vm/memory-model.rst
@@ -205,10 +205,11 @@ subject to its memory ranges being exposed through the sysfs memory
 hotplug api on memory block boundaries. The implementation relies on
 this lack of user-api constraint to allow sub-section sized memory
 ranges to be specified to :c:func:`arch_add_memory`, the top-half of
-memory hotplug. Sub-section support allows for `PMD_SIZE` as the minimum
-alignment granularity for :c:func:`devm_memremap_pages`.
+memory hotplug. Sub-section support allows for 2MB as the cross-arch
+common alignment granularity for :c:func:`devm_memremap_pages`.
 
 The users of `ZONE_DEVICE` are:
+
 * pmem: Map platform persistent memory to be used as a direct-I/O target
   via DAX mappings.
 

