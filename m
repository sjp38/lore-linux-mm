From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14282.60217.253262.910401@dukat.scot.redhat.com>
Date: Mon, 30 Aug 1999 21:36:09 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <m1aer9je4i.fsf@alogconduit1ae.ccr.net>
References: <Pine.LNX.4.10.9908300949550.3356-100000@imperial.edgeglobal.com>
	<m1aer9je4i.fsf@alogconduit1ae.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: James Simmons <jsimmons@edgeglobal.com>, Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 30 Aug 1999 13:51:41 -0500, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> A) Assuming we are doing intensive drawing whatever we are doing with
>    the accellerator needs to happen about 30 times per second.  That
>    begins the aproximate limit on humans seeing updates.

> B) At 30hz we can do some slightly expensive things.
>    To a comuputer there is all kinds of time in there.

Sure, *if* you can get away with activating the accel queue just once
per cycle.  Who gets woken up when accel is done, btw?  How do we
restore fb access?

> C) We could simply put all processes that have the frame buffer
>    mapped to sleep during the interval that the accel enginge runs.

Ouch.  Think about games --- performance is the most important thing for
them, and they want all the CPU they can get.  They most certainly do
NOT want to be stalled just because the framebuffer is out of bounds:
there may be other useful things they could be calculating in the mean
time.

> D) We could keep a copy of the frame buffer (possibly in other video
>    memory) and copy the ``frame buffer'' over, (with memcpy in the kernel, or with an 
>    accel command).
>    At 1600x1280x32 x30hz that is about 220 MB/s.  Is that a figure achieveable in the
>    real world?

Not even close.  At least, not without consuming 100% cpu and bus bandwidth.

> E) Nowhere does it make sense to simultaneously access the accelerator
>    and frame buffer simultaneously. ( At least the same regions of the frame buffer).
>    Because the end result on the screen would be unpredicatable.
>    Therefore it whatever we use for locks ought to be reasonable.

That's a user space issue.  If you have full framebuffer access and you
mess up the screen, it's your fault, no big deal.  If you crash the
machine, that's an entirely different matter.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
