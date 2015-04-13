Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA946B006E
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 08:57:00 -0400 (EDT)
Received: by widdi4 with SMTP id di4so50468985wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 05:57:00 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id s2si13914051wiy.25.2015.04.13.05.56.57
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 05:56:58 -0700 (PDT)
Date: Mon, 13 Apr 2015 15:56:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mlock() on DAX returns -ENOMEM
Message-ID: <20150413125654.GB12354@node.dhcp.inet.fi>
References: <CACTTzNY+u+4rU89o9vXk2HkjdnoRW+H8VcvCdr_H04MUEBCqNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACTTzNY+u+4rU89o9vXk2HkjdnoRW+H8VcvCdr_H04MUEBCqNg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yigal Korman <yigal@plexistor.com>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 12, 2015 at 03:56:33PM +0300, Yigal Korman wrote:
> Hi,
> I've tried to mlock() a range of an ext4-dax file and got "-ENOMEM" in return.

Is it comes from mlock_fixup() or -EFAULT from GUP translated to -ENOMEM
by __mlock_posix_error_return()?

> Looking at the code, it seems that this is related to the fact that
> DAX uses VM_MIXEDMAP and mlock assumes/requires regular page cache.
> To me it seems that DAX should simply return success in mlock() as all
> data is always in memory and no swapping is possible.
> Is this a bug or intentional? Is there a fix planned?

I think it's a bug.

But first we need to define what mlock() means for DAX mappings.

For writable MAP_PRIVATE: we should be able to trigger COW for the range
and mlock resulting pages. It means we should fix kernel to handle
GUP(FOLL_TOUCH | FOLL_POPULATE | FOLL_WRITE | FOLL_FORCE) successfully on
such VMAs.

For MAP_SHARED and non-writable MAP_PRIVATE we should be able to populate
the mapping with PTEs. Not sure if we need to set VM_LOCKED for such VMAs.
We probably should, as we want to re-instantiate PTEs on mremap() and such.
It means we need to get working at least GUP(FOLL_POPULATE | FOLL_FORCE).

In general we need to adjust GUP to avoid going to struct page unless
FOLL_* speficly imply struct page, such as FOLL_GET or FOLL_TOUCH.

Not sure if we need to differentiate DAX mappings from other VM_MIXEDMAP.

Any comments?
 
> Also, the same code path that is used in mlock is also used for
> MAP_POPULATE (pre-fault pages in mmap) so this flag doesn't work as
> well (doesn't fail but simply doesn't pre-fault anything).
> 
> Thanks,
> Yigal
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
