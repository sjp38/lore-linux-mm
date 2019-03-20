Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA11C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B83F2183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B83F2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45EF66B027E; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F71F6B0282; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 287ED6B0281; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C41A86B027E
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:27:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 41so1067560edr.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:27:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=HQ6GKonZweuof86nM4iV/bjnNsB9UeGsbCP9VkdHJvM=;
        b=Ep2zKHkkSnZCrx39Z2b11QfPNZ1yMPj6JXQkThDdkixPXW7mbcHEfLR9MughZ506np
         EArmjbbJlHHacHGALbQhw+fQ3Gzl+5Xo/C88+A6W1ruVzKm7SnxJca926mPblsEfc93o
         eSc68uundKCyWZ1SC/CXVqAVzA6+j8DIW9w0xUfKU7j0lr4VlVlwZKAYJHpF5AI1DIAr
         n6u/Sf12dAUz0L0JMdb50rrehNpcTb/jjrFhaZYOofmNusDdgY0pj067+4Edi4cDWVUC
         ANE1Xh1lIBXGLXitUqQ37hcB9Iohb0DvlJm22qG++5c2ApxFyqDt0Gp7l0VUZq7Wcelk
         +Fgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXtj2Vlm62I7RtKmQMOETYYD5aKcF0e3tTdxmvZhQOLE7sKTOob
	40m8W1oc0/wb+jLQtXKEtDINN+WvxY38s+RFls6NZ68cdLYnBEvvrmdt0zV/HhrTGJQZoxYpVeW
	lYVZr0c/b8Z3/ThdVrxBCu4QcHmsBhIh6XaM+UbAYmCP1om0eT5JI7XfFMdvukU45Iw==
X-Received: by 2002:aa7:d294:: with SMTP id w20mr9492178edq.253.1553095644260;
        Wed, 20 Mar 2019 08:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjig+TvFe8RUBLCcBKKxYHwwIRFa4Bjk3dhyFEdF987A6pHVdKXJ/T7AiIe6IDHjyoq5xw
X-Received: by 2002:aa7:d294:: with SMTP id w20mr9492132edq.253.1553095643241;
        Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095643; cv=none;
        d=google.com; s=arc-20160816;
        b=TbdKDSxD6tPcxzgPLk7JgiuWTKFA/zYAjI6k1sbNdvgTt6G90bH0N0dbBWpNnHDdYZ
         Pz4GCRojGIWuC97Oy2zQz717xHJWwI2q5RENy+hb3YabXj5dAGJSjlOzmj9FGX7jUgTp
         OxuTZafoMeEOigPuCCeIWyap4lJcWD7mS377Vi3Axx2WsGy+Qo+OhwEEpY144cTHXqVg
         uoLkotKGBtqdcMg2yXUKT3OjnR6/YafMx72LXGIWbG+XJzOK/PwvZseSrtpoCNeTO+ak
         YMX3/eKy05anAoRzDoXo9UGbmWXvNhG/D+VQ0W3Y4oOw+yE1fCJtE72lZJehpmdLW/Ux
         eOjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=HQ6GKonZweuof86nM4iV/bjnNsB9UeGsbCP9VkdHJvM=;
        b=sMPjelZmsPyNEO17DQxCwhJjDECmGirq7WaMmRKaLsKhhklK2sWKm6pk9Jl0uYZ1vN
         8Bvbp4OlurLogegOZuyREUT1UrizZnkpC+zExu8ggQQlnQYcs9xx7ZpvqMTEugvg5UQ+
         wRbusH15cTj9Y+bbauZ/lN76exPC8CjPoCbS9wvtqbteUrkmIOCQrmsLVz1oo1lHxR3C
         n2i8CzvDuv+aRhoPBSK/jgMRf/PcE5PYEauWPQDYuJE8JOO1+LeXuvJvWOuL24vwIY52
         pu5pFtUJuz0uxwgdNcMjnANeO+ynJrxASVQL+K8xT2rRGB/dLN95g9eBUm3UnBBLPpVz
         j1SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id w8si898010edx.351.2019.03.20.08.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 20 Mar 2019 16:27:22 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Wed, 20 Mar 2019 15:27:04 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH resend 1/2] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Date: Wed, 20 Mar 2019 16:26:57 +0100
Message-Id: <20190320152658.10855-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190320152658.10855-1-osalvador@suse.de>
References: <20190320152658.10855-1-osalvador@suse.de>
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
index f767582af4f8..02283732544e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1381,10 +1381,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
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

