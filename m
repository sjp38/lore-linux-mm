Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 748696B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 09:43:41 -0400 (EDT)
Received: by widdi4 with SMTP id di4so47217102wid.0
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 06:43:40 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id hx8si24544502wjb.100.2015.04.25.06.43.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Apr 2015 06:43:39 -0700 (PDT)
Received: by widdi4 with SMTP id di4so51775643wid.0
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 06:43:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1504241434040.2456@chino.kir.corp.google.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
 <1429909549-11726-2-git-send-email-anisse@astier.eu> <alpine.DEB.2.10.1504241434040.2456@chino.kir.corp.google.com>
From: Anisse Astier <anisse@astier.eu>
Date: Sat, 25 Apr 2015 15:43:18 +0200
Message-ID: <CALUN=qJheGR9ahrikS5Mith25gz6KmTML-NDB=cfpQmsotN0Lw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/page_alloc.c: cleanup obsolete KM_USER*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi David,

First of all, thanks a lot for your time reviewing this series.

On Fri, Apr 24, 2015 at 11:36 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 24 Apr 2015, Anisse Astier wrote:
>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ebffa0e..05fcec9 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -380,16 +380,10 @@ void prep_compound_page(struct page *page, unsigned long order)
>>       }
>>  }
>>
>> -static inline void prep_zero_page(struct page *page, unsigned int order,
>> -                                                     gfp_t gfp_flags)
>> +static inline void zero_pages(struct page *page, unsigned int order)
>>  {
>>       int i;
>>
>> -     /*
>> -      * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
>> -      * and __GFP_HIGHMEM from hard or soft interrupt context.
>> -      */
>> -     VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
>>       for (i = 0; i < (1 << order); i++)
>>               clear_highpage(page + i);
>>  }
>> @@ -975,7 +969,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>       kasan_alloc_pages(page, order);
>>
>>       if (gfp_flags & __GFP_ZERO)
>> -             prep_zero_page(page, order, gfp_flags);
>> +             zero_pages(page, order);
>>
>>       if (order && (gfp_flags & __GFP_COMP))
>>               prep_compound_page(page, order);
>
> No objection to removing the VM_BUG_ON() here, but I'm not sure that we
> need an inline function to do this and to add additional callers in your
> next patch.  Why can't we just remove the helper entirely and do the
> iteration in prep_new_page()?  We iterate pages all the time.

I just felt it was easier to read as a whole; unless anyone else
objects, I think I'll keep it as-is in the next iteration.

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
