Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 56EFB82F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 16:52:52 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so17271858wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 13:52:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl14si43519250wjb.118.2015.10.19.13.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Oct 2015 13:52:51 -0700 (PDT)
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils> <5624E31A.9010202@suse.cz>
 <alpine.LSU.2.11.1510191204020.4652@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5625581F.10206@suse.cz>
Date: Mon, 19 Oct 2015 22:52:47 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510191204020.4652@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On 10/19/2015 09:17 PM, Hugh Dickins wrote:
>> Now if CPU0 is the last mapper, it will unmap the page anyway
>> further in exit_mmap(). If not, it stays mlocked.
>>
>> The key problem is that page lock doesn't cover the TestClearPageMlocked(page)
>> part on CPU0.
>
> Thank you for expanding: your diagram beats my words.  Yes, I now agree
> with you again - but reserve the right the change my mind an infinite
> number of times as we look into this for longer.

Good :)

> You can see why mm/mlock.c is not my favourite source file, and every
> improvement to it seems to make it worse.

Thank you for not explicitly pointing out the authorship of the current 
pagevec-based munlock_vma_pages_range. In the unknown author's defense, 
it was my first series.

> It doesn't help that most of
> the functions named "munlock" are about trying to set the mlocked bit.

That's hopefully a much older issue. And I may add that it doesn't help 
that although we do atomic TestAndSet/Clear operations, it still subtly 
relies on other locks for correctness.

> And while it's there on our screens, let me note that "page_mapcount > 1"
> "improvement" of mine is, I believe, less valid in the current multistage
> procedure than when I first added it (though perhaps a look back would
> prove me just as wrong back then).  But it errs on the safe side (never
> marking something unevictable when it's evictable) since PageMlocked has
> already been cleared, so I think that it's still an optimization well
> worth making for the common case.

Sure.

>> Your patch should help AFAICS. If CPU1 does the mlock under pte lock, the
>> TestClear... on CPU0 can happen only after that.
>> If CPU0 takes pte lock first, then CPU1 must see the VM_LOCKED flag cleared,
>> right?
>
> Right - thanks a lot for giving it more thought.
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
