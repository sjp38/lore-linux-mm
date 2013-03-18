Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A608E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 12:05:37 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id l13so2853874wie.8
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 09:05:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1303172041460.1935@eggly.anvils>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
	<alpine.LNX.2.00.1303172041460.1935@eggly.anvils>
Date: Mon, 18 Mar 2013 09:05:35 -0700
Message-ID: <CAA25o9TohT6dADroSDzpc2q7oLTmb-eJ1QW53M4z51OkF2QU+g@mail.gmail.com>
Subject: Re: security: restricting access to swap
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Sonny Rao <sonnyrao@google.com>

On Sun, Mar 17, 2013 at 8:58 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 11 Mar 2013, Luigi Semenzato wrote:
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
>>
>> Thank you in advance for any input/suggestion!
>> Luigi

Hugh, thanks for the reply.

> Your O_KERN_SWAP does not make much sense to me.
>
> The open flag would only apply while the device or file is open, yet
> you would also want this security to apply after it has been closed.
>
> And there's not much security if you rely upon zeroing the swap area
> at swapoff.  Maybe it crashes before swapoff.

Yes, that would be a problem.  It's not in our case because the swap
device is ZRAM.

> Maybe you have /dev/sda1
> open O_KERN_SWAP, but someone is watching through /dev/sda.  Maybe you
> have swapfile open O_KERN_SWAP, but someone is watching through the
> block device of the filesystem holding swapfile.

Yes, I realize that this works only when using the entire device for swap.

> I think you want to encrypt the pages going out to swap, and encrypt
> them in such a way that only swap has the key.  Whether that's already
> easily achieved with dm I have no idea.

I think that for our application it may make sense to have a
ZRAM-specific solution.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
