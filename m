Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 842506B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 16:49:36 -0400 (EDT)
Received: by ykp131 with SMTP id 131so4000239ykp.12
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 13:49:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z202si4167071yke.97.2015.03.08.13.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 08 Mar 2015 13:49:35 -0700 (PDT)
Message-ID: <54FCB5D6.1090803@oracle.com>
Date: Sun, 08 Mar 2015 16:49:26 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: hangs in free_pages_prepare
References: <54FB4590.20102@oracle.com> <20150308203838.GA10442@dhcp22.suse.cz>
In-Reply-To: <20150308203838.GA10442@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm >> Andrew Morton" <akpm@linux-foundation.org>

On 03/08/2015 04:38 PM, Michal Hocko wrote:
> On Sat 07-03-15 13:38:08, Sasha Levin wrote:
> [...]
>> [ 1573.730097] ? kasan_free_pages (mm/kasan/kasan.c:301)
>> [ 1573.788680] free_pages_prepare (mm/page_alloc.c:791)
>> [ 1573.788680] ? free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
>> [ 1573.788680] free_hot_cold_page (mm/page_alloc.c:1543)
>> [ 1573.788680] __free_pages (mm/page_alloc.c:2957)
>> [ 1573.788680] ? __vunmap (mm/vmalloc.c:1460 (discriminator 2))
>> [ 1573.788680] __vunmap (mm/vmalloc.c:1460 (discriminator 2))
> 
> __vunmap is doing:
>                 for (i = 0; i < area->nr_pages; i++) {
>                         struct page *page = area->pages[i];
> 
>                         BUG_ON(!page);
>                         __free_page(page);
>                 }
> 
> is it possible that nr_pages is a huge number (a large vmalloc area)? I
> do not see any cond_resched down __free_page path at least. vfree
> delayes the call to workqueue when called from irq context and vunmap is
> marked as might_sleep). So to me it looks like it would be safe. Something
> for vmalloc familiar people, though.
> 
> Anyway, the loop seems to be there since ages so I guess somebody just
> started calling vmalloc for huge areas recently so it shown up.

I might be missing something obvious here, but why does that loop exists at all?

Can't we just call __free_pages() instead?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
