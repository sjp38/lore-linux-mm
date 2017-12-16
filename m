Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBE796B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:41:45 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id m3so2652077lfe.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:41:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u29sor1596134ljd.55.2017.12.15.18.41.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:41:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215211501.v6x6o2ft4khqgbgy@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171213104617.7lffucjhaa6xb7lp@gmail.com> <CANrsvRPuhPyh1nFnzdYj8ph7e1FQRw_W_WN2a1tm9fzpAYks4g@mail.gmail.com>
 <CANrsvRP3-bWatoaq1teNFG1RXRbazqnHvOKXe458eAxSdAnsfg@mail.gmail.com>
 <20171215062428.5dyv7wjbzn2ggxvz@thunk.org> <CANrsvROwvaZzAmTGFH=BaPohkXEB=HhDRdM3xdmPu0m4mjDpfw@mail.gmail.com>
 <20171215211501.v6x6o2ft4khqgbgy@thunk.org>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Sat, 16 Dec 2017 11:41:42 +0900
Message-ID: <CANrsvRMAhG0ofEXt-yWm+WhqJDtYZSaVhqguwQHnMU++pGqbVQ@mail.gmail.com>
Subject: Re: [PATCH] locking/lockdep: Remove the cross-release locking checks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, david@fromorbit.com, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

On Sat, Dec 16, 2017 at 6:15 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Fri, Dec 15, 2017 at 05:39:25PM +0900, Byungchul Park wrote:
>>
>> All locks should belong to one class if each path of acquisition
>> can be switchable each other within the class at any time.
>> Otherwise, they should belong to a different class.
>
> OK, so let's go back to my case of a Network Block Device with a local
> file system mounted on it, which is then exported via NFS.
>
> So an incoming TCP packet can go into the NFS server subsystem, then
> be processed by local disk file system, which then does an I/O
> operation to the NBD device, which results in an TCP packet being sent
> out.  Then the response will come back over TCP, into the NBD block
> layer, then into the local disk file system, and that will result in
> an outgoing response to the TCP connection for the NFS protocol.
>
> In order to avoid cross release problems, all locks associated with
> the incoming TCP connection will need to be classified as belonging to
> a different class as the outgoing TCP connection.  Correct?  One
> solution might be to put every single TCP connection into a separate
> class --- but that will explode the number of lock classes which
> Lockdep will need to track, and there is a limited number of lock
> classes (set at compile time) that Lockdep can track.  So if that
> doesn't work, we will have to put something ugly which manually makes
> certain TCP connections "magic" and require them to be put into a
> separate class than all other TCP connections, which will get
> collapsed into a single class.  Basically, any TCP connection which is
> either originated by the kernel, or passed in from userspace into the
> kernel and used by some kernel subsystem, will have to be assigned its
> own lockdep class.
>
> If the TCP connection gets closed, we don't need to track that lockdep
> class any more.  (Or if a device mapper device is torn down, we
> similarly don't need any unique lockdep classes created for that
> device mapper device.)  Is there a way to tell lockdep that a set of
> lockdep classes can be released so we can recover the kernel memory to
> be used to track some new TCP connection or some new device mapper
> device?

Right. I also think lockdep should be able to reflect that
kind of dynamic situations to do a better job.

The fact that kernel works well w/o that work doesn't
mean current status is perfect, in my opinion.

As you know, lockdep is running within very limited
environment so it's very hard to achieve it.

However, anyway, I think that's a problem and should
be solved by modifying lockdep core. Actually, that had
been one on my to-dos, if allowed.

For some waiters, for which this is only solution to play
with cross-release, I think we can invalidate those
waiters for now, while all others still get benefit.

We have added acquire annotations manually to
consider waiters one by one, and I am sure it's going
to continue in the future.

IMO, considering all waiters at once and fixing false
positives in a right way or invalidating one by one is
better than considering waiters one by one as is, of
course, while keeping off by default.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
