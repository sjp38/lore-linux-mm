Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 784676B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:44:47 -0400 (EDT)
Received: by widdi4 with SMTP id di4so158339254wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:44:47 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id g14si40860183wjz.39.2015.04.28.15.44.45
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 15:44:46 -0700 (PDT)
Date: Wed, 29 Apr 2015 01:44:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
Message-ID: <20150428224442.GA6188@node.dhcp.inet.fi>
References: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org>
 <20150428222828.GA6072@node.dhcp.inet.fi>
 <20150428153724.cbe99bef1e7c2f073755539a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150428153724.cbe99bef1e7c2f073755539a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

On Tue, Apr 28, 2015 at 03:37:24PM -0700, Andrew Morton wrote:
> On Wed, 29 Apr 2015 01:28:28 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Tue, Apr 28, 2015 at 03:14:20PM -0700, Andrew Morton wrote:
> > > On Mon, 27 Apr 2015 14:26:46 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > > PageTrans* helpers are always-false if THP is disabled compile-time.
> > > > It means the fucntion will fail to detect hugetlb pages in this case.
> > > > 
> > > > Let's use PageCompound() instead. With small tweak to how we calculate
> > > > next low_pfn it will make function ready to see tail pages.
> > > 
> > > <scratches head>
> > > 
> > > So this patch has no runtime effects at present?  It is preparation for
> > > something else?
> > 
> > I wrote this to fix bug I originally attributed to refcounting patchset,
> > but Sasha triggered the same bug on -next without the patchset applied:
> >
> > http://lkml.kernel.org/g/553EB993.7030401@oracle.com
> 
> Well why the heck didn't the changelog tell us this?!?!?

Sasha reported bug in -next after I sent the patch.

> 
> > Now I think it's related to changing of PageLRU() behaviour on tail page
> > by my page flags patchset.
> 
> So this patch is a bugfix against one of
> 
> page-flags-trivial-cleanup-for-pagetrans-helpers.patch
> page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
> page-flags-define-pg_locked-behavior-on-compound-pages.patch
> page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
> page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch

^^^ this one is fault, I think.

> page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
> page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
> page-flags-define-pg_reserved-behavior-on-compound-pages.patch
> page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
> page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
> page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
> page-flags-define-pg_uncached-behavior-on-compound-pages.patch
> page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
> page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
> mm-sanitize-page-mapping-for-tail-pages.patch
> include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch
> 
> Which one was the faulty patch?
> 
> > PageLRU() on tail pages now reports true if
> > head page is on LRU. It means no we can go futher insede
> > isolate_migratepages_block() with tail page.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
