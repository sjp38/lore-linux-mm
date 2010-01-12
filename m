Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 671206B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 19:01:08 -0500 (EST)
Received: by pxi5 with SMTP id 5so16298863pxi.12
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 16:00:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1001112334250.7893@sister.anvils>
References: <20100111114607.1d8cd1e0.minchan.kim@barrios-desktop>
	 <alpine.LSU.2.00.1001112334250.7893@sister.anvils>
Date: Tue, 12 Jan 2010 09:00:57 +0900
Message-ID: <28c262361001111600k7cc377dchcfa0814410103b21@mail.gmail.com>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] Count minor fault in break_ksm
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Hugh.

On Tue, Jan 12, 2010 at 8:40 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Mon, 11 Jan 2010, Minchan Kim wrote:
>
>> We have counted task's maj/min fault after handle_mm_fault.
>> break_ksm misses that.
>>
>> I wanted to check by VM_FAULT_ERROR.
>> But now break_ksm doesn't handle HWPOISON error.
>
> Sorry, no, I just don't see a good reason to add this.
> Imagine it this way: these aren't really faults, KSM simply
> happens to be using "handle_mm_fault" to achieve what it needs.

Why I suggest is handle_mm_fault counts PGFAULT in system.
If we want to get minor fault count in system, we have to calculate
(PGFAULT - PGMAJFAULT).

But we don't count it as either major or minor in this case and GUP case
I doubt it, then I see GUP already handled it tsk->[maj|min]flt.
Although it isn't my point, I thought break_ksm also have to count it
like GUP at least.

Okay. It's not real problem. I found just while I review the code.
I have no objection in your opinion.
But I think it would be better to have a consistency PGFAULT and PGMAJFAULT=
.


>
> (And, of course, if we did add something like this, I'd be
> disagreeing with you about which tsk's min_flt to increment.)
>
> Hugh
>
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>> CC: Izik Eidus <ieidus@redhat.com>
>> ---
>> =C2=A0mm/ksm.c | =C2=A0 =C2=A06 +++++-
>> =C2=A01 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 56a0da1..3a1fda4 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -367,9 +367,13 @@ static int break_ksm(struct vm_area_struct *vma, un=
signed long addr)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D follow_page(vm=
a, addr, FOLL_GET);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageKsm(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageKsm(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D handle_mm_fault(vma->vm_mm, vma, addr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FAULT_FLAG_WRITE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (!(ret & (VM_FAULT_SIGBUS | VM_FAULT_OOM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || current->flags &=
 PF_KTHREAD))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 current->min_flt++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D VM_FAULT_WRITE;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(page);
>> --
>> 1.5.6.3
>>
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
