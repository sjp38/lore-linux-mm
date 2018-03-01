Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B78DE6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 10:27:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u36so4364515wrf.21
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 07:27:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si3055716wrh.30.2018.03.01.07.27.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Mar 2018 07:27:31 -0800 (PST)
Date: Thu, 1 Mar 2018 16:27:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Message-ID: <20180301152729.GM15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz>
 <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu 01-03-18 16:09:35, Daniel Vacek wrote:
[...]
> $ grep 7b7ff000 /proc/iomem
> 7b7ff000-7b7fffff : System RAM
[...]
> After commit b92df1de5d28 machine eventually crashes with:
> 
> BUG at mm/page_alloc.c:1913
> 
> >         VM_BUG_ON(page_zone(start_page) != page_zone(end_page));

This is an important information that should be in the changelog.

> >From registers and stack I digged start_page points to
> ffffe31d01ed8000 (note that this is
> page ffffe31d01edffc0 aligned to pageblock) and I can see this in memory dump:
> 
> crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
> 7b800000 7ffff000 80000000
>       PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
> ffffe31d01e00000  78000000                0        0  0 0
> ffffe31d01ed7fc0  7b5ff000                0        0  0 0
> ffffe31d01ed8000  7b600000                0        0  0 0    <<<< note

Are those ranges covered by the System RAM as well?

> that nodeid and zonenr are encoded in top bits of page flags which are
> not initialized here, hence the crash :-(
> ffffe31d01edff80  7b7fe000                0        0  0 0
> ffffe31d01edffc0  7b7ff000                0        0  1 1fffff00000000
> ffffe31d01ee0000  7b800000                0        0  1 1fffff00000000
> ffffe31d01ffffc0  7ffff000                0        0  1 1fffff00000000

It is still not clear why not to do the alignment in
memblock_next_valid_pfn rahter than its caller.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
