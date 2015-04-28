Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3186D6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:37:27 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so8810064pac.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:37:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id zd13si36595407pab.169.2015.04.28.15.37.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:37:26 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:37:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
Message-Id: <20150428153724.cbe99bef1e7c2f073755539a@linux-foundation.org>
In-Reply-To: <20150428222828.GA6072@node.dhcp.inet.fi>
References: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org>
	<20150428222828.GA6072@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

On Wed, 29 Apr 2015 01:28:28 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Apr 28, 2015 at 03:14:20PM -0700, Andrew Morton wrote:
> > On Mon, 27 Apr 2015 14:26:46 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > PageTrans* helpers are always-false if THP is disabled compile-time.
> > > It means the fucntion will fail to detect hugetlb pages in this case.
> > > 
> > > Let's use PageCompound() instead. With small tweak to how we calculate
> > > next low_pfn it will make function ready to see tail pages.
> > 
> > <scratches head>
> > 
> > So this patch has no runtime effects at present?  It is preparation for
> > something else?
> 
> I wrote this to fix bug I originally attributed to refcounting patchset,
> but Sasha triggered the same bug on -next without the patchset applied:
>
> http://lkml.kernel.org/g/553EB993.7030401@oracle.com

Well why the heck didn't the changelog tell us this?!?!?

> Now I think it's related to changing of PageLRU() behaviour on tail page
> by my page flags patchset.

So this patch is a bugfix against one of

page-flags-trivial-cleanup-for-pagetrans-helpers.patch
page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
page-flags-define-pg_locked-behavior-on-compound-pages.patch
page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
page-flags-define-pg_reserved-behavior-on-compound-pages.patch
page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
page-flags-define-pg_uncached-behavior-on-compound-pages.patch
page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
mm-sanitize-page-mapping-for-tail-pages.patch
include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch

Which one was the faulty patch?

> PageLRU() on tail pages now reports true if
> head page is on LRU. It means no we can go futher insede
> isolate_migratepages_block() with tail page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
