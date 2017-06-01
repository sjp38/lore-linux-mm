Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 130B36B02C3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:39:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c6so53205135pfj.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:39:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j3si14987781pgs.370.2017.06.01.11.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:39:00 -0700 (PDT)
Received: from mail-ua0-f176.google.com (mail-ua0-f176.google.com [209.85.217.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C7E7B239F1
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 18:38:59 +0000 (UTC)
Received: by mail-ua0-f176.google.com with SMTP id x47so32720644uab.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:38:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601151107.GC3961@redhat.com>
References: <20170531150349.4816-1-jglisse@redhat.com> <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
 <20170601143344.GA3961@redhat.com> <CALCETrWhehYF-2pPxH5S6px=hi=MaTeO6OC7_Ro3MgfKpyBhxg@mail.gmail.com>
 <20170601151107.GC3961@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 1 Jun 2017 11:38:38 -0700
Message-ID: <CALCETrXsDj5wEq9womFRA0JzijmPr05vNc5gqVQK6-RrK+kPzQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 1, 2017 at 8:11 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Jun 01, 2017 at 07:38:25AM -0700, Andy Lutomirski wrote:
>> On Thu, Jun 1, 2017 at 7:33 AM, Jerome Glisse <jglisse@redhat.com> wrote=
:
>> > On Thu, Jun 01, 2017 at 06:59:04AM -0700, Andy Lutomirski wrote:
>> >> On Wed, May 31, 2017 at 8:03 AM, J=C3=A9r=C3=B4me Glisse <jglisse@red=
hat.com> wrote:
>> >> > Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()=
")
>> >> > we no longer cleanup stall pgd entries and thus the BUG_ON() inside
>> >> > sync_global_pgds() is wrong.
>> >> >
>> >> > This patch remove the BUG_ON() and unconditionaly update stall pgd
>> >> > entries.
>> >> >
>> >> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> >> > Cc: Ingo Molnar <mingo@kernel.org>
>> >> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> >> > ---
>> >> >  arch/x86/mm/init_64.c | 7 +------
>> >> >  1 file changed, 1 insertion(+), 6 deletions(-)
>> >> >
>> >> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> >> > index ff95fe8..36b9020 100644
>> >> > --- a/arch/x86/mm/init_64.c
>> >> > +++ b/arch/x86/mm/init_64.c
>> >> > @@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, uns=
igned long end)
>> >> >                         pgt_lock =3D &pgd_page_get_mm(page)->page_t=
able_lock;
>> >> >                         spin_lock(pgt_lock);
>> >> >
>> >> > -                       if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
>> >> > -                               BUG_ON(p4d_page_vaddr(*p4d)
>> >> > -                                      !=3D p4d_page_vaddr(*p4d_ref=
));
>> >> > -
>> >> > -                       if (p4d_none(*p4d))
>> >> > -                               set_p4d(p4d, *p4d_ref);
>> >> > +                       set_p4d(p4d, *p4d_ref);
>> >>
>> >> If we have a mismatch in the vmalloc range, vmalloc_fault is going to
>> >> screw up and we'll end up using incorrect page tables.
>> >>
>> >> What's causing the mismatch?  If you're hitting this BUG in practice,
>> >> I suspect we have a bug elsewhere.
>> >
>> > No bug elsewhere, simply hotplug memory then hotremove same memory you
>> > just hotplugged then hotplug it again and you will trigger this as on
>> > the first hotplug we allocate p4d/pud for the struct pages area, then =
on
>> > hot remove we free that memory and clear the p4d/pud in the mm_init pg=
d
>> > but not in any of the other pgds.
>>
>> That sounds like a bug to me.  Either we should remove the stale
>> entries and fix all the attendant races, or we should unconditionally
>> allocate second-highest-level kernel page tables in unremovable memory
>> and never free them.  I prefer the latter even though it's slightly
>> slower.
>>
>> > So at that point the next hotplug
>> > will trigger the BUG because of stall entries from the first hotplug.
>>
>> By the time we have a pgd with an entry pointing off into the woods,
>> we've already lost.  Removing the BUG just hides the problem.
>
> Then why did you sign of on af2cf278ef4f9289f88504c3e03cb12f76027575
> this is what introduced this change in behavior.
>
> If i understand you correctly you want to avoid deallocating p4d/pud
> directory page when hotremove happen ? But this happen in common non
> arch specific code vmemmap_populate_basepages() thought we can make
> x86 vmemmap_populate() code arch different thought.
>
> So i am not sure how to proceed here. My first attempt was to undo
> af2cf278ef4f9289f88504c3e03cb12f76027575 so that we keep all pgds
> synchronize. No if we want special case p4d/pud allocation that's
> a different approach all together.
>

The intent of that patch was to leave the pud table allocated and to
leave the pgd entry in place.  The code appears to do that.

I'm not terribly familiar with memory hotplug.  Where's the
problematic code?  I suspect there's a fairly simple bug somewhere
that needs fixing.  kernel_physical_mapping_init() looks right,
though.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
