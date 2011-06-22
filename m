Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1FED0900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:42:15 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1401716vxg.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:42:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110622150350.GX20843@redhat.com>
References: <201106212055.25400.nai.xia@gmail.com>
	<201106212132.39311.nai.xia@gmail.com>
	<20110622150350.GX20843@redhat.com>
Date: Thu, 23 Jun 2011 07:42:11 +0800
Message-ID: <BANLkTin1zB1mDOo1pJ3KWp8rNp7-2oMkQA@mail.gmail.com>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On Wed, Jun 22, 2011 at 11:03 PM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
> On Tue, Jun 21, 2011 at 09:32:39PM +0800, Nai Xia wrote:
>> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
>> index d48ec60..b407a69 100644
>> --- a/arch/x86/kvm/vmx.c
>> +++ b/arch/x86/kvm/vmx.c
>> @@ -4674,6 +4674,7 @@ static int __init vmx_init(void)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kvm_mmu_set_mask_ptes(0ull, 0ull, 0ull, 0ull=
,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VMX_EPT_EXEC=
UTABLE_MASK);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kvm_enable_tdp();
>> + =A0 =A0 =A0 =A0 =A0 =A0 kvm_dirty_update =3D 0;
>> =A0 =A0 =A0 } else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kvm_disable_tdp();
>>
>
> Why not return !shadow_dirty_mask instead of adding a new var?
>
>> =A0struct mmu_notifier_ops {
>> + =A0 =A0 int (*dirty_update)(struct mmu_notifier *mn,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mm_struct *m=
m);
>> +
>
> Needs some docu.

OK. I'll add it.

>
> I think dirty_update isn't self explanatory name. I think
> "has_test_and_clear_dirty" would be better.

Agreed.  So it will be the name in the next version. :)

Thanks,
Nai

>
> If we don't flush the smp tlb don't we risk that we'll insert pages in
> the unstable tree that are volatile just because the dirty bit didn't
> get set again on the spte?
>
> The first patch I guess it's a sign of hugetlbfs going a little over
> the edge in trying to mix with the core VM... Passing that parameter
> &need_pte_unmap all over the place not so nice, maybe it'd be possible
> to fix within hugetlbfs to use a different method to walk the hugetlb
> vmas. I'd prefer that if possible.
>
> Thanks,
> Andrea
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
