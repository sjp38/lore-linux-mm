Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 95E496B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 14:07:41 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so1417891qcq.17
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 11:07:41 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id f4si8298225qas.88.2014.08.14.11.07.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 11:07:41 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id lf12so1807461vcb.26
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 11:07:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140814151329.GA22187@optiplex.redhat.com>
References: <53E6CEAA.9020105@oracle.com>
	<CAPAsAGxcC0+V1ZzR3LL=ASx=KXifPbw_cyvHCBBJT4mZ1grg+Q@mail.gmail.com>
	<20140813153501.GE21041@optiplex.redhat.com>
	<20140814151329.GA22187@optiplex.redhat.com>
Date: Thu, 14 Aug 2014 22:07:40 +0400
Message-ID: <CAPAsAGwk7kF6XtJNz6Y41zn0SHHzEt1Nwi_wC0gWgt0fpdp-ZQ@mail.gmail.com>
Subject: Re: mm: compaction: buffer overflow in isolate_migratepages_range
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <a.ryabinin@samsung.com>

2014-08-14 19:13 GMT+04:00 Rafael Aquini <aquini@redhat.com>:
>> Yeah, it happens because I failed to anticipate a race window opening where
>> balloon_page_movable() can stumble across an anon page being released --
>> somewhere in the midway of __page_cache_release() & free_pages_prepare()
>> down on the put_page() codepath -- while isolate_migratepages_range() performs
>> its loop in the (lru) unlocked case.
>>
>
> Giving it a second thought, I see my first analisys (above) isn't accurate,
> as if we had raced against a page being released at the point I mentioned,
> balloon_page_movable() would have bailed out while performing its
> page_flags_cleared() checkpoint.
>
> But I now can see from where this occurrence is coming from, actually.
>
> The real race window for this issue opens when balloon_page_movable()
> checkpoint @ isolate_migratepages_range() stumbles across a (new)
> page under migration at:
>
> static int move_to_new_page(struct page *newpage, struct page *page, ...
> {
>    ...
>    newpage->mapping = page->mapping;
>
>
> At this point, *newpage points to a fresh page coming out from the allocator
> (just as any other possible ballooned page), but it gets its ->mapping
> pointer set, which can create the conditions to the access (for mapping flag
> checking purposes only) KASAN is complaining about, if *page happens to
> be pointing to an anon page.
>
>
>> Although harmless, IMO, as we only go for the isolation step if we hold the
>> lru lock (and the check is re-done under lock safety) this is an
>> annoying thing we have to get rid of to not defeat the purpose of having
>> the kasan in place.
>>
>
> It still a harmless condition as before, but considering what goes above
> I'm now convinced & confident the patch proposed by Andrey is the real fix
> for such occurrences.
>

I don't think that it's harmless, because we could cross page boundary here and
try to read from a memory hole.
And this code has more potential problems like use after free. Since
we don't hold locks properly here,
page->mapping could point to freed struct address_space.

We discussed this with Konstantin and he suggested a better solution for this.
If I understood him correctly the main idea was to store bit
identifying ballon page
in struct page (special value in _mapcount), so we won't need to check
mapping->flags.


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
