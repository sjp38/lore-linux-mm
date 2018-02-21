Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2841F6B000C
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:16:28 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so945968plo.11
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:16:28 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z188si3176668pfz.46.2018.02.21.08.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 08:16:27 -0800 (PST)
Subject: Re: Use higher-order pages in vmalloc
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz>
 <20180221154214.GA4167@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fff58819-d39d-3a8a-f314-690bcb2f95d7@intel.com>
Date: Wed, 21 Feb 2018 08:16:22 -0800
MIME-Version: 1.0
In-Reply-To: <20180221154214.GA4167@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 02/21/2018 07:42 AM, Matthew Wilcox wrote:
> On Tue, Jan 23, 2018 at 01:55:32PM +0300, Konstantin Khlebnikov wrote:
>> Virtually mapped stack have two bonuses: it eats order-0 pages and
>> adds guard page at the end. But it slightly slower if system have
>> plenty free high-order pages.
>>
>> This patch adds option to use virtually bapped stack as fallback for
>> atomic allocation of traditional high-order page.
> This prompted me to write a patch I've been meaning to do for a while,
> allocating large pages if they're available to satisfy vmalloc.  I thought
> it would save on touching multiple struct pages, but it turns out that
> the checking code we currently have in the free_pages path requires you
> to have initialised all of the tail pages (maybe we can make that code
> conditional ...)

What the concept here?  If we can use high-order pages for vmalloc() at
the moment, we *should* use them?

One of the coolest things about vmalloc() is that it can do large
allocations without consuming large (high-order) pages, so it has very
few side-effects compared to doing a bunch of order-0 allocations.  This
patch seems to propose removing that cool thing.  Even trying the
high-order allocation could kick off a bunch of reclaim and compaction
that was not there previously.

If you could take this an only _opportunistically_ allocate large pages,
it could be a more universal win.  You could try to make sure that no
compaction or reclaim is done for the large allocation.  Or, maybe you
only try it if there are *only* high-order pages in the allocator that
would have been broken down into order-0 *anyway*.

I'm not sure it's worth it, though.  I don't see a lot of folks
complaining about vmalloc()'s speed or TLB impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
