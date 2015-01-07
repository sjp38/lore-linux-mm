Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD3A6B006C
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 16:40:42 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so6234304iec.1
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 13:40:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q63si2416560ioe.54.2015.01.07.13.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 13:40:41 -0800 (PST)
Date: Wed, 7 Jan 2015 13:40:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Message-Id: <20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
In-Reply-To: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org

On Mon,  5 Jan 2015 13:46:22 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> The only caller is __free_one_page(). By the time we should have
> page->flags to be cleared already:
> 
>  - for 0-order pages though PCP list:
> 	free_hot_cold_page()
> 		free_pages_prepare()
> 			free_pages_check()
> 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> 		<put the page to PCP list>
> 
> 	free_pcppages_bulk()
> 		page = <withdraw pages from PCP list>
> 		__free_one_page(page)
> 
>  - for non-0-order pages:
> 	__free_pages_ok()
> 		free_pages_prepare()
> 			free_pages_check()
> 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> 		free_one_page()
> 			__free_one_page()
> 
> So there's no way PageCompound() will return true in __free_one_page().
> Let's remove dead destroy_compound_page() and put assert for page->flags
> there instead.

Well.  An alternative would be to fix up the call site so those
useful-looking checks actually get to check things.  Perhaps under
CONFIG_DEBUG_VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
