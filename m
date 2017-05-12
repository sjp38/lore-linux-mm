Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 974FE6B02EE
	for <linux-mm@kvack.org>; Thu, 11 May 2017 23:41:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d127so38003599pga.11
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:41:41 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 136si1917331pgf.338.2017.05.11.20.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 20:41:40 -0700 (PDT)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 668D7239B2
	for <linux-mm@kvack.org>; Fri, 12 May 2017 03:41:40 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id j17so40044289uag.3
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:41:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <EFEA207A-72E6-4A41-A70A-D91CC9EB8A47@gmail.com>
References: <cover.1494160201.git.luto@kernel.org> <51ec06f28360a1cc505649acaf0c9db905824115.1494160201.git.luto@kernel.org>
 <EFEA207A-72E6-4A41-A70A-D91CC9EB8A47@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 11 May 2017 20:41:18 -0700
Message-ID: <CALCETrUAGHHCS1_NX+ckjYqnqg7t2M5bzu7uVafN7J3U2x-thA@mail.gmail.com>
Subject: Re: [RFC 04/10] x86/mm: Pass flush_tlb_info to flush_tlb_others() etc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

On Thu, May 11, 2017 at 1:01 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>
>> On May 7, 2017, at 5:38 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> @@ -243,15 +237,15 @@ static void flush_tlb_func(void *info)
>>               return;
>>       }
>>
>> -     if (f->flush_end =3D=3D TLB_FLUSH_ALL) {
>> +     if (f->end =3D=3D TLB_FLUSH_ALL) {
>>               local_flush_tlb();
>>               trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
>>       } else {
>>               unsigned long addr;
>>               unsigned long nr_pages =3D
>> -                     (f->flush_end - f->flush_start) / PAGE_SIZE;
>> -             addr =3D f->flush_start;
>> -             while (addr < f->flush_end) {
>> +                     (f->end - f->start) / PAGE_SIZE;
>> +             addr =3D f->start;
>> +             while (addr < f->end) {
>>                       __flush_tlb_single(addr);
>>                       addr +=3D PAGE_SIZE;
>>               }
>> @@ -260,33 +254,27 @@ static void flush_tlb_func(void *info)
>> }
>>
>> void native_flush_tlb_others(const struct cpumask *cpumask,
>> -                              struct mm_struct *mm, unsigned long start=
,
>> -                              unsigned long end)
>> +                          const struct flush_tlb_info *info)
>> {
>> -     struct flush_tlb_info info;
>> -
>> -     info.flush_mm =3D mm;
>> -     info.flush_start =3D start;
>> -     info.flush_end =3D end;
>> -
>>       count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
>> -     if (end =3D=3D TLB_FLUSH_ALL)
>> +     if (info->end =3D=3D TLB_FLUSH_ALL)
>>               trace_tlb_flush(TLB_REMOTE_SEND_IPI, TLB_FLUSH_ALL);
>>       else
>>               trace_tlb_flush(TLB_REMOTE_SEND_IPI,
>> -                             (end - start) >> PAGE_SHIFT);
>> +                             (info->end - info->start) >> PAGE_SHIFT);
>
> I know it is stupid, but since you already change the code, can you make
> flush_tlb_func() and native_flush_tlb_others() consistent in the way
> they compute the number of pages? (either =E2=80=98>> PAGE_SHIFT=E2=80=99=
 or =E2=80=98/ PAGE_SIZE=E2=80=99)?

I added this to the queue.

>
> On a different topic: I do not like or actually understand why TLBSTATE_O=
K
> is defined as 1 and not 0. The very least it would generate a better code=
.

Me neither.  The value 0 can happen too, e.g. for init_mm.  Maybe I'll
clean that up when I'm all done with this stuff.

>
> Thanks,
> Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
