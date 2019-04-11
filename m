Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58A99C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:10:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21839218AE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:10:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21839218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B77A96B0007; Thu, 11 Apr 2019 07:10:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B263D6B000E; Thu, 11 Apr 2019 07:10:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A16E86B026D; Thu, 11 Apr 2019 07:10:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE726B0007
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:10:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c67so4744041qkg.5
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:10:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=I/kmvnWPqGwhEx/wx0Tfdw8YtCd3PF0otIwlvdQzFyU=;
        b=JgbiaCLGhp7uWSZvhnsowMTOGI1LnmVpNOr97Qzjww5o+O/rO1VRqlxTfUWakZ1rTa
         McRzKOM/rZVo34x9zMMJ1N+ZVYA7TH9Vs9oXcoihBo0NB+NjOYeHB2/Ks1mlM1eVEYA9
         wqbOGkvXZXMwPG+NzKA1GkoB1kGuXpt7e05gXRyXu+X2EMUGUUjZudSH5JOwhMrWMZkG
         S+xzD7Noez6aPpajH6MpGdYWptlwxrPQt/1ZpPXmdbJsRu81bMyCCfqXAsawKBxCjCqF
         6JM37/WRylJfwkT4KG6jdQmaVbJBnVMLIXXgI9BLGmanHTmzdgU8p30/UoZKIq+8yK74
         TXQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXDFuvjqi7uMNNldvI/zen9K70DgiTj726MiYBxC8VqJadYmOKw
	ThSOEnOOOJnG2kOXh3DpGkPVvky6B3LNi8OzAYwzpn46XkVEdHgz/ZOKtW36SehlfPQVrBmNNV5
	YCtY+OfUm/JeH9s8OEMVlBr4Av9yQNWpyWrVxuFUspsts7jLfb+LJk0dWYEzcudd7Ow==
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr36664795qkb.164.1554981003310;
        Thu, 11 Apr 2019 04:10:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVgk2JZ2qjMRCUz276yag/EQtuLhA4SzWv+ZlYq6dSdhhcinqkxt8FDmiZP57SgFHyXoXy
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr36664733qkb.164.1554981002383;
        Thu, 11 Apr 2019 04:10:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554981002; cv=none;
        d=google.com; s=arc-20160816;
        b=M92kv7ipi8xvu3fYf21XJ+UKtc4d7iEJSYeF6NA7UNzAsYVQqBhBbNeYOFtj+SM+Dv
         DD/U5T1hL0+dWTovXveR9EeViASMPduxoPik2hyyN+Gaye2fgoyXIpDIqbEH2RE0YCF7
         0F2TQvf2W3t/heHGJO0NxHjykZtreecFvhdzGparcUHcml6AC+1Rj5ECE3xbhVHVHnJ8
         ugdReQJoyPyaCHX/6nuhwg/FMxqzZhd4219xVZlOTmVk42hXM5ChjqSYG0i8G6G1CJsu
         MkGYXTUA6p64sJ16T3KbRsN221A35GmdiBmfvmS9tKQq4xIZTIv8CRj9IBZnHoFoNrqR
         BxzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=I/kmvnWPqGwhEx/wx0Tfdw8YtCd3PF0otIwlvdQzFyU=;
        b=QD0rs8XCXyRBrFHYi3TR9j6/3RUF8fjNborIqKCLPJ3gxYLFfsphzaT61oqmaIpqJc
         dkOSZoBO4G/FNuL9pCllejFYP1Ge92PrF+Fo+aJFTPisYyRLcBuVxqjimbOW5HLMeZOt
         e8yb2fahFwXmdzFfOTjGVHkj/SS06zXS8c3ftnA7m34HnsqzD8sAfrFKMwsDRhYDQbuG
         /TpNjmUlkraUVBPc3PcntDnXWbV9i1H6uW0k9F48lvDP4q9HVun6oZg8vrZYOE1CXaO0
         yYy5WipAbV32Ca/MxMK6JQxj51kVuQmC7tyB19z3h6ScTTmXfmlIwgoTbvAt0rF3tCqr
         pDqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y14si1603470qvc.188.2019.04.11.04.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:10:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D472D77F2;
	Thu, 11 Apr 2019 11:10:01 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.43])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B657660BF7;
	Thu, 11 Apr 2019 11:09:56 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v2] mm/memory_hotplug: Drop memory device reference after find_memory_block()
Date: Thu, 11 Apr 2019 13:09:55 +0200
Message-Id: <20190411110955.1430-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 11 Apr 2019 11:10:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Right now we are using find_memory_block() to get the node id for the
pfn range to online. We are missing to drop a reference to the memory
block device. While the device still gets unregistered via
device_unregister(), resulting in no user visible problem, the device is
never released via device_release(), resulting in a memory leak. Fix
that by properly using a put_device().

Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5eb4a4c7c21b..328878b6799d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	mem = find_memory_block(__pfn_to_section(pfn));
 	nid = mem->nid;
+	put_device(&mem->dev);
 
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
-- 
2.20.1

