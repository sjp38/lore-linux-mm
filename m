Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 350356B0069
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:41:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so1305713pgu.17
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:41:13 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h1si6062072pln.150.2017.10.17.04.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Oct 2017 04:41:12 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
In-Reply-To: <20171013120013.698-1-mhocko@kernel.org>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz> <20171013120013.698-1-mhocko@kernel.org>
Date: Tue, 17 Oct 2017 22:41:08 +1100
Message-ID: <871sm2j92j.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko <mhocko@kernel.org> writes:

> From: Michal Hocko <mhocko@suse.com>
>
> Michael has noticed that the memory offline tries to migrate kernel code
> pages when doing
>  echo 0 > /sys/devices/system/memory/memory0/online
>
> The current implementation will fail the operation after several failed
> page migration attempts but we shouldn't even attempt to migrate
> that memory and fail right away because this memory is clearly not
> migrateable. This will become a real problem when we drop the retry loop
> counter resp. timeout.
>
> The real problem is in has_unmovable_pages in fact. We should fail if
> there are any non migrateable pages in the area. In orther to guarantee
> that remove the migrate type checks because MIGRATE_MOVABLE is not
> guaranteed to contain only migrateable pages. It is merely a heuristic.
> Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> allocate any non-migrateable pages from the block but CMA allocations
> themselves are unlikely to migrateable. Therefore remove both checks.
>
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Thanks, that works for me.

Tested-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
