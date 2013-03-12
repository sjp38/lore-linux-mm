Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 2F1296B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 11:46:47 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id ez12so1970319wid.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 08:46:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130312130636.GC17901@phenom.dumpdata.com>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
	<20130312130636.GC17901@phenom.dumpdata.com>
Date: Tue, 12 Mar 2013 08:46:40 -0700
Message-ID: <CAA25o9RRYHgepo8Loqv2FJ3jFoM0Fo_VZVRG9Pndi8_OqWioOw@mail.gmail.com>
Subject: Re: security: restricting access to swap
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org

On Tue, Mar 12, 2013 at 6:06 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Mon, Mar 11, 2013 at 04:57:25PM -0700, Luigi Semenzato wrote:
>> Greetings linux-mmers,
>>
>> before we can fully deploy zram, we must ensure it conforms to the
>> Chrome OS security requirements.  In particular, we do not want to
>> allow user space to read/write the swap device---not even root-owned
>> processes.
>>
>> A similar restriction is available for /dev/mem under CONFIG_STRICT_DEVMEM.
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
>
> What/who does the swapon/swapoff calls? Is there an kernel level thread
> (aka init but in kernel?) that would do this?

No, swapon() would be typically called from user level shortly after
boot by the swapon program to set up swap.  Swapoff() would typically
not be called at all.

The swapon() syscall internally calls filp_open() and that's where it
would pass the O_KERN_SWAP flag.  It also needs to pass an extra flag
in claim_swapfile().

I should probably just send a patch.

>>
>> Thank you in advance for any input/suggestion!
>> Luigi
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
