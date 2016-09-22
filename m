Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEE46B026C
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:55:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so67987349wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:55:36 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id r134si36311707wmd.40.2016.09.22.03.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 03:55:35 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id b184so13349677wma.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:55:35 -0700 (PDT)
Date: Thu, 22 Sep 2016 13:55:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: avoid endless recursion in dump_page()
Message-ID: <20160922105532.GB24593@node>
References: <20160908082137.131076-1-kirill.shutemov@linux.intel.com>
 <df20f638-0c22-36fd-24b1-3e748419a23c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df20f638-0c22-36fd-24b1-3e748419a23c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Sep 21, 2016 at 04:27:31PM +0200, Vlastimil Babka wrote:
> On 09/08/2016 10:21 AM, Kirill A. Shutemov wrote:
> >dump_page() uses page_mapcount() to get mapcount of the page.
> >page_mapcount() has VM_BUG_ON_PAGE(PageSlab(page)) as mapcount doesn't
> >make sense for slab pages and the field in struct page used for other
> >information.
> >
> >It leads to recursion if dump_page() called for slub page and DEBUG_VM
> >is enabled:
> >
> >dump_page() -> page_mapcount() -> VM_BUG_ON_PAGE() -> dump_page -> ...
> >
> >Let's avoid calling page_mapcount() for slab pages in dump_page().
> 
> How about instead splitting page_mapcount() so that there is a version
> without VM_BUG_ON_PAGE()?

Why? page->_mapping is garbage for slab page and might be confusing.

If you want the information from page->_mapping union for slab page to be
shown during dump_page() we should present in proper way.

> 
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> > mm/debug.c | 6 ++++--
> > 1 file changed, 4 insertions(+), 2 deletions(-)
> >
> >diff --git a/mm/debug.c b/mm/debug.c
> >index 8865bfb41b0b..74c7cae4f683 100644
> >--- a/mm/debug.c
> >+++ b/mm/debug.c
> >@@ -42,9 +42,11 @@ const struct trace_print_flags vmaflag_names[] = {
> >
> > void __dump_page(struct page *page, const char *reason)
> > {
> 
> At least there should be a comment explaining why.

Fair enough.

> >+	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
