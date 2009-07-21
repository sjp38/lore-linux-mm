Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 03A576B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 05:32:35 -0400 (EDT)
Received: by yxe35 with SMTP id 35so4763252yxe.12
        for <linux-mm@kvack.org>; Tue, 21 Jul 2009 02:32:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090720081130.GA7989@csn.ul.ie>
References: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org>
	 <20090714102735.GD28569@csn.ul.ie>
	 <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com>
	 <202cde0e0907190639k7bbebc63k143734ad696f90f5@mail.gmail.com>
	 <20090720081130.GA7989@csn.ul.ie>
Date: Tue, 21 Jul 2009 21:32:34 +1200
Message-ID: <202cde0e0907210232gc8a6119jc7f2ba522d22a80d@mail.gmail.com>
Subject: Re: HugeTLB mapping for drivers (sample driver)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
>
> Did the OOM killer really trigger and select a process for killing or
> did the process itself just get killed with an out-of-memory message? I
> would have expected the latter.
>
OMM killer triggered in case of private mapping on attempt to access a
page under private mapping. It was because code did not check the pages
availability at mmap time. Will be fixed.

>> In fact there should be quite few cases when private mapping makes
>> sense for drivers and mapping DMA buffers. I thought about possible
>> solutions. The question is what to choose.
>>
>> 1. Forbid private mappings for drivers in case of hugetlb. (But this
>> limits functionality - it is not so good)
>
> For a long time, this was the "solution" for hugetlbfs.
>
>> 2. Allow private mapping. Use hugetlbfs hstates. (But it forces user
>> to know how much hugetlb memory it is necessary to reserve for
>> drivers)
>
> You can defer working out the reservations until mmap() time,
> particularly if you are using dynamic hugepage pool resizing instead of
> static allocation.
>
>> 3. Allow private mapping. Use special hstate for driver and driver
>> should tell how much memory needs to be reserved for it. (Not clear
>> yet how to behave if we are out of reserved space)
>>
>> Could you please suggest what is the best solution? May be some other op=
tions?
>>
>
> The only solution that springs to mind is the same one used by hugetlbfs
> and that is that reservations are taken at mmap() time for the size of th=
e
> mapping. In your case, you prefault but either way, the hugepages exist.
>
Yes, that looks sane. I'll follow this way. In a particular case if
driver do not
need a private mapping mmap will return error. Thanks for the advice.
I'm about
to modify the patches. I'll try to involve  hugetlb reservation
functions as much  as
possible and track reservations by special hstate for drivers.

> What then happens for hugetlbfs is that only the process that called mmap=
()
> is guaranteed their faults will succeed. If a child process incurs a COW
> and the hugepages are not available, the child process gets killed. If
> the parent process performs COW and the huge pages are not available, it
> unmaps the pages from the child process so that COW becomes unnecessary. =
If
> the child process then faults, it gets killed. =C2=A0This is implemented =
in
> mm/hugetlb.c#unmap_ref_private().

So on out of memory COW hugetlb code prefer applications to be killed by
SIGSEGV (SIGBUS?) instead of OOM. Okk.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
