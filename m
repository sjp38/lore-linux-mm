Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2AF1280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:27:05 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b71so52716509lfg.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 04:27:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l64si1841652wma.21.2016.09.22.04.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 04:27:04 -0700 (PDT)
Subject: Re: [PATCH] mm: avoid endless recursion in dump_page()
References: <20160908082137.131076-1-kirill.shutemov@linux.intel.com>
 <df20f638-0c22-36fd-24b1-3e748419a23c@suse.cz> <20160922105532.GB24593@node>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5a28daab-6502-3e14-9e12-cd2b7ccc6a9d@suse.cz>
Date: Thu, 22 Sep 2016 13:26:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160922105532.GB24593@node>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 09/22/2016 12:55 PM, Kirill A. Shutemov wrote:
> On Wed, Sep 21, 2016 at 04:27:31PM +0200, Vlastimil Babka wrote:
>> On 09/08/2016 10:21 AM, Kirill A. Shutemov wrote:
>> >dump_page() uses page_mapcount() to get mapcount of the page.
>> >page_mapcount() has VM_BUG_ON_PAGE(PageSlab(page)) as mapcount doesn't
>> >make sense for slab pages and the field in struct page used for other
>> >information.
>> >
>> >It leads to recursion if dump_page() called for slub page and DEBUG_VM
>> >is enabled:
>> >
>> >dump_page() -> page_mapcount() -> VM_BUG_ON_PAGE() -> dump_page -> ...
>> >
>> >Let's avoid calling page_mapcount() for slab pages in dump_page().
>>
>> How about instead splitting page_mapcount() so that there is a version
>> without VM_BUG_ON_PAGE()?
>
> Why? page->_mapping is garbage for slab page and might be confusing.
>
> If you want the information from page->_mapping union for slab page to be
> shown during dump_page() we should present in proper way.

Hmm, fair enough.

>
>> >+	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
>
> From d550530cc40ca2e9d60c84a893901c2dad6e7767 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 22 Sep 2016 13:52:40 +0300
> Subject: [PATCH] mm: clarify why we avoid page_mapcount() for slab pages in
>  dump_page()
>
> Let's add comment on why we skip page_mapcount() for sl[aou]b pages.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/debug.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/mm/debug.c b/mm/debug.c
> index 74c7cae4f683..9feb699c5d25 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -42,6 +42,11 @@ const struct trace_print_flags vmaflag_names[] = {
>
>  void __dump_page(struct page *page, const char *reason)
>  {
> +	/*
> +	 * Avoid VM_BUG_ON() in page_mapcount().
> +	 * page->_mapcount space in struct page is used by sl[aou]b pages to
> +	 * encode own info.
> +	 */
>  	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
>
>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
