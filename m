Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEF06B006C
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:14:30 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id u14so8029016lbd.2
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:14:29 -0800 (PST)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id h2si8233620lbv.95.2015.01.26.07.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 07:14:28 -0800 (PST)
Received: by mail-la0-f49.google.com with SMTP id gf13so8097660lab.8
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:14:27 -0800 (PST)
Date: Mon, 26 Jan 2015 18:14:26 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] proc/pagemap: walk page tables under pte lock
Message-ID: <20150126151426.GU7377@moon>
References: <20150126145214.11053.5670.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126145214.11053.5670.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Stable <stable@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Feiner <pfeiner@google.com>

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
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
