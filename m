Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF5182963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:58:02 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l66so92687758wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:58:02 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id 201si15982266wml.102.2016.02.03.14.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:58:01 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm/debug-pagealloc: add missing debug_pagealloc_enabled
Date: Wed, 03 Feb 2016 23:51:17 +0100
Message-ID: <1715666.B0erB7v9pc@wuerfel>
In-Reply-To: <56B27F71.2000700@redhat.com>
References: <1454537757-3760706-1-git-send-email-arnd@arndb.de> <56B27F71.2000700@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Wednesday 03 February 2016 14:30:09 Laura Abbott wrote:
> On 02/03/2016 02:15 PM, Arnd Bergmann wrote:
> > The change to move the pagealloc logic broke the slab allocator
> > check when it's disabled at compile time:
> >
> > mm/slab.c: In function 'is_debug_pagealloc_cache':
> > mm/slab.c:1608:29: error: implicit declaration of function 'debug_pagealloc_enabled' [-Werror=implicit-function-declaration]
> >
> > This adds an inline helper to get it to work again.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: 0a244aea1a61 ("mm/slab: clean up DEBUG_PAGEALLOC processing code")
> > ---
> >   include/linux/mm.h | 1 +
> >   1 file changed, 1 insertion(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 5d86eb2e8584..90d600ce56ad 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2242,6 +2242,7 @@ kernel_map_pages(struct page *page, int numpages, int enable)
> >   extern bool kernel_page_present(struct page *page);
> >   #endif /* CONFIG_HIBERNATION */
> >   #else
> > +static inline bool debug_pagealloc_enabled(void) { return 0; }
> >   static inline void
> >   kernel_map_pages(struct page *page, int numpages, int enable) {}
> >   #ifdef CONFIG_HIBERNATION
> >
> 
> I believe this should be fixed with http://article.gmane.org/gmane.linux.kernel.mm/145655

Yes, Christian's version looks nicer too (correct return type).

Thanks,

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
