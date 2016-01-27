Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CC6FF6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:12:05 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p63so4684508wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:12:05 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id ld8si10809819wjc.77.2016.01.27.13.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 13:12:04 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id r129so161486870wmr.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:12:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160127194132.GA896@redhat.com>
References: <CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com>
 <CALYGNiP6-T=LuBwzKys7TPpFAiGC-U7FymDT4kr3Zrcfo7CoiQ@mail.gmail.com>
 <CACT4Y+YNUZumEy2-OXhDku3rdn-4u28kCDRKtgYaO2uA9cYv5w@mail.gmail.com>
 <CACT4Y+afp8BaUvQ72h7RzQuMOX05iDEyP3p3wuZfjaKcW_Ud9A@mail.gmail.com> <20160127194132.GA896@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 27 Jan 2016 22:11:44 +0100
Message-ID: <CACT4Y+Z86=NoNPrS-vgtJiB54Akwq6FfAPf2wnBA1FX2BHafWQ@mail.gmail.com>
Subject: Re: mm: BUG in expand_downwards
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Wed, Jan 27, 2016 at 8:41 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 01/27, Dmitry Vyukov wrote:
>>
>> On Wed, Jan 27, 2016 at 1:24 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > On Wed, Jan 27, 2016 at 12:49 PM, Konstantin Khlebnikov
>> > <koct9i@gmail.com> wrote:
>> >> It seems anon_vma appeared between lock and unlock.
>> >>
>> >> This should fix the bug and make code faster (write lock isn't required here)
>> >>
>> >> --- a/mm/mmap.c
>> >> +++ b/mm/mmap.c
>> >> @@ -453,12 +453,16 @@ static void validate_mm(struct mm_struct *mm)
>> >>         struct vm_area_struct *vma = mm->mmap;
>> >>
>> >>         while (vma) {
>> >> +               struct anon_vma *anon_vma = vma->anon_vma;
>> >>                 struct anon_vma_chain *avc;
>> >>
>> >> -               vma_lock_anon_vma(vma);
>> >> -               list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
>> >> -                       anon_vma_interval_tree_verify(avc);
>> >> -               vma_unlock_anon_vma(vma);
>> >> +               if (anon_vma) {
>> >> +                       anon_vma_lock_read(anon_vma);
>> >> +                       list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
>> >> +                               anon_vma_interval_tree_verify(avc);
>> >> +                       anon_vma_unlock_read(anon_vma);
>> >> +               }
>> >> +
>> >>                 highest_address = vma->vm_end;
>> >>                 vma = vma->vm_next;
>> >>                 i++;
>> >
>> >
>> > Now testing with this patch. Thanks for quick fix!
>>
>>
>> Hit the same BUG with this patch.
>
> Do you mean the same "bad unlock balance detected" BUG? this should be "obviously"
> fixed by the patch above...
>
> Or you mean the 2nd VM_BUG_ON_MM() ?
>
>> Please try to reproduce it locally and test.
>
> tried to reproduce, doesn't work.


Sorry, I meant only the second once. The mm bug.
I guess you need at least CONFIG_DEBUG_VM.  Run it in a tight parallel
loop with CPU oversubscription (e.g. 32 parallel processes on 2 cores)
for  at least an hour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
