Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 871CF6B005C
	for <linux-mm@kvack.org>; Thu, 28 May 2009 05:11:42 -0400 (EDT)
Date: Thu, 28 May 2009 17:11:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [4/16] HWPOISON: Add support for poison swap entries v2
Message-ID: <20090528091127.GA13856@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201230.19B1C1D0286@basil.firstfloor.org> <4A1E4F80.9090404@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1E4F80.9090404@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 04:46:56PM +0800, Hidehiro Kawai wrote:
> Andi Kleen wrote:
> 
> > CPU migration uses special swap entry types to trigger special actions on page
> > faults. Extend this mechanism to also support poisoned swap entries, to trigger
> > poison handling on page faults. This allows followon patches to prevent 
> > processes from faulting in poisoned pages again.
> > 
> > v2: Fix overflow in MAX_SWAPFILES (Fengguang Wu)
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > ---
> >  include/linux/swap.h    |   34 ++++++++++++++++++++++++++++------
> >  include/linux/swapops.h |   38 ++++++++++++++++++++++++++++++++++++++
> >  mm/swapfile.c           |    4 ++--
> >  3 files changed, 68 insertions(+), 8 deletions(-)
> > 
> > Index: linux/include/linux/swap.h
> > ===================================================================
> > --- linux.orig/include/linux/swap.h	2009-05-27 21:13:54.000000000 +0200
> > +++ linux/include/linux/swap.h	2009-05-27 21:14:21.000000000 +0200
> > @@ -34,16 +34,38 @@
> >   * the type/offset into the pte as 5/27 as well.
> >   */
> >  #define MAX_SWAPFILES_SHIFT	5
> > -#ifndef CONFIG_MIGRATION
> > -#define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
> > +
> > +/*
> > + * Use some of the swap files numbers for other purposes. This
> > + * is a convenient way to hook into the VM to trigger special
> > + * actions on faults.
> > + */
> > +
> > +/*
> > + * NUMA node memory migration support
> > + */
> > +#ifdef CONFIG_MIGRATION
> > +#define SWP_MIGRATION_NUM 2
> > +#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
> > +#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 2)
> >  #else
> > -/* Use last two entries for page migration swap entries */
> > -#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-2)
> > -#define SWP_MIGRATION_READ	MAX_SWAPFILES
> > -#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + 1)
> > +#define SWP_MIGRATION_NUM 0
> >  #endif
> >  
> >  /*
> > + * Handling of hardware poisoned pages with memory corruption.
> > + */
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +#define SWP_HWPOISON_NUM 1
> > +#define SWP_HWPOISON		(MAX_SWAPFILES + 1)
> > +#else
> > +#define SWP_HWPOISON_NUM 0
> > +#endif
> > +
> > +#define MAX_SWAPFILES \
> > +	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM - 1)
> 
> I don't prefer this fix against the overflow issue.
> For example, if both CONFIG_MIGRATION and CONFIG_MEMORY_FAILURE are
> undefined, MAX_SWAPFILES is defined as 31.  But we should be able to
> use up to 32 swap files/devices!
> 
> So instead, we should do:
> 
> #define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM)
> #define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
> 
> #define SWP_HWPOISON		MAX_SWAPFILES
> 
> #define MAX_SWAPFILES \
> 	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> 
> and:
> 
> static inline int non_swap_entry(swp_entry_t entry)
> {
> 	return swp_type(entry) >= MAX_SWAPFILES;
> }

Yes this is a better way to fix the overflow problem: when
SWP_HWPOISON=32 and it is shifted by SWP_TYPE_SHIFT and then shift
back, we get 0 (overflowed).

Andi, this patch does what Hidehiro describes.

---
 include/linux/swap.h    |    8 ++++----
 include/linux/swapops.h |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

--- linux.orig/include/linux/swap.h
+++ linux/include/linux/swap.h
@@ -46,8 +46,8 @@ static inline int current_is_kswapd(void
  */
 #ifdef CONFIG_MIGRATION
 #define SWP_MIGRATION_NUM 2
-#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
-#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 2)
+#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM)
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
 #else
 #define SWP_MIGRATION_NUM 0
 #endif
@@ -57,13 +57,13 @@ static inline int current_is_kswapd(void
  */
 #ifdef CONFIG_MEMORY_FAILURE
 #define SWP_HWPOISON_NUM 1
-#define SWP_HWPOISON 		(MAX_SWAPFILES + 1)
+#define SWP_HWPOISON 		MAX_SWAPFILES
 #else
 #define SWP_HWPOISON_NUM 0
 #endif
 
 #define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM - 1)
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
--- linux.orig/include/linux/swapops.h
+++ linux/include/linux/swapops.h
@@ -161,7 +161,7 @@ static inline int is_hwpoison_entry(swp_
 #if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
 static inline int non_swap_entry(swp_entry_t entry)
 {
-	return swp_type(entry) > MAX_SWAPFILES;
+	return swp_type(entry) >= MAX_SWAPFILES;
 }
 #else
 static inline int non_swap_entry(swp_entry_t entry)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
