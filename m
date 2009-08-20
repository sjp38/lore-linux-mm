Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 22BDD6B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 03:03:28 -0400 (EDT)
Received: by yxe14 with SMTP id 14so6388998yxe.12
        for <linux-mm@kvack.org>; Thu, 20 Aug 2009 00:03:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819100553.GE24809@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
	 <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
	 <20090819100553.GE24809@csn.ul.ie>
Date: Thu, 20 Aug 2009 19:03:28 +1200
Message-ID: <202cde0e0908200003w43b91ac3v8a149ec1ace45d6d@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel,

>> User level applications process the data.
>> Device is using a master DMA to send data to the user buffer, buffer
>> size can be >1GB and performance is very important. (So huge pages
>> mapping really makes sense.)
>>
>
> Ok, so the DMA may be faster because you have to do less scatter/gather
> and can DMA in larger chunks and and reading from userspace may be faster
> because there is less translation overhead. Right?
>
Less translation overhead is important. Unfortunately not all devices
have scatter/gather
(our case) as having it increase h/w complexity a lot.

>> In addition we have to mention that:
>> 1. It is hard for user to tell how much huge pages needs to be
>> =C2=A0 =C2=A0reserved by the driver.
>
> I think you have this problem either way. If the buffer is allocated and
> populated before mmap(), then the driver is going to have to guess how ma=
ny
> pages it needs. If the DMA occurs as a result of mmap(), it's easier beca=
use
> you know the number of huge pages to be reserved at that point and you ha=
ve
> the option of falling back to small pages if necessary.
>
>> 2. Devices add constrains on memory regions. For example it needs to
>> =C2=A0 =C2=A0be contiguous with in the physical address space. It is nec=
essary to
>> =C2=A0 have ability to specify special gfp flags.
>
> The contiguity constraints are the same for huge pages. Do you mean there
> are zone restrictions? If so, the hugetlbfs_file_setup() function could b=
e
> extended to specify a GFP mask that is used for the allocation of hugepag=
es
> and associated with the hugetlbfs inode. Right now, there is a htlb_alloc=
_mask
> mask that is applied to some additional flags so htlb_alloc_mask would be
> the default mask unless otherwise specified.
>
Under contiguous I mean that we need several huge pages being
physically contiguous.
To obtain it we allocate pages till not find a contig. region
(success) or reach a boundary (fail).
So in our particular case approach based on getting pages from
hugetlbfs won't work
because memory region will not be contiguous.
However this approach will give an easy way to support hugetlb
mapping, it won't cause any complexity
in accounting. But it will be suitable for hardware with large amount
of sg regions only.

>
> How about;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0o Extend Eric's helper slightly to take a GFP =
mask that is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0associated with the inode and used for =
allocations from
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0outside the hugepage pool
> =C2=A0 =C2=A0 =C2=A0 =C2=A0o A helper that returns the page at a given of=
fset within
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0a hugetlbfs file for population before =
the page has been
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0faulted.
Do you mean get_user_pages call?

Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
