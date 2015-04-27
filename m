Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 106E76B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:12:15 -0400 (EDT)
Received: by wgin8 with SMTP id n8so107095514wgi.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 01:12:14 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id em10si32003820wjd.79.2015.04.27.01.12.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 01:12:13 -0700 (PDT)
Received: by wiun10 with SMTP id n10so80436748wiu.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 01:12:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87tww2ejit.fsf@tassilo.jf.intel.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
 <1429909549-11726-3-git-send-email-anisse@astier.eu> <87tww2ejit.fsf@tassilo.jf.intel.com>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 27 Apr 2015 10:11:52 +0200
Message-ID: <CALUN=qL6X=RXyTmxezFDzif+3PZCykpB0mT9hkbgAab4vV59sg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Andi,

Thinks for taking the time to review this.

On Sun, Apr 26, 2015 at 10:12 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Anisse Astier <anisse@astier.eu> writes:
>> +       If unsure, say N.
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 05fcec9..c71440a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -803,6 +803,11 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>>               debug_check_no_obj_freed(page_address(page),
>>                                          PAGE_SIZE << order);
>>       }
>> +
>> +#ifdef CONFIG_SANITIZE_FREED_PAGES
>> +     zero_pages(page, order);
>> +#endif
>
> And not removing the clear on __GFP_ZERO by remembering that?
>
> That means all clears would be done twice.
>
> That patch is far too simple. Clearing is commonly the most
> expensive kernel operation.
>

I thought about this, but if you unconditionally remove the clear on
__GFP_ZERO, you wouldn't be guaranteed to have a zeroed page when
memory is first used (you would protect the kernel from its own info
leaks though); you'd need to clear memory on boot for example.

If you try to remember that a page it's cleared, it means using a page
flag, which is was previously deemed too precious for this kind of
operation.

Regarding the expensive operation, I don't think this is an option
you'd enable on your systems if you care about performance.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
