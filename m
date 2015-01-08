Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D12266B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 09:11:07 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so11363093pde.12
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 06:11:07 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 12si8710707pde.142.2015.01.08.06.11.04
        for <linux-mm@kvack.org>;
        Thu, 08 Jan 2015 06:11:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Content-Transfer-Encoding: 7bit
Message-Id: <20150108141004.AB3461A2@black.fi.intel.com>
Date: Thu,  8 Jan 2015 16:10:04 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, linux-mm@kvack.org

Andrew Morton wrote:
> On Mon,  5 Jan 2015 13:46:22 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > The only caller is __free_one_page(). By the time we should have
> > page->flags to be cleared already:
> > 
> >  - for 0-order pages though PCP list:
> > 	free_hot_cold_page()
> > 		free_pages_prepare()
> > 			free_pages_check()
> > 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > 		<put the page to PCP list>
> > 
> > 	free_pcppages_bulk()
> > 		page = <withdraw pages from PCP list>
> > 		__free_one_page(page)
> > 
> >  - for non-0-order pages:
> > 	__free_pages_ok()
> > 		free_pages_prepare()
> > 			free_pages_check()
> > 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > 		free_one_page()
> > 			__free_one_page()
> > 
> > So there's no way PageCompound() will return true in __free_one_page().
> > Let's remove dead destroy_compound_page() and put assert for page->flags
> > there instead.
> 
> Well.  An alternative would be to fix up the call site so those
> useful-looking checks actually get to check things.  Perhaps under
> CONFIG_DEBUG_VM.

Something like this?
