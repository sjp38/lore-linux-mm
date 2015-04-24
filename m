Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 29B806B0078
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:51:23 -0400 (EDT)
Received: by wgso17 with SMTP id o17so49628111wgs.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 05:51:22 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id p14si3965676wiv.47.2015.04.24.05.51.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 05:51:21 -0700 (PDT)
Received: by widdi4 with SMTP id di4so20779485wid.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 05:51:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADUS3okX90JX3KfCf8zHvxY12b=QiU25jQBioh8LrEDVF56A-A@mail.gmail.com>
References: <CADUS3okX90JX3KfCf8zHvxY12b=QiU25jQBioh8LrEDVF56A-A@mail.gmail.com>
Date: Fri, 24 Apr 2015 20:51:20 +0800
Message-ID: <CADUS3okBFnTP2EhFHUPo1s_dHNhsP5EEgGygzrfm5xSnSQ9nDA@mail.gmail.com>
Subject: Re: about bootmem allocation/freeing flow
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

2015-04-17 20:20 GMT+08:00 yoma sophian <sophian.yoma@gmail.com>:
> hi all:
> I have several questions about free_all_bootmem_core:
>
> 1.
> In __free_pages_bootmem, we set set_page_count(p, 0) while looping nr_pages,
> why we need to set_page_refcounted(page) before calling __free_pages?
below is excerpted from mm/page_alloc.c  and mm/internal.h
the reason why we use set_page_refcounted(page) is because
set_page_refcounted(page) will calling VM_BUG_ON
to checking page property?

static inline void set_page_refcounted(struct page *page)
{
        VM_BUG_ON(PageTail(page));
        VM_BUG_ON(atomic_read(&page->_count));
        set_page_count(page, 1);
}

void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
{
        unsigned int nr_pages = 1 << order;
        unsigned int loop;

        prefetchw(page);
        for (loop = 0; loop < nr_pages; loop++) {
                struct page *p = &page[loop];

                if (loop + 1 < nr_pages)
                        prefetchw(p + 1);
                __ClearPageReserved(p);
                set_page_count(p, 0);
        }

        page_zone(page)->managed_pages += 1 << order;
        set_page_refcounted(page);
        __free_pages(page, order);
}

appreciate your kind help,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
