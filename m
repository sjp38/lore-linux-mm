Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32BEE6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 13:15:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so15990467lfg.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:15:17 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id r22si21818014wme.34.2016.07.12.10.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 10:15:15 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id i5so34030615wmg.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:15:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160712133942.GA28837@redhat.com>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org>
 <1468014494-25291-3-git-send-email-keescook@chromium.org> <20160711122826.GA969@redhat.com>
 <CAGXu5j+efUrhOTikpuYK0V8Eqv58f5rQBMOYDqiVM-JWrqRbLA@mail.gmail.com> <20160712133942.GA28837@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 12 Jul 2016 13:15:14 -0400
Message-ID: <CAGXu5j+oZ49K0omm-7yMsR_kFYD-DQcYG8f+urS+TumzFYXR_w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 9:39 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/11, Kees Cook wrote:
>>
>> On Mon, Jul 11, 2016 at 8:28 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> >
>> > and thus this patch fixes the error code returned by do_brk() in case
>> > of overflow, now it returns -ENOMEM rather than zero. Perhaps
>> >
>> >         if (!len)
>> >                 return 0;
>> >         len = PAGE_ALIGN(len);
>> >         if (!len)
>> >                 return -ENOMEM;
>> >
>> > would be more clear but this is subjective.
>>
>> I'm fine either way.
>
> Me too, so feel free to ignore,
>
>> > I am wondering if we should shift this overflow check to the caller(s).
>> > Say, sys_brk() does find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE)
>> > before do_brk(), and in case of overflow find_vma_intersection() can
>> > wrongly return NULL.
>> >
>> > Then do_brk() will be called with len = -oldbrk, this can overflow or
>> > not but in any case this doesn't look right too.
>> >
>> > Or I am totally confused?
>>
>> I think the callers shouldn't request a negative value, sure, but
>> vm_brk should notice and refuse it.
>
> Not sure I understand...
>
> I tried to say that, with or without this change, sys_brk() should check
> for overflow too, otherwise it looks buggy.

Hmm, it's not clear to me the right way to fix sys_brk(), but it looks
like my change to do_brk() would catch the problem?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
