Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D87866B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:01:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so58015315wma.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:01:12 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id h6si787056wjw.273.2016.07.11.11.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 11:01:10 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id f65so73095737wmi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:01:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160711122826.GA969@redhat.com>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org>
 <1468014494-25291-3-git-send-email-keescook@chromium.org> <20160711122826.GA969@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Jul 2016 14:01:08 -0400
Message-ID: <CAGXu5j+efUrhOTikpuYK0V8Eqv58f5rQBMOYDqiVM-JWrqRbLA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 11, 2016 at 8:28 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> I think both patches are fine, just a question.
>
> On 07/08, Kees Cook wrote:
>>
>> -static int do_brk(unsigned long addr, unsigned long len)
>> +static int do_brk(unsigned long addr, unsigned long request)
>>  {
>>       struct mm_struct *mm = current->mm;
>>       struct vm_area_struct *vma, *prev;
>> -     unsigned long flags;
>> +     unsigned long flags, len;
>>       struct rb_node **rb_link, *rb_parent;
>>       pgoff_t pgoff = addr >> PAGE_SHIFT;
>>       int error;
>>
>> -     len = PAGE_ALIGN(len);
>> +     len = PAGE_ALIGN(request);
>> +     if (len < request)
>> +             return -ENOMEM;
>
> So iiuc "len < request" is only possible if len == 0, right?

Oh, hrm, good point.

>
>>       if (!len)
>>               return 0;
>
> and thus this patch fixes the error code returned by do_brk() in case
> of overflow, now it returns -ENOMEM rather than zero. Perhaps
>
>         if (!len)
>                 return 0;
>         len = PAGE_ALIGN(len);
>         if (!len)
>                 return -ENOMEM;
>
> would be more clear but this is subjective.

I'm fine either way.

> I am wondering if we should shift this overflow check to the caller(s).
> Say, sys_brk() does find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE)
> before do_brk(), and in case of overflow find_vma_intersection() can
> wrongly return NULL.
>
> Then do_brk() will be called with len = -oldbrk, this can overflow or
> not but in any case this doesn't look right too.
>
> Or I am totally confused?

I think the callers shouldn't request a negative value, sure, but
vm_brk should notice and refuse it.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
