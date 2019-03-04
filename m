Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38A55C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02EE920823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02EE920823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34D768E0001; Mon,  4 Mar 2019 03:52:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284EA8E0004; Mon,  4 Mar 2019 03:52:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19FB18E0001; Mon,  4 Mar 2019 03:52:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A38708E0004
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 03:52:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so2346361eda.3
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 00:52:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MSmURSWfisyXP8XnF9b0h4NuzqhZ0djkyBzGLKeiut0=;
        b=qQJc73uHQSdq2gpGfEIwxtukfJqKVTG6t4gjJ0hkulTrsXw1oPn6Q/QJdj4cH6odOO
         7c/HbyHhq+emZvoWoNkjlOayLEJaCQhQ1tUr9eC6ia/ae9hV1LZByZAkigNeMwYGyJBq
         NFl+YqCsrI/rI37E+b26Q/NvlPFqZVzKZwePbMQSZjV05PramLlP1h4NoEwgYGuPBCD3
         BNLVhGhx8Sip4I5FMTAvBXTVX428J6U9bXEW64wNkQSE1IWtjO6pqpNoLYRYBsH5Jdj9
         Svqoi7NRD/2qZO1iyCijERjb2kNIMrA+PAa9cfPLR9D9V4qSkdcUlByX3pUSIYc6x94z
         ucWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVz177w1UwPSIFsI7ZR7Sjc6fkbojmr9GXMzKj2Fh3PvFa20jWy
	lLx+bfa9IZLBym9LBY/NGBGZEH2BplMEWOGhJtr2LrpvrH/PCKpqZxZZ70HiDdjQxo6n5kijZmx
	ENeZ3Zv2HO87DnGJ1o1d4TbL/4jWQcc49d7R42qNMKXtom1oh/vuPR7sXmnxJeguXwg==
X-Received: by 2002:a50:ad31:: with SMTP id y46mr14296378edc.97.1551689533155;
        Mon, 04 Mar 2019 00:52:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqw6cxt+NS8UJiMmABBZuENOaN6PYo4ywNvYa/JAzISGBpMTSf9rvDEnUzEwJWA226H8QKLn
X-Received: by 2002:a50:ad31:: with SMTP id y46mr14296306edc.97.1551689531546;
        Mon, 04 Mar 2019 00:52:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551689531; cv=none;
        d=google.com; s=arc-20160816;
        b=vYShlZX9e8sKi5qByKBujfJyTkXjwpfIHIoZcXvNGMNey0yYkIK3nCy3UhYfb+cgBL
         2pPDl51snAe0wOIdGFVnKaJGR+T2ay34Sha58/4c23aAXMXEy+WTWOkpwGn6cdW5fNh7
         PrKTJlCGLwItZUv01dFChxms5sHLLt/mxbp4kkY1lJx4mPFfbcRxfHaicxXFlTIzovJS
         1iI3f+mCjRHckunpu4UX95C3jiMH7VYGTrtwRqoEICHDALpwQQB1XK2g8FGDiw7B23me
         dWuz8xxOBCvQ8qSdkmr82NLcbHXizcMcsrroJnldVzxLhIuuEkx/bCxb7W9ZpOf0/yIl
         MZvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MSmURSWfisyXP8XnF9b0h4NuzqhZ0djkyBzGLKeiut0=;
        b=fkjFhdhe1o8T48D8Mz+kUs86z8m6Iah24BgV/HC9evU26dxgUbZ0KIWQ9KggxqYhbR
         hee/QlSybd9lWWu8KwbLXN0TV0zGs8+kWFQoYaaZRQn/9EQ73fcFri6rulzNd8U89Cw0
         bT02npL6TDZAEIjcuJYygzr8pQx85wUcvzY8z6kGSIzp4F1Q0lDNLqhhbtGO3prdt3cZ
         UQuJIAE+rT2yE0sXucVru3rzCpJeix+7G3ktzGwCE9zwOWIJocyyAVN4E7GOAMYI0a/H
         kV599F4UQDwL+0wCg3QSDcXoxDfVyOe19+anWlyVOKV0KvxgwpUIcIwOCLZkvr1YWFTz
         34jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id r2si2073866eds.268.2019.03.04.00.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 00:52:11 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 04 Mar 2019 09:52:10 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 04 Mar 2019 08:51:59 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 1/2] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Date: Mon,  4 Mar 2019 09:51:46 +0100
Message-Id: <20190304085147.556-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190304085147.556-1-osalvador@suse.de>
References: <20190304085147.556-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On x86_64, 1GB-hugetlb pages could never be offlined due to the fact
that hugepage_migration_supported() returned false for PUD_SHIFT.
So whenever we wanted to offline a memblock containing a gigantic
hugetlb page, we never got beyond has_unmovable_pages() check.
This changed with [1], where now we also return true for PUD_SHIFT.

After that patch, the check in has_unmovable_pages() and scan_movable_pages()
returned true, but we still had a final barrier in do_migrate_range():

if (compound_order(head) > PFN_SECTION_SHIFT) {
	ret = -EBUSY;
	break;
}

This is not really nice, and we do not really need it.
It is perfectly possible to migrate a gigantic page as long as another node has
a spare gigantic page for us.
In alloc_huge_page_nodemask(), we calculate the __real__ number of free pages,
and if any, we try to dequeue one from another node.

This all works fine when we do have another node with a spare gigantic page,
but if that is not the case, alloc_huge_page_nodemask() ends up calling
alloc_migrate_huge_page() which bails out if the wanted page is gigantic.
That is mainly because finding a 1GB (or even 16GB on powerpc) contiguous
memory is quite unlikely when the system has been running for a while.

In that situation, we will keep looping forever because scan_movable_pages()
will give us the same page and we will fail again because there is no node
where we can dequeue a gigantic page from.
This is not nice, and it has been raised that we might want to treat -ENOMEM
as a fatal error in do_migrate_range(), but this has to be checked further.

Anyway, I would tend say that this is the administrator's job, to make sure
that the system can keep up with the memory to be offlined, so that would mean
that if we want to use gigantic pages, make sure that the other nodes have at
least enough gigantic pages to keep up in case we need to offline memory.

Just for the sake of completeness, this is one of the tests done:

 # echo 1 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
 # echo 1 > /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages

 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
   1
 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
   1

 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages
   1
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   1

 (hugetlb1gb is a program that maps 1GB region using MAP_HUGE_1GB)

 # numactl -m 1 ./hugetlb1gb
 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
   0
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   1

 # offline node1 memory
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   0

[1] https://lore.kernel.org/patchwork/patch/998796/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a9d5787044e1..0f479c710615 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1387,10 +1387,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
-			if (compound_order(head) > PFN_SECTION_SHIFT) {
-				ret = -EBUSY;
-				break;
-			}
 			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
 			isolate_huge_page(head, &source);
 			continue;
-- 
2.13.7

