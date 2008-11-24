Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id mAOLoKRF032327
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 13:50:20 -0800
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by spaceape9.eur.corp.google.com with ESMTP id mAOLoHr6019301
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 13:50:18 -0800
Received: by wf-out-1314.google.com with SMTP id 25so2362517wfc.22
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 13:50:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84144f020811241313o7401e3c2gd360c4226f33b28f@mail.gmail.com>
References: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>
	 <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>
	 <604427e00811241302t2a52e38etffca2546f319a7af@mail.gmail.com>
	 <84144f020811241313o7401e3c2gd360c4226f33b28f@mail.gmail.com>
Date: Mon, 24 Nov 2008 13:50:17 -0800
Message-ID: <604427e00811241350j25b7b483p1d171ea1b5b6f8bf@mail.gmail.com>
Subject: Re: [PATCH][V3]Make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

thanks Pekka and i think one example of the case you mentioned is in
access_process_vm() which is calling
get_user_pages(tsk, mm, addr, 1, write, 1, &pages, &vma). However, it
is allocating only one page here which
much less likely to be stuck under memory pressure. Like you said, in
order to make it more flexible for future
changes, i might make the change like:
>>>>                         */
>>>> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>>>> -                               return i ? i : -ENOMEM;
>>>> +                       if (unlikely(sigkill_pending(current) | | sigkill_pending(tsk)))
>>>> +                               return i ? i : -ERESTARTSYS;

is this something acceptable?



On Mon, Nov 24, 2008 at 1:13 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> On Fri, Nov 21, 2008 at 5:31 PM, Ying Han <yinghan@google.com> wrote:
>>>>                         */
>>>> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>>>> -                               return i ? i : -ENOMEM;
>>>> +                       if (unlikely(sigkill_pending(tsk)))
>>>> +                               return i ? i : -ERESTARTSYS;
>
> On Mon, Nov 24, 2008 at 12:02 PM, Paul Menage <menage@google.com> wrote:
>>> You've changed the check from sigkill_pending(current) to sigkill_pending(tsk).
>>>
>>> I originally made that sigkill_pending(current) since we want to avoid
>>> tasks entering an unkillable state just because they're doing
>>> get_user_pages() on a system that's short of memory. Admittedly for
>>> the main case that we care about, mlock() (or an mmap() with
>>> MCL_FUTURE set) then tsk==current, but philosophically it seems to me
>>> to be more correct to do the check against current than tsk, since
>>> current is the thing that's actually allocating the memory. But maybe
>>> it would be better to check both?
>
> On Mon, Nov 24, 2008 at 11:02 PM, Ying Han <yinghan@google.com> wrote:
>> In most of cases, tsk==current in get_user_pages(), that is why i
>> change current to tsk since
>> tsk is a superset of current, no? If that is right, why we need to check both?
>
> I'm not sure if it's strictly necessary but as I pointed out in the
> other mail, there can be callers that are doing get_user_pages() on
> behalf of other tasks and you probably want to be able to kill the
> task that's actually _calling_ get_user_pages() as well.
>
>                        Pekka
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
