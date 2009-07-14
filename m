Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D13886B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 07:21:13 -0400 (EDT)
Received: by pxi13 with SMTP id 13so1534218pxi.12
        for <linux-mm@kvack.org>; Tue, 14 Jul 2009 04:51:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090714093718.GB28569@csn.ul.ie>
References: <alpine.LFD.2.00.0907140244220.25576@casper.infradead.org>
	 <20090714093718.GB28569@csn.ul.ie>
Date: Tue, 14 Jul 2009 23:51:59 +1200
Message-ID: <202cde0e0907140451h14ecb494xe7a8e7d9c235d538@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/2] HugeTLB mapping for drivers (Alloc/free for
	drivers, hstate_nores)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Ok, this makes me raise an eyebrow immediately. Things to watch out for
> are
>
> o allocations made by the driver that are not faulted immediately can
> =C2=A0potentially fail at fault time if reservations are not made
> o allocations that ignore the userspace reservations and allocate huge
> =C2=A0pages from the pool potentially cause application failure later

Indeed.
>
> You deal with the latter but the former will depend on how the driver is
> implemented.
>
>> This is different to prototype. Why it is implemented? HugetlbFs and
>> drivers reservations has completely different sources of reservations.
>> In hugetlbfs case it is dictated by users. So it is necessary to bother
>> about restrictions/ quotas etc.
>
> The reservations in the hugetlbfs case are about stability. If hugepages
> were not reserved or allocated at mmap() time, a failure to allocate a
> page at fault time will force-kill the application. Be careful that
> drivers really are immune from the same problem.
>
Dirvers must care about cases when there is no memory. For example failure
to allocate DMA buffer in device driver usually means inaccessible
device. It is
normal to expect module insert failure (or failure of all further
requests) in this case.
Usually applications have information about size of DMA buffer.
If an application requested memory which is out of range it will be
fine to terminate the application, but kernel mustn't fall to panic.
(Oneof test case - will check around it)

>> In driver case it is dictated by HW. In thius case it is necessary invol=
ve user
>> in tuning process as less as possible.
>> If we would use HugeTlbFs reservations - we would need to force user to
>> supply how much huge pages needs to be reserved for drivers.
>> To protect drivers to interract with htlbfs reservations the state hstat=
e_nores was
>> introduced.
>
> What does nores mean?
>
nores means no reservation. I.e. if we are in this stage it tells
hugetlb.c functions to
behave as VM_NORESERVE flag is specified.
Initially name was hstate_drv. (but it sounds not so good as well )

>> Reservations with a state hstate_nores should not touch htlb
>> pools.
>>
>
> Ok, that's good, but you still need to be careful in the event you setup
> a mapping that doesn't have associated hugepages allocated.
>
Who setup mapping driver or application?
If driver - it will be rather hard to said what we should do in this
case. I would
prefer to see panic because it means driver did something nasty.

>> +void hugetlb_free_pages(struct page *page)
>> +{
>
> This name is too general. There is nothing to indicate that it is only
> used by drivers.

Acked.
Need to think more about good naming. I will discuss it with
colleagues. It is hard to
choose something good now.

>
>> + =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 struct hstate *h =3D &hstate_nores;
>> +
>> + =C2=A0 =C2=A0 VM_BUG_ON(h->order >=3D MAX_ORDER);
>> +
>
> This is a perfectly possible condition for you unfortunately in the curre=
nt
> initialisation of hstate_nores. Nothing stops the default hugepage size b=
eing
> set to 1G or 16G on machines that wanted that pagesize used for shared me=
mory
> segments. On such configurations, you should either be failing the alloca=
tion
> or having hstate_nores use a smaller hugepage size.
>
Ahhhh! I did not expect this. So it is necessary to be very accurate
when choosing parameters
of hstate_nores. Thanks a lot for pointing to this.

>> + =C2=A0 =C2=A0 for (i =3D 0; i < pages_per_huge_page(h); i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page[i].flags &=3D ~(1 << PG=
_locked | 1 << PG_error |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
1 << PG_referenced | 1 << PG_dirty | 1 << PG_active |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
1 << PG_reserved | 1 << PG_private | 1 << PG_writeback);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 set_compound_page_dtor(page, NULL);
>> + =C2=A0 =C2=A0 set_page_refcounted(page);
>> + =C2=A0 =C2=A0 arch_release_hugepage(page);
>> + =C2=A0 =C2=A0 __free_pages(page, huge_page_order(h));
>> +}
>> +EXPORT_SYMBOL(hugetlb_free_pages);
>
> You need to reuse update_and_free_page() somehow here by splitting the
> accounting portion from the page free portion. I know this is a
> prototype but at least comment that it's copied from
> update_and_free_page() for anyone else looking to review this that is
> not familiar with hugetlbfs.
>
Acked. Thanks. Will be updated.
>> +
>> =C2=A0/* Put bootmem huge pages into the standard lists after mem_map is=
 up */
>> =C2=A0static void __init gather_bootmem_prealloc(void)
>> =C2=A0{
>> @@ -1078,7 +1123,13 @@ static void __init hugetlb_init_hstates(
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (h->order < MAX_ORDE=
R)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 hugetlb_hstate_alloc_pages(h);
>> =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 /* Special hstate for use of drivers, allocations are no=
t
>> + =C2=A0 =C2=A0 =C2=A0* tracked by hugetlbfs */
>
> The term "tracked" doesn't really say anything. How about something
> like;
>
> /*
> =C2=A0* hstate_nores is used by drivers. Allocations are immediate,
> =C2=A0* there is no hugepage pool and there are no reservations made
> =C2=A0*/
>
Immediate sounds better. Seems naming needs to be tuned more. I'll ask
colleagues
to help here.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
