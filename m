Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1FF736B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 23:59:04 -0400 (EDT)
Received: by mail-da0-f49.google.com with SMTP id t11so1059258daj.22
        for <linux-mm@kvack.org>; Sun, 17 Mar 2013 20:59:02 -0700 (PDT)
Date: Sun, 17 Mar 2013 20:58:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: security: restricting access to swap
In-Reply-To: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1303172041460.1935@eggly.anvils>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

On Mon, 11 Mar 2013, Luigi Semenzato wrote:
> Greetings linux-mmers,
> 
> before we can fully deploy zram, we must ensure it conforms to the
> Chrome OS security requirements.  In particular, we do not want to
> allow user space to read/write the swap device---not even root-owned
> processes.
> 
> A similar restriction is available for /dev/mem under CONFIG_STRICT_DEVMEM.
> 
> There are a few possible approaches to this, but before we go ahead
> I'd like to ask if anything has happened or is planned in this
> direction.
> 
> Otherwise, one idea I am playing with is to add a CONFIG_STRICT_SWAP
> option that would do this for any swap device (i.e. not specific to
> zram) and possibly also when swapping to a file.  We would add an
> "internal" open flag, O_KERN_SWAP, as well as clean up a little bit
> the FMODE_NONOTIFY confusion by adding the kernel flag O_KERN_NONOTIFY
> and formalizing the sets of external (O_*) and internal (O_KERN_*)
> open flags.
> 
> Swapon() and swapoff() would use O_KERN_SWAP internally, and a device
> opened with that flag would reject user-level opens.
> 
> Thank you in advance for any input/suggestion!
> Luigi

Your O_KERN_SWAP does not make much sense to me.

The open flag would only apply while the device or file is open, yet
you would also want this security to apply after it has been closed.

And there's not much security if you rely upon zeroing the swap area
at swapoff.  Maybe it crashes before swapoff.  Maybe you have /dev/sda1
open O_KERN_SWAP, but someone is watching through /dev/sda.  Maybe you
have swapfile open O_KERN_SWAP, but someone is watching through the
block device of the filesystem holding swapfile.

I think you want to encrypt the pages going out to swap, and encrypt
them in such a way that only swap has the key.  Whether that's already
easily achieved with dm I have no idea.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
