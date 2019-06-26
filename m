Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1D62C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1B602133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1B602133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D7128E0005; Wed, 26 Jun 2019 02:11:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2874F8E0002; Wed, 26 Jun 2019 02:11:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE24A8E0007; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF00E8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v6so3320738ybq.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=iw+LijAGfA/bbxpOZiGUOMEK8HBhFl4MwrlnlnObUp4=;
        b=ISiD9yqQvHlZoZypXO5TQsV4qa/+zhFemuMDnoeshfkdjxCpZkrFf1e54Wt31pnaYW
         JT4O3WnfWbQYK40zDMID25ycnGAFGJu7j6RGpfZqkWv1wJBuEl9VdfThc33fqzDrpJcN
         Mt15UAGTXJEzpg1zLP1ZggBlMh+6rIJbtY8HF+cvCLq5shvdT7uu/uOv9u16n+sD9EPe
         f6EBI18tE39s7k4/ZIpmTb3hP8hER4ZyIIns5QvnyZzRMv1n0tqIdw3LTGHBeQW9NKle
         nmM0pa8Z1GQJyUoM3l4MHpKfPLVo3wkL9tZuitwjfyvzzpptJoidt29jAyxMHqPS+Tk/
         p2nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVj5QMcDBdwzxcgj8mpQdSYjclCczxkOP2BrqmCQRmvSdLKnaFB
	sVC1Bkuby5fbb2bAWFGcI4mXhJftP8PNi9sIaI0wHhUs3lz2JUdVh3f9Ry0smrVhTpGzXV9DYM+
	l0xNoS7xf33/sK8X+iz38dXxSDoxjWNoy6MXUtrNtzQZhJ/7jACdOLRkDVKYf3SRdIg==
X-Received: by 2002:a81:a005:: with SMTP id x5mr1700893ywg.508.1561529507605;
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvb/O6iqQVFS0Qvs1YrBiWuuUc0iKzQuRD4BU11dgmGnc+0G7ZmBIVsaWjvmC+W8TYhS23
X-Received: by 2002:a81:a005:: with SMTP id x5mr1700878ywg.508.1561529507084;
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529507; cv=none;
        d=google.com; s=arc-20160816;
        b=pCgwrAsvQVG0LpiW1TQer0OTD4lEqK4Vs8yTiCm8tujyUqwXWF6L4hhzfZKmG1gJhA
         s4TyFSJWbmRGb11HT7IyoZ/gDZehXaNT8SOBBxAlzavK8vjZ8Z6viVycaKORKdr+SBUe
         CdnfKz2XDXrKNpm6PSvmoREp2OR2om48+ZbMfcgfmGVhSGC7SVT+Lwp5vldwOr/i8pyT
         NTbn2T3KwXTHEaRJ/pFjI9lsLWeo1Fx5c8EimvKWqIUyP6Q5DX1RiYlqc20EPOP2dkhU
         Lw0KUraEGli8OtIyXtN8eC/UJgxinVpZy+lqaMn/gYYXEudrej377Fv+f5ZkgV+hzfF8
         fX9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=iw+LijAGfA/bbxpOZiGUOMEK8HBhFl4MwrlnlnObUp4=;
        b=SB5WjGegF712eqW3Ig1a51gAowjjn7GsXKiEgDDwnOm9kmdv+POuBZjEmNYKDW+81P
         HRQgoOcwCBZbBE6aBP2uQ+t3yOGJSpSBkjCuKXR4WvxrX3cPV/M79xdR4ieyXizYugTL
         mLC3uTwpBcp91fhlTh+mZmt3yXakkiJDFYpMz9BIVCacNNPaXUWIYEbfmfP4wgmKguML
         D18c/2yBj4N/hkVwl7n935gHD14WI2sBb+dSPkRUE8meDQelELrRHfaqcx8iCGEUmLQo
         QjWl8kKDwUhP/IETTklsOgipcE48/Lxn+rpKmuwaj0b++Y/lEOVwwV0DP+5Bd3jZLHVD
         buVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i4si5714395yba.53.2019.06.25.23.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q678rm012970
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:46 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tc13w47h1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:46 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Wed, 26 Jun 2019 07:11:45 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:11:41 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q6BUwO37028112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:11:30 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 304F742041;
	Wed, 26 Jun 2019 06:11:40 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D07E94204B;
	Wed, 26 Jun 2019 06:11:39 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 26 Jun 2019 06:11:39 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id B9ADCA0283;
	Wed, 26 Jun 2019 16:11:38 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
        Qian Cai <cai@lca.pw>, Logan Gunthorpe <logang@deltatee.com>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH v2 2/3] mm: don't hide potentially null memmap pointer in sparse_remove_one_section
Date: Wed, 26 Jun 2019 16:11:22 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190626061124.16013-1-alastair@au1.ibm.com>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19062606-0008-0000-0000-000002F7145B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-0009-0000-0000-0000226447BA
Message-Id: <20190626061124.16013-3-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=623 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
we hide a potentially null memmap from the null check inside
clear_hwpoisoned_pages.

This patch passes the offset to clear_hwpoisoned_pages instead, allowing
memmap to successfully peform it's null check.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/sparse.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 57a1a3d9c1cf..1ec32aef5590 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -753,7 +753,8 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 #ifdef CONFIG_MEMORY_FAILURE
-static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+static void clear_hwpoisoned_pages(struct page *memmap,
+		unsigned long start, unsigned long count)
 {
 	int i;
 
@@ -769,7 +770,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	if (atomic_long_read(&num_poisoned_pages) == 0)
 		return;
 
-	for (i = 0; i < nr_pages; i++) {
+	for (i = start; i < start + count; i++) {
 		if (PageHWPoison(&memmap[i])) {
 			atomic_long_sub(1, &num_poisoned_pages);
 			ClearPageHWPoison(&memmap[i]);
@@ -777,7 +778,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	}
 }
 #else
-static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+static inline void clear_hwpoisoned_pages(struct page *memmap,
+		unsigned long start, unsigned long count)
 {
 }
 #endif
@@ -824,7 +826,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		ms->pageblock_flags = NULL;
 	}
 
-	clear_hwpoisoned_pages(memmap + map_offset,
+	clear_hwpoisoned_pages(memmap, map_offset,
 			PAGES_PER_SECTION - map_offset);
 	free_section_usemap(memmap, usemap, altmap);
 }
-- 
2.21.0

