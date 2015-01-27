Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 610FD6B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 20:34:53 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so12231049wev.8
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 17:34:52 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id gh5si64638wib.102.2015.01.26.17.34.51
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 17:34:51 -0800 (PST)
Date: Tue, 27 Jan 2015 03:34:41 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] proc/pagemap: walk page tables under pte lock
Message-ID: <20150127013441.GB3007@node.dhcp.inet.fi>
References: <20150126145214.11053.5670.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126145214.11053.5670.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Stable <stable@vger.kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Feiner <pfeiner@google.com>

On Mon, Jan 26, 2015 at 05:52:14PM +0300, Konstantin Khlebnikov wrote:
> Lockless access to pte in pagemap_pte_range() might race with page migration
> and trigger BUG_ON(!PageLocked()) in migration_entry_to_page():
> 
> CPU A (pagemap)                           CPU B (migration)
>                                           lock_page()
>                                           try_to_unmap(page, TTU_MIGRATION...)
>                                                make_migration_entry()
>                                                set_pte_at()
> <read *pte>
> pte_to_pagemap_entry()
>                                           remove_migration_ptes()
>                                           unlock_page()
>     if(is_migration_entry())
>         migration_entry_to_page()
>             BUG_ON(!PageLocked(page))
> 
> Also lockless read might be non-atomic if pte is larger than wordsize.
> Other pte walkers (smaps, numa_maps, clear_refs) already lock ptes.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Reported-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Fixes: 052fb0d635df ("proc: report file/anon bit in /proc/pid/pagemap")
> Cc: Stable <stable@vger.kernel.org> (v3.5+)

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
