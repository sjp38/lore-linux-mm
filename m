Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A3BC36B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 13:49:43 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id o10so328727qcv.7
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 10:49:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130604154500.GA5664@gmail.com>
References: <201306040922.10235.frank.mehnert@oracle.com>
	<20130604115807.GF3672@sgi.com>
	<201306041414.52237.frank.mehnert@oracle.com>
	<20130604154500.GA5664@gmail.com>
Date: Tue, 4 Jun 2013 13:49:42 -0400
Message-ID: <CAH3drwZMe-6y-nVvpzOBzH28-hVJCO7QzXV5hPgM8n8SgH9kFA@mail.gmail.com>
Subject: Re: Handling NUMA page migration
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Tue, Jun 4, 2013 at 11:45 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Tue, Jun 04, 2013 at 02:14:45PM +0200, Frank Mehnert wrote:
>> On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
>> > This is probably more appropriate to be directed at the linux-mm
>> > mailing list.
>> >
>> > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
>> > > Hi,
>> > >
>> > > our memory management on Linux hosts conflicts with NUMA page migration.
>> > > I assume this problem existed for a longer time but Linux 3.8 introduced
>> > > automatic NUMA page balancing which makes the problem visible on
>> > > multi-node hosts leading to kernel oopses.
>> > >
>> > > NUMA page migration means that the physical address of a page changes.
>> > > This is fatal if the application assumes that this never happens for
>> > > that page as it was supposed to be pinned.
>> > >
>> > > We have two kind of pinned memory:
>> > >
>> > > A) 1. allocate memory in userland with mmap()
>> > >
>> > >    2. madvise(MADV_DONTFORK)
>> > >    3. pin with get_user_pages().
>> > >    4. flush dcache_page()
>> > >    5. vm_flags |= (VM_DONTCOPY | VM_LOCKED)
>> > >
>> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
>> > >
>> > >        VM_DONTCOPY | VM_LOCKED | 0xff)
>> >
>> > I don't think this type of allocation should be affected.  The
>> > get_user_pages() call should elevate the pages reference count which
>> > should prevent migration from completing.  I would, however, wait for
>> > a more definitive answer.
>>
>> Thanks Robin! Actually case B) is more important for us so I'm waiting
>> for more feedback :)
>>
>> Frank
>>
>> > > B) 1. allocate memory with alloc_pages()
>> > >
>> > >    2. SetPageReserved()
>> > >    3. vm_mmap() to allocate a userspace mapping
>> > >    4. vm_insert_page()
>> > >    5. vm_flags |= (VM_DONTEXPAND | VM_DONTDUMP)
>> > >
>> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
>> > >       0xff)
>> > >
>> > > At least the memory allocated like B) is affected by automatic NUMA page
>> > > migration. I'm not sure about A).
>> > >
>> > > 1. How can I prevent automatic NUMA page migration on this memory?
>> > > 2. Can NUMA page migration also be handled on such kind of memory without
>> > >
>> > >    preventing migration?
>> > >
>> > > Thanks,
>> > >
>> > > Frank
>
> I was looking at migration code lately, and while i am not an expert at all
> in this area. I think there is a bug in the way handle_mm_fault deals, or
> rather not deals, with migration entry.
>
> When huge page is migrated its pmd is replace with a special swp entry pmd,
> which is a non zero pmd but that does not have any of the huge pmd flag set
> so none of the handle_mm_fault path detect it as swap entry. Then believe
> its a valid pmd and try to allocate pte under it which should oops.
>
> Attached patch is what i believe should be done (not even compile tested).
>
> Again i might be missing a subtelty somewhere else and just missed where
> huge migration entry are dealt with.
>
> Cheers,
> Jerome

Never mind i was missing something hugetlb_fault will handle it.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
