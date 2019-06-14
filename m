Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2767C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7091021773
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7091021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C1106B000E; Fri, 14 Jun 2019 06:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04AB56B0266; Fri, 14 Jun 2019 06:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2D526B0269; Fri, 14 Jun 2019 06:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE0DB6B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:02:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l185so1577260qkd.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=cAPITdUBXNdAj4ItDddrLE+kS/aOwxGpgqwbqMPrSKY=;
        b=SNvFOnIN5OPpjI8u+tHYfgChr6UIwqVif5Y+9F2c2E/Adrm9GodAvDcWexu2pBPOuM
         ZXM10itiTo8xMD2AU0wjrn/MsapHnyIdngUDwbJsH4bojr5GK/Kd7F98f39W9pq/29+d
         KJNlzXlX5appV/AMfECrR59nK/FQpCMH1PMreci8APgPLL/WQ4EfwpY33Hazx9Xs28/K
         MqOjyUhk8mLbvDjPYJ0SUGg8z58aUdZrIwWx8eh87VQozQHtvge/IiQ/Zhv2X6Kmrs9F
         CL3lWbGnbTaEZpmn3XB4oQs3pZkqGPd9aptL53Bm1dPwvQVinQgffCE8waPahSQxQrs0
         Ui2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUbmuKnxlJH7fg3XDk6ETFv4tRRf8TsffisBAvSK9/iQ1CFy27g
	iG65ikkuei3+5VgwHs6OcGlnUqCRizB0781u2Us2m6Drrx6CNywSIAjkPIjBUlfm8JK96FMx5+3
	4rJ5/nzll3TCtGFuq3ajEIlbnTsuvli0MXsO/6OeiyaZ97bFmKlZ0XR8pdR5BQlFr8g==
X-Received: by 2002:ac8:6958:: with SMTP id n24mr40204643qtr.360.1560506521542;
        Fri, 14 Jun 2019 03:02:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+448lXwjITJpOxgyNF8KQfUGXYyI8PVg53EVkrS6/sRwSw4k9AfssfSUv0HvNY8mjKhSC
X-Received: by 2002:ac8:6958:: with SMTP id n24mr40204574qtr.360.1560506520861;
        Fri, 14 Jun 2019 03:02:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560506520; cv=none;
        d=google.com; s=arc-20160816;
        b=qXCztdIYDGrLjQQ2fyiwim8v9gv50hBBp9FIHfUWdxnccOg9LbgFPNkzuwkq+3RZ9J
         O+1yCvgh8TY6WgCDRl7p0gW1/fdLFCp3v4f2i4uEMpX5VCcL9Tb9LolbOF+e3OP3qcMI
         zftWENFMXryCTu+WjrV0AI9ulyrP145g1acRggFHGPX/LeQUto4EOdcbqfxOMA3TcjMf
         FCFwOw52vNtjJHeFLvy5ISmTPgBywK83Z6513UOuSpT0qWf4HNo5Zs9bAh7s/LBiyqDy
         qRvgllD52VDTjxA/nQS+s1PbIz6xfiv8bEgn4ny2MARI0GGX4oI3pGBds4gS1G0KKMoJ
         AJDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=cAPITdUBXNdAj4ItDddrLE+kS/aOwxGpgqwbqMPrSKY=;
        b=xdzAfXZwWpRcKT9aorlwaLucyKv5e8LmX0MEdQlgDCvXEthAa8OQafl+9Tm0yRPO4I
         H4MzpPJi74UvVeVux1jadkTbgl/v5A9bHmgJalNmqwOe+aPLgyUtlZ3KhCIJDCjZn8fW
         VOZ76L4fknTAheU1N5WU1YvIBaxOX3LAOUbiFFVDJh5B3WgMJxJpSjTQTyRAQxyuAz72
         6HPjYNd9tLoWNCRQs28XI8USFu1XvXTyc3RCWzym7cjdWek9mRCNN3BEK666hZAv+p3E
         o+4dlk7lfcQr6ePCN29lAFtyXXP7GESldnC767DqyyxnqmBuEng8UHgSHS11vzwhhkg0
         d8SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g46si1385501qvd.44.2019.06.14.03.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 03:02:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7B670308FBB4;
	Fri, 14 Jun 2019 10:01:33 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-252.ams2.redhat.com [10.36.116.252])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 22F6D5D9C3;
	Fri, 14 Jun 2019 10:01:14 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Juergen Gross <jgross@suse.com>,
	Keith Busch <keith.busch@intel.com>,
	Len Brown <lenb@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michael Neuling <mikey@neuling.org>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Rashmica Gupta <rashmica.g@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v1 0/6] mm: Further memory block device cleanups
Date: Fri, 14 Jun 2019 12:01:08 +0200
Message-Id: <20190614100114.311-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 14 Jun 2019 10:01:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some further cleanups around memory block devices. Especially, clean up
and simplify walk_memory_range(). Including some other minor cleanups.

Based on: linux-next

Minor conflict with Dan's subsection hot-add series.
Compiled + tested on x86 with DIMMs under QEMU.

David Hildenbrand (6):
  mm: Section numbers use the type "unsigned long"
  drivers/base/memory: Use "unsigned long" for block ids
  mm: Make register_mem_sect_under_node() static
  mm/memory_hotplug: Rename walk_memory_range() and pass start+size
    instead of pfns
  mm/memory_hotplug: Move and simplify walk_memory_blocks()
  drivers/base/memory.c: Get rid of find_memory_block_hinted()

 arch/powerpc/platforms/powernv/memtrace.c | 22 +++---
 drivers/acpi/acpi_memhotplug.c            | 19 ++----
 drivers/base/memory.c                     | 81 +++++++++++++++++------
 drivers/base/node.c                       |  8 ++-
 include/linux/memory.h                    |  5 +-
 include/linux/memory_hotplug.h            |  2 -
 include/linux/mmzone.h                    |  4 +-
 include/linux/node.h                      |  7 --
 mm/memory_hotplug.c                       | 57 +---------------
 mm/sparse.c                               | 12 ++--
 10 files changed, 92 insertions(+), 125 deletions(-)

-- 
2.21.0

