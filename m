Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D23AE6B0006
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 19:57:27 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id ds1so2698176wgb.2
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 16:57:26 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 11 Mar 2013 16:57:25 -0700
Message-ID: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
Subject: security: restricting access to swap
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Greetings linux-mmers,

before we can fully deploy zram, we must ensure it conforms to the
Chrome OS security requirements.  In particular, we do not want to
allow user space to read/write the swap device---not even root-owned
processes.

A similar restriction is available for /dev/mem under CONFIG_STRICT_DEVMEM.

There are a few possible approaches to this, but before we go ahead
I'd like to ask if anything has happened or is planned in this
direction.

Otherwise, one idea I am playing with is to add a CONFIG_STRICT_SWAP
option that would do this for any swap device (i.e. not specific to
zram) and possibly also when swapping to a file.  We would add an
"internal" open flag, O_KERN_SWAP, as well as clean up a little bit
the FMODE_NONOTIFY confusion by adding the kernel flag O_KERN_NONOTIFY
and formalizing the sets of external (O_*) and internal (O_KERN_*)
open flags.

Swapon() and swapoff() would use O_KERN_SWAP internally, and a device
opened with that flag would reject user-level opens.

Thank you in advance for any input/suggestion!
Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
