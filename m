Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4A096B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:50:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g32so6953513wrd.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:50:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si8973504wrj.342.2017.07.26.03.50.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 03:50:07 -0700 (PDT)
Date: Wed, 26 Jul 2017 12:50:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: gigantic hugepages vs. movable zones
Message-ID: <20170726105004.GI2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I've just noticed that alloc_gigantic_page ignores movability of the
gigantic page and it uses any existing zone. Considering that
hugepage_migration_supported only supports 2MB and pgd level hugepages
then 1GB pages are not migratable and as such allocating them from a
movable zone will break the basic expectation of this zone. Standard
hugetlb allocations try to avoid that by using htlb_alloc_mask and I
believe we should do the same for gigantic pages as well.

I suspect this behavior is not intentional. What do you think about the
following untested patch?
---
