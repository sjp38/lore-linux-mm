Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 99E8F6B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 06:27:42 -0400 (EDT)
Received: by laat2 with SMTP id t2so4182386laa.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:27:42 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id db1si19060621wib.84.2015.04.14.03.27.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 03:27:40 -0700 (PDT)
Received: by wizk4 with SMTP id k4so107263619wiz.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:27:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150413125654.GB12354@node.dhcp.inet.fi>
References: <CACTTzNY+u+4rU89o9vXk2HkjdnoRW+H8VcvCdr_H04MUEBCqNg@mail.gmail.com>
	<20150413125654.GB12354@node.dhcp.inet.fi>
Date: Tue, 14 Apr 2015 13:27:39 +0300
Message-ID: <CACTTzNZJzsisnPVb_+6e2QHeoDC_q=pwD5eqe5NxDTLrFBW32w@mail.gmail.com>
Subject: Re: mlock() on DAX returns -ENOMEM
From: Yigal Korman <yigal@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Apr 13, 2015 at 3:56 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Apr 12, 2015 at 03:56:33PM +0300, Yigal Korman wrote:
>> Hi,
>> I've tried to mlock() a range of an ext4-dax file and got "-ENOMEM" in return.
>
> Is it comes from mlock_fixup() or -EFAULT from GUP translated to -ENOMEM
> by __mlock_posix_error_return()?

It comes from GUP. An associate followed the flow from GUP to
vm_normal_page which returns NULL for VM_MIXEDMAP.

>
>> Looking at the code, it seems that this is related to the fact that
>> DAX uses VM_MIXEDMAP and mlock assumes/requires regular page cache.
>> To me it seems that DAX should simply return success in mlock() as all
>> data is always in memory and no swapping is possible.
>> Is this a bug or intentional? Is there a fix planned?
>
> I think it's a bug.
>
> But first we need to define what mlock() means for DAX mappings.
>
> For writable MAP_PRIVATE: we should be able to trigger COW for the range
> and mlock resulting pages. It means we should fix kernel to handle
> GUP(FOLL_TOUCH | FOLL_POPULATE | FOLL_WRITE | FOLL_FORCE) successfully on
> such VMAs.

writable MAP_PRIVATE seems to work OK already.

>
> For MAP_SHARED and non-writable MAP_PRIVATE we should be able to populate
> the mapping with PTEs. Not sure if we need to set VM_LOCKED for such VMAs.
> We probably should, as we want to re-instantiate PTEs on mremap() and such.
> It means we need to get working at least GUP(FOLL_POPULATE | FOLL_FORCE).
>
> In general we need to adjust GUP to avoid going to struct page unless
> FOLL_* speficly imply struct page, such as FOLL_GET or FOLL_TOUCH.
>
> Not sure if we need to differentiate DAX mappings from other VM_MIXEDMAP.
>
> Any comments?

Indeed, the issue is VM_MIXEDMAP and not DAX specifically.
What will happen for other users of VM_MIXEDMAP that, unlike DAX, do
swap pages and need some special callback to handle mlock?

>
>> Also, the same code path that is used in mlock is also used for
>> MAP_POPULATE (pre-fault pages in mmap) so this flag doesn't work as
>> well (doesn't fail but simply doesn't pre-fault anything).
>>
>> Thanks,
>> Yigal
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
>  Kirill A. Shutemov

Thanks,
Yigal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
