Received: by an-out-0708.google.com with SMTP id d14so879768and.26
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 13:13:10 -0800 (PST)
Message-ID: <84144f020811241313o7401e3c2gd360c4226f33b28f@mail.gmail.com>
Date: Mon, 24 Nov 2008 23:13:10 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH][V3]Make get_user_pages interruptible
In-Reply-To: <604427e00811241302t2a52e38etffca2546f319a7af@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>
	 <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>
	 <604427e00811241302t2a52e38etffca2546f319a7af@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 21, 2008 at 5:31 PM, Ying Han <yinghan@google.com> wrote:
>>>                         */
>>> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>>> -                               return i ? i : -ENOMEM;
>>> +                       if (unlikely(sigkill_pending(tsk)))
>>> +                               return i ? i : -ERESTARTSYS;

On Mon, Nov 24, 2008 at 12:02 PM, Paul Menage <menage@google.com> wrote:
>> You've changed the check from sigkill_pending(current) to sigkill_pending(tsk).
>>
>> I originally made that sigkill_pending(current) since we want to avoid
>> tasks entering an unkillable state just because they're doing
>> get_user_pages() on a system that's short of memory. Admittedly for
>> the main case that we care about, mlock() (or an mmap() with
>> MCL_FUTURE set) then tsk==current, but philosophically it seems to me
>> to be more correct to do the check against current than tsk, since
>> current is the thing that's actually allocating the memory. But maybe
>> it would be better to check both?

On Mon, Nov 24, 2008 at 11:02 PM, Ying Han <yinghan@google.com> wrote:
> In most of cases, tsk==current in get_user_pages(), that is why i
> change current to tsk since
> tsk is a superset of current, no? If that is right, why we need to check both?

I'm not sure if it's strictly necessary but as I pointed out in the
other mail, there can be callers that are doing get_user_pages() on
behalf of other tasks and you probably want to be able to kill the
task that's actually _calling_ get_user_pages() as well.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
