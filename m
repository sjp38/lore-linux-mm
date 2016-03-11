Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id ECB08828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:36:14 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id n190so137149567iof.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:36:14 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p143si10056140ioe.43.2016.03.11.00.36.13
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 00:36:14 -0800 (PST)
Date: Fri, 11 Mar 2016 17:35:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 02/19] mm/compaction: support non-lru movable page
 migration
Message-ID: <20160311083520.GA27206@bbox>
References: <1457681423-26664-3-git-send-email-minchan@kernel.org>
 <201603111650.Suc95X5j%fengguang.wu@intel.com>
MIME-Version: 1.0
In-Reply-To: <201603111650.Suc95X5j%fengguang.wu@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, dri-devel@lists.freedesktop.org

Hi kbuild,

On Fri, Mar 11, 2016 at 04:11:19PM +0800, kbuild test robot wrote:
> Hi Minchan,
> 
> [auto build test ERROR on v4.5-rc7]
> [cannot apply to next-20160310]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Minchan-Kim/Support-non-lru-page-migration/20160311-153649
> config: x86_64-nfsroot (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from mm/compaction.c:12:0:
> >> include/linux/compaction.h:87:20: error: static declaration of 'isolate_movable_page' follows non-static declaration
>     static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
>                        ^
>    In file included from mm/compaction.c:11:0:
>    include/linux/migrate.h:36:13: note: previous declaration of 'isolate_movable_page' was here
>     extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
>                 ^
>    In file included from mm/compaction.c:12:0:
> >> include/linux/compaction.h:92:20: error: static declaration of 'putback_movable_page' follows non-static declaration
>     static inline void putback_movable_page(struct page *page)
>                        ^
>    In file included from mm/compaction.c:11:0:
>    include/linux/migrate.h:37:13: note: previous declaration of 'putback_movable_page' was here
>     extern void putback_movable_page(struct page *page);
>                 ^
> 
> vim +/isolate_movable_page +87 include/linux/compaction.h
> 
>     81	
>     82	static inline bool compaction_deferred(struct zone *zone, int order)
>     83	{
>     84		return true;
>     85	}
>     86	
>   > 87	static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
>     88	{
>     89		return false;
>     90	}
>     91	
>   > 92	static inline void putback_movable_page(struct page *page)
>     93	{
>     94	}
>     95	#endif /* CONFIG_COMPACTION */
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Actually, I made patchset based on v4.5-rc6 but the problem you found is
still problem in v4.5-rc6, too. Thanks for catching it fast.

I should apply following patch to fix the problem.

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 6f040ad379ce..4cd4ddf64cc7 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -84,14 +84,6 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
-static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
-{
-	return false;
-}
-
-static inline void putback_movable_page(struct page *page)
-{
-}
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
