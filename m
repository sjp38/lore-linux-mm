Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 35BA66B005C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:22:41 -0500 (EST)
Received: by qadc16 with SMTP id c16so5193865qad.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:22:40 -0800 (PST)
Date: Wed, 21 Dec 2011 15:22:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
Message-ID: <20111221062232.GE28505@barrios-laptop.redhat.com>
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <op.v6tsxbmb3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.v6tsxbmb3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 21, 2011 at 07:13:49AM +0100, Michal Nazarewicz wrote:
> On Wed, 21 Dec 2011 06:17:59 +0100, Minchan Kim <minchan@kernel.org> wrote:
> >We don't like function body which include #ifdef.
> >If we can, define null function to go out compile time.
> >It's trivial, no functional change.
> 
> It actually adds a??flush_tlb_kenel_range()a?? call to the function so there
> is functional change.

Sorry. I can't understand your point.
Why does it add flush_tlb_kernel_range in case of !CONFIG_DEBUG_PAGEALLOC?

> 
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> > mm/vmalloc.c |    9 +++++++--
> > 1 files changed, 7 insertions(+), 2 deletions(-)
> >
> >diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> >index 0aca3ce..e1fa5a6 100644
> >--- a/mm/vmalloc.c
> >+++ b/mm/vmalloc.c
> >@@ -505,6 +505,7 @@ static void unmap_vmap_area(struct vmap_area *va)
> > 	vunmap_page_range(va->va_start, va->va_end);
> > }
> >+#ifdef CONFIG_DEBUG_PAGEALLOC
> > static void vmap_debug_free_range(unsigned long start, unsigned long end)
> > {
> > 	/*
> >@@ -520,11 +521,15 @@ static void vmap_debug_free_range(unsigned long start, unsigned long end)
> > 	 * debugging doesn't do a broadcast TLB flush so it is a lot
> > 	 * faster).
> > 	 */
> >-#ifdef CONFIG_DEBUG_PAGEALLOC
> > 	vunmap_page_range(start, end);
> > 	flush_tlb_kernel_range(start, end);
> >-#endif
> > }
> >+#else
> >+static inline void vmap_debug_free_range(unsigned long start,
> >+					unsigned long end)
> >+{
> >+}
> >+#endif
> >/*
> >  * lazy_max_pages is the maximum amount of virtual address space we gather up
> 
> -- 
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
> ..o | Computer Science,  MichaA? a??mina86a?? Nazarewicz    (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
