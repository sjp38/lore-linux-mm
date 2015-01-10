Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AB7A96B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 20:15:49 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so10886276wgh.3
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 17:15:49 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id em16si22384051wjd.106.2015.01.09.17.15.48
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 17:15:48 -0800 (PST)
Date: Sat, 10 Jan 2015 03:15:46 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Message-ID: <20150110011546.GA32685@node.dhcp.inet.fi>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
 <20150108141004.AB3461A2@black.fi.intel.com>
 <20150109162419.b52796aee45d6747399d2ebb@linux-foundation.org>
 <20150110004143.GA32424@node.dhcp.inet.fi>
 <20150109170642.14a01c7e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150109170642.14a01c7e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, linux-mm@kvack.org

On Fri, Jan 09, 2015 at 05:06:42PM -0800, Andrew Morton wrote:
> On Sat, 10 Jan 2015 02:41:43 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Fri, Jan 09, 2015 at 04:24:19PM -0800, Andrew Morton wrote:
> > > On Thu,  8 Jan 2015 16:10:04 +0200 (EET) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > > Something like this?
> > > > 
> > > > >From 5fd481c1c521112e9cea407f5a2644c9f93d0e14 Mon Sep 17 00:00:00 2001
> > > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > > Date: Thu, 8 Jan 2015 15:59:23 +0200
> > > > Subject: [PATCH] mm: more checks on free_pages_prepare() for tail pages
> > > > 
> > > > Apart form being dead, destroy_compound_page() did some potentially
> > > > useful checks. Let's re-introduce them in free_pages_prepare(), where
> > > > they can be acctually triggered.
> > > > 
> > > > compound_order() assert is already in free_pages_prepare(). We have few
> > > > checks for tail pages left.
> > > > 
> > > 
> > > I'm thinking we avoid the overhead unless CONFIG_DEBUG_VM?
> > 
> > That's why there's "if (!IS_ENABLED(CONFIG_DEBUG_VM))". Is it wrong in
> > some way?
> > I didn't check, but I assume compiler is smart enough to get rid of
> > free_tail_pages_check() if CONFIG_DEBUG_VM is not defined. No?
> 
> doh, OK.  I updated the
> mm-more-checks-on-free_pages_prepare-for-tail-pages.patch changelog to
> reflect this and did
> 
> --- a/mm/page_alloc.c~mm-more-checks-on-free_pages_prepare-for-tail-pages-fix
> +++ a/mm/page_alloc.c
> @@ -764,19 +764,18 @@ static void free_one_page(struct zone *z
>  	spin_unlock(&zone->lock);
>  }
>  
> -static int free_tail_pages_check(struct page *head_page, struct page *page)
> +static void free_tail_pages_check(struct page *head_page, struct page *page)
>  {
>  	if (!IS_ENABLED(CONFIG_DEBUG_VM))
> -		return 0;
> +		return;
>  	if (unlikely(!PageTail(page))) {
>  		bad_page(page, "PageTail not set", 0);
> -		return 1;
> +		return;
>  	}
>  	if (unlikely(page->first_page != head_page)) {
>  		bad_page(page, "first_page not consistent", 0);
> -		return 1;
> +		return;
>  	}
> -	return 0;
>  }
>  
>  static bool free_pages_prepare(struct page *page, unsigned int order)
> _

Oops. I wanted this return code to be accounted into 'bad' in
free_pages_prepare() instead. Incremental patch:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cf327e2eea6f..ee37d1e0c969 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -798,7 +798,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
        bad += free_pages_check(page);
        for (i = 1; i < (1 << order); i++) {
                if (compound)
-                       free_tail_pages_check(page, page + i);
+                       bad += free_tail_pages_check(page, page + i);
                bad += free_pages_check(page + i);
        }
        if (bad)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
