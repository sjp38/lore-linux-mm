Subject: Re: accel handling
References: <Pine.LNX.4.10.9908300949550.3356-100000@imperial.edgeglobal.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Aug 1999 13:51:41 -0500
In-Reply-To: James Simmons's message of "Mon, 30 Aug 1999 10:31:27 -0400 (EDT)"
Message-ID: <m1aer9je4i.fsf@alogconduit1ae.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Simmons <jsimmons@edgeglobal.com> writes:

> > What I believe James is talking about here is allowing non-priviledged
> > processes to access graphics hardware where the graphics card, or even
> > the whole system, may enter an unrecoverable state if you try to access
> > the frame buffer while the accel engine is active. (Yes there really
> > exist such hardware...)
> > 
> > To achieve this you really must physicly prevent the process to access
> > the framebuffer while the accel engine is active. The question is what
> > the best way to do this is (and if that way is good enough to bother
> > doing it...) ?
> 
> Marcus you are on this list too. Actually I have though about what he
> said. I never though of it this way but you can think of the accel engine
> as another "process" trying to use the framebuffer. Their still is the
> question. How do you know when a mmap of the framebuffer is being
> accessed? So I can lock the accel engine when needed.

Just a couple of thoughts.

A) Assuming we are doing intensive drawing whatever we are doing with
   the accellerator needs to happen about 30 times per second.  That
   begins the aproximate limit on humans seeing updates.

B) At 30hz we can do some slightly expensive things.
   To a comuputer there is all kinds of time in there.

C) We could simply put all processes that have the frame buffer
   mapped to sleep during the interval that the accel enginge runs.

D) We could keep a copy of the frame buffer (possibly in other video
   memory) and copy the ``frame buffer'' over, (with memcpy in the kernel, or with an 
   accel command).
   At 1600x1280x32 x30hz that is about 220 MB/s.  Is that a figure achieveable in the
   real world?

E) Nowhere does it make sense to simultaneously access the accelerator
   and frame buffer simultaneously. ( At least the same regions of the frame buffer).
   Because the end result on the screen would be unpredicatable.
   Therefore it whatever we use for locks ought to be reasonable.

F) It might be work bouncing this off of the ggi guys to see if they have
   satisfactorily solved this problem.  Last I looked the ggi list was linux-ggi@eskimo.com

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
