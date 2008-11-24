Message-ID: <492B2E83.7010605@cs.helsinki.fi>
Date: Tue, 25 Nov 2008 00:45:23 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH][V3]Make get_user_pages interruptible
References: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>	 <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>	 <604427e00811241302t2a52e38etffca2546f319a7af@mail.gmail.com>	 <84144f020811241313o7401e3c2gd360c4226f33b28f@mail.gmail.com> <604427e00811241350j25b7b483p1d171ea1b5b6f8bf@mail.gmail.com>
In-Reply-To: <604427e00811241350j25b7b483p1d171ea1b5b6f8bf@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

Ying Han wrote:
> thanks Pekka and i think one example of the case you mentioned is in
> access_process_vm() which is calling
> get_user_pages(tsk, mm, addr, 1, write, 1, &pages, &vma). However, it
> is allocating only one page here which
> much less likely to be stuck under memory pressure. Like you said, in
> order to make it more flexible for future
> changes, i might make the change like:
>>>>>                         */
>>>>> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>>>>> -                               return i ? i : -ENOMEM;
>>>>> +                       if (unlikely(sigkill_pending(current) | | sigkill_pending(tsk)))
>>>>> +                               return i ? i : -ERESTARTSYS;
> 
> is this something acceptable?

The formatting is bit wacky but I'm certainly OK with the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
