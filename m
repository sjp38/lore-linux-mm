Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DD8CB6B006A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:58:31 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so4305188and.26
        for <linux-mm@kvack.org>; Tue, 02 Jun 2009 22:58:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090602083852.GC5960@csn.ul.ie>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
	 <20090528095904.GD10334@csn.ul.ie>
	 <202cde0e0905292227tc619a17h41df83d22bc922fa@mail.gmail.com>
	 <20090602083852.GC5960@csn.ul.ie>
Date: Wed, 3 Jun 2009 17:58:30 +1200
Message-ID: <202cde0e0906022258g2bd825a9ncfc1e1b83dbee4e8@mail.gmail.com>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order allocations
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

Mel, Kame San,

Thanks a lot for your answers and good advises it is more or less clear why
counting needs to be per page based.
Code which splits pages works fine - no issues.

On Tue, Jun 2, 2009 at 8:38 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Sat, May 30, 2009 at 05:27:15PM +1200, Alexey Korolev wrote:
>> Hi,
>> >> To allocate memory I use standard function alloc_apges(gfp_mask,
>> >> order) which asks buddy allocator to give a chunk of memory of given
>> >> "order".
>> >> Allocator returns page and also sets page count to 1 but for page of
>> >> high order. I.e. pages 2,3 etc inside high order allocation will have
>> >> page->_count=3D=3D0.
>> >> If I try to mmap allocated area to user space vm_insert_page will
>> >> return error as pages 2,3, etc are not refcounted.
>> >>
>> >
>> > page =3D alloc_pages(high_order);
>> > split_page(page, high_order);
>> >
>> > That will fix up the ref-counting of each of the individual pages. You=
 are
>> > then responsible for freeing them individually. As you are inserting t=
hese
>> > into userspace, I suspect that's ok.
>>
>> It seems it is the only way I have now. It is not so elegant - but shoul=
d work.
>> Thanks for good advise.
>>
>> BTW: Just out of curiosity what limits mapping high ordered pages into
>> user space. I tried to find any except the check in vm_insert but
>> failed. Is this checks caused by possible swapping?
>>
>
> Nothing limits it as such other than it's usually not required. There is
> nothing really that special about high-order pages other than they are
> physically contiguous. The expectation is normally that userspace does
> not care about physical contiguity.
>
> There is expected to be a 1 to 1 mapping of PTE to ref-counted pages so t=
hat
> they get freed at the right times so it's not just about swapping.
>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
