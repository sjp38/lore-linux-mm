Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5AB4E6B0038
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:48:51 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id s43so3226750wey.21
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 08:48:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5142E411.2040005@gmail.com>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
	<5142E411.2040005@gmail.com>
Date: Fri, 15 Mar 2013 08:48:49 -0700
Message-ID: <CAA25o9RPhu++JsX_8AjhqJuodRkybiYVSEifjCXX=oPnOO5fEA@mail.gmail.com>
Subject: Re: security: restricting access to swap
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Mar 15, 2013 at 2:04 AM, Ric Mason <ric.masonn@gmail.com> wrote:
> On 03/12/2013 07:57 AM, Luigi Semenzato wrote:
>>
>> Greetings linux-mmers,
>>
>> before we can fully deploy zram, we must ensure it conforms to the
>> Chrome OS security requirements.  In particular, we do not want to
>> allow user space to read/write the swap device---not even root-owned
>> processes.
>
>
> Interesting.

Thank you.

>>
>> A similar restriction is available for /dev/mem under
>> CONFIG_STRICT_DEVMEM.
>
>
> Sorry, what's /dev/mem used for?  and why relevant your topic?

I don't know what it's used for Chrome OS, but I don't think it
matters.  The point is that /dev/mem is compiled in the kernel, and
without CONFIG_STRICT_DEVMEM it offers a way for a root-owned process
to read/write all of physical memory.  The situation is not as dire
with a swap device, but currently a root-owned process can open a
block device used for swap and peek and poke its data, which means
that a root-owned process has now potential access to the data segment
of any other process, among other things.

>>
>> There are a few possible approaches to this, but before we go ahead
>> I'd like to ask if anything has happened or is planned in this
>> direction.
>>
>> Otherwise, one idea I am playing with is to add a CONFIG_STRICT_SWAP
>> option that would do this for any swap device (i.e. not specific to
>> zram) and possibly also when swapping to a file.  We would add an
>> "internal" open flag, O_KERN_SWAP, as well as clean up a little bit
>> the FMODE_NONOTIFY confusion by adding the kernel flag O_KERN_NONOTIFY
>> and formalizing the sets of external (O_*) and internal (O_KERN_*)
>> open flags.
>>
>> Swapon() and swapoff() would use O_KERN_SWAP internally, and a device
>> opened with that flag would reject user-level opens.
>>
>> Thank you in advance for any input/suggestion!
>> Luigi
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
