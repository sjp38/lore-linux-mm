Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 826DC6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:38:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r63so43276071itc.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:38:48 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y127si20939781itc.54.2017.06.01.07.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 07:38:47 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E11CB23A0C
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:38:46 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id y4so28599640uay.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601143344.GA3961@redhat.com>
References: <20170531150349.4816-1-jglisse@redhat.com> <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
 <20170601143344.GA3961@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 1 Jun 2017 07:38:25 -0700
Message-ID: <CALCETrWhehYF-2pPxH5S6px=hi=MaTeO6OC7_Ro3MgfKpyBhxg@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 1, 2017 at 7:33 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Jun 01, 2017 at 06:59:04AM -0700, Andy Lutomirski wrote:
>> On Wed, May 31, 2017 at 8:03 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat=
.com> wrote:
>> > Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
>> > we no longer cleanup stall pgd entries and thus the BUG_ON() inside
>> > sync_global_pgds() is wrong.
>> >
>> > This patch remove the BUG_ON() and unconditionaly update stall pgd
>> > entries.
>> >
>> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> > Cc: Ingo Molnar <mingo@kernel.org>
>> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > ---
>> >  arch/x86/mm/init_64.c | 7 +------
>> >  1 file changed, 1 insertion(+), 6 deletions(-)
>> >
>> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> > index ff95fe8..36b9020 100644
>> > --- a/arch/x86/mm/init_64.c
>> > +++ b/arch/x86/mm/init_64.c
>> > @@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, unsign=
ed long end)
>> >                         pgt_lock =3D &pgd_page_get_mm(page)->page_tabl=
e_lock;
>> >                         spin_lock(pgt_lock);
>> >
>> > -                       if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
>> > -                               BUG_ON(p4d_page_vaddr(*p4d)
>> > -                                      !=3D p4d_page_vaddr(*p4d_ref));
>> > -
>> > -                       if (p4d_none(*p4d))
>> > -                               set_p4d(p4d, *p4d_ref);
>> > +                       set_p4d(p4d, *p4d_ref);
>>
>> If we have a mismatch in the vmalloc range, vmalloc_fault is going to
>> screw up and we'll end up using incorrect page tables.
>>
>> What's causing the mismatch?  If you're hitting this BUG in practice,
>> I suspect we have a bug elsewhere.
>
> No bug elsewhere, simply hotplug memory then hotremove same memory you
> just hotplugged then hotplug it again and you will trigger this as on
> the first hotplug we allocate p4d/pud for the struct pages area, then on
> hot remove we free that memory and clear the p4d/pud in the mm_init pgd
> but not in any of the other pgds.

That sounds like a bug to me.  Either we should remove the stale
entries and fix all the attendant races, or we should unconditionally
allocate second-highest-level kernel page tables in unremovable memory
and never free them.  I prefer the latter even though it's slightly
slower.

> So at that point the next hotplug
> will trigger the BUG because of stall entries from the first hotplug.

By the time we have a pgd with an entry pointing off into the woods,
we've already lost.  Removing the BUG just hides the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
