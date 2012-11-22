Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 866CE6B0078
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 10:10:53 -0500 (EST)
Date: Thu, 22 Nov 2012 13:10:29 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v12 4/7] mm: introduce compaction and migration for
 ballooned pages
Message-ID: <20121122151028.GA1834@t510.redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
 <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
 <50A7D0FA.2080709@gmail.com>
 <20121117215434.GA23879@x61.redhat.com>
 <CA+1xoqfbxL-mL3XRDXxnuv0R6b9w6qxU7t+8U3FwS2eK5Sf0OA@mail.gmail.com>
 <20121120141438.GA21672@x61.redhat.com>
 <50AC2BCC.6050507@gmail.com>
 <20121122000114.GB1815@t510.redhat.com>
 <50AE3463.1040107@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AE3463.1040107@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>

On Thu, Nov 22, 2012 at 09:19:15AM -0500, Sasha Levin wrote:
> And managed to reproduce it only once through last night, here is the dump I got
> before the oops:
> 
> [ 2760.356820] page:ffffea0000d00e00 count:1 mapcount:-2147287036 mapping:00000000000004f4 index:0xd00e00000003
> [ 2760.362354] page flags: 0x350000000001800(private|private_2)
> 

Thanks alot for following up this one Sasha.


We're stumbling across a private page -- seems something in your setup is doing
this particular usage, and that's probably why I'm not seeing the same here.

Regardless being a particular case or not, we shouldn't be poking at that
private page, so I figured the tests I'm doing at balloon_page_movable() are
incomplete and dumb.

Perhaps, a better way to proceed here would be assuring the NR_PAGEFLAGS
rightmost bits from page->flags are all cleared, as this is the state a page
coming from buddy to the balloon list will be, and this is the state the balloon
page flags will be kept as long as it lives as such (we don't play with any flag
at balloon level).


Here goes what I'll propose after you confirm it doesn't trigger your crash
anymore, as it simplifies the code and reduces the testing battery @
balloon_page_movable() -- ballooned pages have no flags set, 1 refcount and 0
mapcount, always.


Could you give this a try?

Thank you!

---
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compacti
index e339dd9..44ad50f 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -101,6 +101,12 @@ static inline bool __is_movable_balloon_page(struct page *p
        return mapping_balloon(mapping);
 }
 
+#define PAGE_FLAGS_MASK       ((1UL << NR_PAGEFLAGS) - 1)
+static inline bool __balloon_page_flags(struct page *page)
+{
+       return page->flags & PAGE_FLAGS_MASK ? false : true;
+}
+
 /*
  * balloon_page_movable - test page->mapping->flags to identify balloon pages
  *                       that can be moved by compaction/migration.
@@ -121,8 +127,8 @@ static inline bool balloon_page_movable(struct page *page)
         * Before dereferencing and testing mapping->flags, lets make sure
         * this is not a page that uses ->mapping in a different way
         */
-       if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
-           !page_mapped(page))
+       if (__balloon_page_flags(page) && !page_mapped(page) &&
+           page_count(page) == 1)
                return __is_movable_balloon_page(page);
 
        return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
