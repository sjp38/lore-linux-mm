Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 4069E6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 10:00:08 -0500 (EST)
Date: Mon, 5 Dec 2011 16:00:22 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH repost] mm,x86: remove debug_pagealloc_enabled
Message-ID: <20111205150019.GA5434@redhat.com>
References: <1322582711-14571-1-git-send-email-sgruszka@redhat.com>
 <20111205110656.GA22259@elte.hu>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Content-Disposition: inline
In-Reply-To: <20111205110656.GA22259@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 05, 2011 at 12:06:56PM +0100, Ingo Molnar wrote:
> 
> * Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> 
> > When (no)bootmem finish operation, it pass pages to buddy allocator.
> > Since debug_pagealloc_enabled is not set, we will do not protect pages,
> > what is not what we want with CONFIG_DEBUG_PAGEALLOC=y.
> > 
> > To fix remove debug_pagealloc_enabled. That variable was introduced by
> > commit 12d6f21e "x86: do not PSE on CONFIG_DEBUG_PAGEALLOC=y" to get
> > more CPA (change page attribude) code testing. But currently we have
> > CONFIG_CPA_DEBUG, which test CPA.
> > 
> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  arch/x86/mm/pageattr.c |    6 ------
> >  include/linux/mm.h     |   10 ----------
> >  init/main.c            |    5 -----
> >  mm/debug-pagealloc.c   |    3 ---
> >  4 files changed, 0 insertions(+), 24 deletions(-)
> 
> I'm getting this boot crash with the patch applied:

I'm sorry for breaking the boot. I tried to reproduce problem on my
laptop, but failed. I plan to test patch with your config on some other
machines.

On the meantime can you test attached incremental patch and see if it
workaround the crash? I suspect memblock reuse pages that it passed
already to buddy allocator.

Thanks
Stanislaw

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="init_highmem_pages_first.patch"

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 29f7c6d..0d0ddcb 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -760,6 +760,9 @@ void __init mem_init(void)
 #ifdef CONFIG_FLATMEM
 	BUG_ON(!mem_map);
 #endif
+
+	set_highmem_pages_init();
+
 	/* this will put all low memory onto the freelists */
 	totalram_pages += free_all_bootmem();
 
@@ -771,8 +774,6 @@ void __init mem_init(void)
 		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
-	set_highmem_pages_init();
-
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
 	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;

--FCuugMFkClbJLl1L--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
