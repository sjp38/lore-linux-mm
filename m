Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6BE46B02C3
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 10:05:40 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id o81so32113971ybg.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:05:40 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id m66si1191578ywb.122.2017.06.23.07.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 07:05:39 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id m47so8881661iti.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:05:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623135924.GC5314@dhcp22.suse.cz>
References: <20170622001720.GA32173@beast> <20170623135924.GC5314@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 23 Jun 2017 07:05:37 -0700
Message-ID: <CAGXu5jJB-DKWLVPKL5-BiCF5Rmn3M_Q5yTPxtn8HW-2VekBaXg@mail.gmail.com>
Subject: Re: [PATCH] exec: Account for argv/envp pointers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Qualys Security Advisory <qsa@qualys.com>, Linux-MM <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, Jun 23, 2017 at 6:59 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 21-06-17 17:17:20, Kees Cook wrote:
>> When limiting the argv/envp strings during exec to 1/4 of the stack limit,
>> the storage of the pointers to the strings was not included. This means
>> that an exec with huge numbers of tiny strings could eat 1/4 of the
>> stack limit in strings and then additional space would be later used
>> by the pointers to the strings. For example, on 32-bit with a 8MB stack
>> rlimit, an exec with 1677721 single-byte strings would consume less than
>> 2MB of stack, the max (8MB / 4) amount allowed, but the pointers to the
>> strings would consume the remaining additional stack space (1677721 *
>> 4 == 6710884). The result (1677721 + 6710884 == 8388605) would exhaust
>> stack space entirely. Controlling this stack exhaustion could result in
>> pathological behavior in setuid binaries (CVE-2017-1000365).
>>
>> Fixes: b6a2fea39318 ("mm: variable length argument support")
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  fs/exec.c | 20 ++++++++++++++++----
>>  1 file changed, 16 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 72934df68471..8079ca70cfda 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -220,8 +220,18 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>>
>>       if (write) {
>>               unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
>> +             unsigned long ptr_size;
>>               struct rlimit *rlim;
>>
>> +             /*
>> +              * Since the stack will hold pointers to the strings, we
>> +              * must account for them as well.
>> +              */
>> +             ptr_size = (bprm->argc + bprm->envc) * sizeof(void *);
>> +             if (ptr_size > ULONG_MAX - size)
>> +                     goto fail;
>> +             size += ptr_size;
>> +
>>               acct_arg_size(bprm, size / PAGE_SIZE);
>
> Doesn't this over account? I mean this gets called for partial arguments
> as they fit into a page so a single argument can get into this function
> multiple times AFAIU. I also do not understand why would you want to
> account bprm->argc + bprm->envc pointers for each argument.

Based on what I could understand in acct_arg_size(), this is called
repeatedly with with the "current" size (it handles the difference
between prior calls, see calls like acct_arg_size(bprm, 0)).

The size calculation is the entire vma while each arg page is built,
so each time we get here it's calculating how far it is currently
(rather than each call being just the newly added size from the arg
page). As a result, we need to always add the entire size of the
pointers, so that on the last call to get_arg_page() we'll actually
have the entire correct size.

-Kees

>
>>
>>               /*
>> @@ -239,13 +249,15 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>>                *    to work from.
>>                */
>>               rlim = current->signal->rlim;
>> -             if (size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4) {
>> -                     put_page(page);
>> -                     return NULL;
>> -             }
>> +             if (size > READ_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4)
>> +                     goto fail;
>>       }
>>
>>       return page;
>> +
>> +fail:
>> +     put_page(page);
>> +     return NULL;
>>  }
>>
>>  static void put_arg_page(struct page *page)
>> --
>> 2.7.4
>>
>>
>> --
>> Kees Cook
>> Pixel Security
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
