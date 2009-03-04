Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 886CE6B00AE
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:17:30 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so3341703tia.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 06:17:27 -0800 (PST)
Date: Wed, 4 Mar 2009 23:17:23 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] generic debug pagealloc
Message-ID: <20090304141721.GC7168@localhost.localdomain>
References: <20090303160103.GB5812@localhost.localdomain> <20090303133610.cb771fef.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20090303133610.cb771fef.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 01:36:10PM -0800, Andrew Morton wrote:
> Alternatively, we could just not do the kmap_atomic() at all.  i386
> won't be using this code and IIRC the only other highmem architecture
> is powerpc32, and ppc32 appears to also have its own DEBUG_PAGEALLOC
> implementation.  So you could remove the kmap_atomic() stuff and put
> 
> #ifdef CONFIG_HIGHMEM
> #error i goofed
> #endif
> 
> in there.

I'll take the variant of this. Then poison_page() will be

static void poison_page(struct page *page)
{
        void *addr;

        if (PageHighmem(page))
                return; // i goofed

       page->poison = true;
       addr = page_address(page);
       memset(addr, PAGE_POISON, PAGE_SIZE);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
