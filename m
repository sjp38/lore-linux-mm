Received: by rn-out-0910.google.com with SMTP id j71so1963425rne.4
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 12:55:21 -0800 (PST)
Message-ID: <84144f020811241255v2d4de38j59ceeb967227489@mail.gmail.com>
Date: Mon, 24 Nov 2008 22:55:20 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH][V3]Make get_user_pages interruptible
In-Reply-To: <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <604427e00811211731l40898486r1a58e4940f3859e9@mail.gmail.com>
	 <6599ad830811241202o74312a18m84ed86a5f4393086@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

Hi Paul,

On Fri, Nov 21, 2008 at 5:31 PM, Ying Han <yinghan@google.com> wrote:
>>                         */
>> -                       if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>> -                               return i ? i : -ENOMEM;
>> +                       if (unlikely(sigkill_pending(tsk)))
>> +                               return i ? i : -ERESTARTSYS;

On Mon, Nov 24, 2008 at 10:02 PM, Paul Menage <menage@google.com> wrote:
> You've changed the check from sigkill_pending(current) to sigkill_pending(tsk).
>
> I originally made that sigkill_pending(current) since we want to avoid
> tasks entering an unkillable state just because they're doing
> get_user_pages() on a system that's short of memory. Admittedly for
> the main case that we care about, mlock() (or an mmap() with
> MCL_FUTURE set) then tsk==current, but philosophically it seems to me
> to be more correct to do the check against current than tsk, since
> current is the thing that's actually allocating the memory. But maybe
> it would be better to check both?

Well, most callers seem to pass 'current' to get_user_pages() but for
the out-of-tree revoke patches, for example, you certainly want to
check sigkill_pending(current) as well; otherwise the revoke operation
is unkillable while in get_user_pages().

Not that revoke() is going to hit mainline any time soon but it does
serve as an argument for checking both.

                        Pekka
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
