Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B1B166B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:41:29 -0500 (EST)
Received: by igcph11 with SMTP id ph11so99174111igc.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:41:29 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id t12si1155678igd.27.2015.12.01.15.41.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Dec 2015 15:41:29 -0800 (PST)
Date: Wed, 2 Dec 2015 08:41:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:3272!
Message-ID: <20151201234148.GA20632@bbox>
References: <565C5F2D.5060003@oracle.com>
 <20151201212636.GA137439@black.fi.intel.com>
MIME-Version: 1.0
In-Reply-To: <20151201212636.GA137439@black.fi.intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 01, 2015 at 11:26:36PM +0200, Kirill A. Shutemov wrote:
> On Mon, Nov 30, 2015 at 09:37:33AM -0500, Sasha Levin wrote:
> > Hi Kirill,
> > 
> > I've hit the following while fuzzing with trinity on the latest -next kernel:
> > 
> > [  321.348184] page:ffffea0011a20080 count:1 mapcount:1 mapping:ffff8802d745f601 index:0x1802
> > [  321.350607] flags: 0x320035c00040078(uptodate|dirty|lru|active|swapbacked)
> > [  321.453706] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> > [  321.455353] page->mem_cgroup:ffff880286620000
> 
> I think this should help:
> 
> From aadc911f047b094c68b350550556dafabf05af13 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 20 Nov 2015 12:20:00 +0200
> Subject: [PATCH] thp: fix split_huge_page vs. deferred_split_scan race
> 
> Minchan[1] and Sasha[2] had reported crash in split_huge_page_to_list()
> called from deferred_split_scan() due VM_BUG_ON_PAGE(!PageLocked(page)).
> 
> This can happen because race between deferred_split_scan() and
> split_huge_page(). The result of the race is that the page can be split
> under deferred_split_scan().
> 
> The patch prevents this by taking split_queue_lock in
> split_huge_page_to_list() when we check if the page can be split.
> If the page is suitable for splitting, we remove page from splitting
> queue under the same lock, before splitting starts.
> 
> [1] http://lkml.kernel.org/g/20151117073539.GB32578@bbox
> [2] http://lkml.kernel.org/g/565C5F2D.5060003@oracle.com
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Minchan Kim <minchan@kernel.org>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>

With this, I cannot reprocude the error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
