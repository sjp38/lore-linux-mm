Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 170376B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:41:38 -0500 (EST)
Received: by mail-qk0-f175.google.com with SMTP id x1so8009864qkc.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:41:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d32si8021814qgd.67.2016.01.27.11.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 11:41:37 -0800 (PST)
Date: Wed, 27 Jan 2016 20:41:32 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: mm: BUG in expand_downwards
Message-ID: <20160127194132.GA896@redhat.com>
References: <CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com>
 <CALYGNiP6-T=LuBwzKys7TPpFAiGC-U7FymDT4kr3Zrcfo7CoiQ@mail.gmail.com>
 <CACT4Y+YNUZumEy2-OXhDku3rdn-4u28kCDRKtgYaO2uA9cYv5w@mail.gmail.com>
 <CACT4Y+afp8BaUvQ72h7RzQuMOX05iDEyP3p3wuZfjaKcW_Ud9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+afp8BaUvQ72h7RzQuMOX05iDEyP3p3wuZfjaKcW_Ud9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On 01/27, Dmitry Vyukov wrote:
>
> On Wed, Jan 27, 2016 at 1:24 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > On Wed, Jan 27, 2016 at 12:49 PM, Konstantin Khlebnikov
> > <koct9i@gmail.com> wrote:
> >> It seems anon_vma appeared between lock and unlock.
> >>
> >> This should fix the bug and make code faster (write lock isn't required here)
> >>
> >> --- a/mm/mmap.c
> >> +++ b/mm/mmap.c
> >> @@ -453,12 +453,16 @@ static void validate_mm(struct mm_struct *mm)
> >>         struct vm_area_struct *vma = mm->mmap;
> >>
> >>         while (vma) {
> >> +               struct anon_vma *anon_vma = vma->anon_vma;
> >>                 struct anon_vma_chain *avc;
> >>
> >> -               vma_lock_anon_vma(vma);
> >> -               list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> >> -                       anon_vma_interval_tree_verify(avc);
> >> -               vma_unlock_anon_vma(vma);
> >> +               if (anon_vma) {
> >> +                       anon_vma_lock_read(anon_vma);
> >> +                       list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> >> +                               anon_vma_interval_tree_verify(avc);
> >> +                       anon_vma_unlock_read(anon_vma);
> >> +               }
> >> +
> >>                 highest_address = vma->vm_end;
> >>                 vma = vma->vm_next;
> >>                 i++;
> >
> >
> > Now testing with this patch. Thanks for quick fix!
>
>
> Hit the same BUG with this patch.

Do you mean the same "bad unlock balance detected" BUG? this should be "obviously"
fixed by the patch above...

Or you mean the 2nd VM_BUG_ON_MM() ?

> Please try to reproduce it locally and test.

tried to reproduce, doesn't work.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
